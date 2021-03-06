#import <objc/runtime.h>
#import "__CLASS__PREFIX__RestAPIClient.h"
#import "__CLASS__PREFIX__RestAPI.h"
#import "__CLASS__PREFIX__RegistrationHelper.h"
#import "AFJSONRequestOperation.h"


/**
* Maintains list of delegates, so each of them could cancel all requests associated with it.
*/


static char kCDRestAPIOperationDelegateObjectKey;


@implementation __CLASS__PREFIX__RestAPIClient
{

}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSString *applicationVersion = (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        CGFloat scale = [[UIScreen mainScreen] scale];
        NSString *screenSize = [NSString stringWithFormat:@"%dx%d", (NSInteger)([UIScreen mainScreen].bounds.size.width * scale), (NSInteger)([UIScreen mainScreen].bounds.size.height * scale)];

        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Device-ID" value:[__CLASS__PREFIX__RegistrationHelper deviceId]];
        [self setDefaultHeader:@"Push-ID" value:[__CLASS__PREFIX__RegistrationHelper pushToken]];
        [self setDefaultHeader:@"Device-OS" value:@"iOS"];
        [self setDefaultHeader:@"Device-OS-Version" value:[[UIDevice currentDevice] systemVersion]];
        [self setDefaultHeader:@"Device-Model" value:[[UIDevice currentDevice] model]];
        [self setDefaultHeader:@"Device-Screen-Size" value:screenSize];
        [self setDefaultHeader:@"Application" value:applicationName];
        [self setDefaultHeader:@"Application-Version" value:applicationVersion];
        if ([__CLASS__PREFIX__RegistrationHelper authToken]) {
            [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", [__CLASS__PREFIX__RegistrationHelper authToken]]];
        }

        self.parameterEncoding = AFJSONParameterEncoding;
    }

    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    [self setDefaultHeader:@"Device-ID" value:[__CLASS__PREFIX__RegistrationHelper deviceId]];
    [self setDefaultHeader:@"Push-ID" value:[__CLASS__PREFIX__RegistrationHelper pushToken]];
    if ([__CLASS__PREFIX__RegistrationHelper authToken]) {
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", [__CLASS__PREFIX__RegistrationHelper authToken]]];
    }
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    [request setTimeoutInterval:10];
    return request;
}


/** Makes request, maps list of operations to given delegate;
*
* @param path Relative url
* @param delegate Delegate
* @param parameters GET-params
* @param success Completion block
* @param failure Failure block
*/
- (void)getPath:(NSString *)path
        delegate:(id)delegate
        parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
        delegate:(id)delegate
        parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

- (void)putPath:(NSString *)path
        delegate:(id)delegate
        parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path
        delegate:(id)delegate
        parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

- (void)patchPath:(NSString *)path
        delegate:(id)delegate
        parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

/** Cancels all operations associated with delegate
*
* @param delegate Delegate
*/
- (void)cancelAllOperationsForDelegate:(id)delegate
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }

        BOOL match = (id)objc_getAssociatedObject(operation, &kCDRestAPIOperationDelegateObjectKey) == delegate;

        if (match) {
            [operation cancel];
        }
    }
}

@end