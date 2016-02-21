//
//  InstagramEngine.m
//  GetImageFromInstagram
//
//  Created by Home on 12/10/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "InstagramEngine.h"
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "InstagramKitConstants.h"
#import "InstagramPaginationInfo.h"
#import "InstagramModel.h"

@interface InstagramEngine()

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end

@implementation InstagramEngine

+ (instancetype)sharedEngine {
    static InstagramEngine *_sharedEngine = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedEngine = [[InstagramEngine alloc] init];
    });
    return _sharedEngine;
}


- (instancetype)init {
    
    if (self = [super init])
    {
        NSURL *baseURL = [NSURL URLWithString:kInstagramKitBaseURL];
        self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        self.httpManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        self.appClientID = info[kInstagramAppClientIdConfigurationKey];
        self.appRedirectURL = info[kInstagramAppRedirectURLConfigurationKey];
        
        self.backgroundQueue = dispatch_queue_create("instagramkit.response.queue", NULL);
        
        if (!IKNotNull(self.appClientID) || [self.appClientID isEqualToString:@""]) {
            NSLog(@"ERROR : InstagramKit - Invalid Client ID. Please set a valid value for the key \"%@\" in the App's Info.plist file",kInstagramAppClientIdConfigurationKey);
        }
        
        if (!IKNotNull(self.appRedirectURL) || [self.appRedirectURL isEqualToString:@""]) {
            NSLog(@"ERROR : InstagramKit - Invalid Redirect URL. Please set a valid value for the key \"%@\" in the App's Info.plist file",kInstagramAppRedirectURLConfigurationKey);
        }
        
        #if INSTAGRAMKIT_UICKEYCHAINSTORE
        self.keychainStore = [UICKeyChainStore keyChainStoreWithService:InstagramKitKeychainStore];
        _accessToken = self.keychainStore[@"token"];
        #endif
    }
    return self;
}


- (NSURL *)authorizationURL
{
    return [self authorizationURLForScope:InstagramKitLoginScopeBasic];
}


- (NSURL *)authorizationURLForScope:(InstagramKitLoginScope)scope
{
    NSDictionary *parameters = [self authorizationParametersWithScope:scope];
    NSURLRequest *authRequest = (NSURLRequest *)[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:kInstagramKitAuthorizationURL parameters:parameters error:nil];
    return authRequest.URL;
}

- (NSDictionary *)authorizationParametersWithScope:(InstagramKitLoginScope)scope
{
    NSString *scopeString = [self stringForScope:scope];
    NSDictionary *parameters = @{ @"client_id": self.appClientID,
                                  @"redirect_uri": self.appRedirectURL,
                                  @"response_type": @"token",
                                  @"scope": scopeString };
    return parameters;
}



- (NSString *)stringForScope:(InstagramKitLoginScope)scope
{
    NSArray *typeStrings = @[@"basic", @"comments", @"relationships", @"likes"];
    
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:typeStrings.count];
    [typeStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSUInteger enumBitValueToCheck = 1 << idx;
        (scope & enumBitValueToCheck) ? [strings addObject:obj] : 0;
    }];
    
    return (strings.count) ? [strings componentsJoinedByString:@" "] : typeStrings[0];
}


- (BOOL)receivedValidAccessTokenFromURL:(NSURL *)url
                                  error:(NSError *__autoreleasing *)error
{
    NSURL *appRedirectURL = [NSURL URLWithString:self.appRedirectURL];
    if (![appRedirectURL.scheme isEqual:url.scheme] || ![appRedirectURL.host isEqual:url.host])
    {
        return NO;
    }
    
    BOOL success = YES;
    NSString *token = [self queryStringParametersFromString:url.fragment][@"access_token"];
    if (token)
    {
        self.accessToken = token;
    }
    else
    {
        NSString *localizedDescription = NSLocalizedString(@"Authorization not granted.", @"Error notification to indicate Instagram OAuth token was not provided.");
        *error = [NSError errorWithDomain:InstagramKitErrorDomain
                                     code:InstagramKitAuthenticationFailedError
                                 userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
        success = NO;
    }
    return success;
}

- (NSDictionary *)queryStringParametersFromString:(NSString*)string {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [[string componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * param, NSUInteger idx, BOOL *stop) {
        NSArray *pairs = [param componentsSeparatedByString:@"="];
        if ([pairs count] != 2) return;
        
        NSString *key = [pairs[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [pairs[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:value forKey:key];
    }];
    return dict;
}



#pragma mark -


- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    
#if INSTAGRAMKIT_UICKEYCHAINSTORE
    self.keychainStore[@"token"] = self.accessToken;
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:InstagramKitUserAuthenticationChangedNotification object:nil];
}


- (BOOL)isSessionValid
{
    return self.accessToken != nil;
}


- (void)logout
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:cookie];
    }];
    
    self.accessToken = nil;
}

- (void)getPopularMediaWithSuccess:(InstagramMediaBlock)success
                           failure:(InstagramFailureBlock)failure
{
    [self getPaginatedPath:@"media/popular"
                parameters:nil
             responseModel:[InstagramMedia class]
                   success:success
                   failure:failure];
}


- (void)getPaginatedPath:(NSString *)path
              parameters:(NSDictionary *)parameters
           responseModel:(Class)modelClass
                 success:(InstagramPaginatiedResponseBlock)success
                 failure:(InstagramFailureBlock)failure
{
    NSDictionary *params = [self dictionaryWithAccessTokenAndParameters:parameters];
    NSString *percentageEscapedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.httpManager GET:percentageEscapedPath
               parameters:params
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      if (!success) return;
                      NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                      
                      NSDictionary *pInfo = responseDictionary[kPagination];
                      InstagramPaginationInfo *paginationInfo = IKNotNull(pInfo)?[[InstagramPaginationInfo alloc] initWithInfo:pInfo andObjectType:modelClass]: nil;
                      
                      NSArray *responseObjects = IKNotNull(responseDictionary[kData]) ? responseDictionary[kData] : nil;
                      
                      NSMutableArray *objects = [NSMutableArray arrayWithCapacity:responseObjects.count];
                      dispatch_async(self.backgroundQueue, ^{
                          [responseObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                              NSDictionary *info = obj;
                              id model = [[modelClass alloc] initWithInfo:info];
                              [objects addObject:model];
                          }];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              NSLog(@"dispatch_get_main_queue");
                              success(objects, paginationInfo);
                          });
                      });
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      (failure)? failure(error, ((NSHTTPURLResponse *)[task response]).statusCode) : 0;
                  }];
}

- (NSDictionary *)dictionaryWithAccessTokenAndParameters:(NSDictionary *)params
{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:params];
    if (self.accessToken) {
        [mutableDictionary setObject:self.accessToken forKey:kKeyAccessToken];
    }
    else
    {
        [mutableDictionary setObject:self.appClientID forKey:kKeyClientID];
    }
    return [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

- (void)getSelfFeedWithCount:(NSInteger)count
                       maxId:(NSString *)maxId
                     success:(InstagramMediaBlock)success
                     failure:(InstagramFailureBlock)failure
{
    NSDictionary *params = [self parametersFromCount:count maxId:maxId andPaginationKey:kPaginationKeyMaxId];
    [self getPaginatedPath:(self.currentTagSearch != nil ? [NSString stringWithFormat:@"tags/%@/media/recent",self.currentTagSearch] :[NSString stringWithFormat:@"users/self/feed"])
                parameters:params
             responseModel:[InstagramMedia class]
                   success:success
                   failure:failure];
}


- (NSDictionary *)parametersFromCount:(NSInteger)count maxId:(NSString *)maxId andPaginationKey:(NSString *)key
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (count) {
        [params setObject:[NSString stringWithFormat:@"%ld",(long)count] forKey:kCount];
    }
    if (maxId) {
        [params setObject:maxId forKey:key];
    }
    return [params copy];
}

@end
