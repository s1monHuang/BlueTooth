//
//  BaseRequestOperator.h
//

#import "BaseRequestOperator.h"
#import "AppResponseSerializer.h"

@interface BaseRequestOperator ()
@property (nonatomic, strong) AFHTTPRequestOperation *afRequestOperation;
@end

@implementation BaseRequestOperator

+ (NSString *)serverDomain
{
    return kAppApiServer;
}

+ (instancetype)requestOperator
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    return self;
}

-(void)dealloc
{
    [self cancelRequest];
}

- (void)cancelRequest
{
    if (_afRequestOperation)
    {
        [_afRequestOperation cancel];
        _afRequestOperation = nil;
    }else{}
}

- (AFHTTPResponseSerializer *)createResponseSerializer
{
    return [AppResponseSerializer serializer];
}

- (NSDictionary *)appendHeaderParams:(NSDictionary *)params
{
    if (!params) return nil;
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
    return [mParams copy];
}

-(void)requestNetworkWithPath:(NSString *)path
                   parameters:(NSDictionary *)parameters
                callBackBlock:(BaseNetworkCallBack)callBackBlock
{
    [self requestNetworkWithHost:[[self class] serverDomain]  path:path isPost:NO parameters:parameters timeOut:kSVRDefaultTimeout reserveInfo:nil callBackBlock:callBackBlock];

}

-(void)requestNetworkWithHost:(NSString *)host
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters
                callBackBlock:(BaseNetworkCallBack)callBackBlock
{
    [self requestNetworkWithHost:host path:path isPost:NO parameters:parameters timeOut:kSVRDefaultTimeout reserveInfo:nil callBackBlock:callBackBlock];
}


-(void)requestNetworkWithHost:(NSString *)host
                         path:(NSString *)path
                       isPost:(BOOL)isPost
                   parameters:(NSDictionary *)parameters
                      timeOut:(CGFloat)timeOut
                  reserveInfo:(id)reserveInfo
                callBackBlock:(BaseNetworkCallBack)callBackBlock
{
//    [self cancelRequest];
    
    AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = timeOut > 0 ? timeOut : kSVRDefaultTimeout;
    
    parameters = [self appendHeaderParams:parameters];
    NSString *urlPath = [NSString stringWithFormat:@"%@/%@", host, path];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:(isPost ? @"GET" : @"GET") URLString:[[NSURL URLWithString:urlPath] absoluteString] parameters:parameters error:nil];
    self.afRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.afRequestOperation.responseSerializer = [self createResponseSerializer];
    
    DLog(@"\nHTTP Requesting === %@, %@", [request.URL absoluteString] , parameters);
    [self.afRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //DLog(@"\nHTTP Request success === %@ , %@ \n Response === %@ ", urlPath, parameters , [[responseObject description] logUTF8String]);
        DLog(@"^^^^^^^^^^%@",responseObject[@"retMsg"]);
        if(callBackBlock) callBackBlock(YES, responseObject, nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //[UtilityUI showHUDWithErrorText:@"网络好像不给力！"];
         DLog(@"\nHTTP Request End Failed === %@, %@, \n %@", urlPath, parameters , error);
         if(callBackBlock) callBackBlock(NO, nil, error);
     }];
    
    [self.afRequestOperation start];
}

-(void)requestMultipartFormPostWithHost:(NSString *)host
                                  path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                      data:(id )data
                                  postName:(NSString *)postName
                                  fileName:(NSString *)fileName
                             callBackBlock:(BaseNetworkCallBack)callBackBlock
{
    
//    [self cancelRequest];
    
    AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSString *urlPath = [NSString stringWithFormat:@"%@/%@", host, path];
    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ([data isKindOfClass:[NSString class]]) {
            DLog(@"post muti filePath:%@",data);
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:data] name:postName error:nil];
        }else if([data isKindOfClass:[NSData class]]){
            DLog(@"post muti data:%@",fileName);
            [formData appendPartWithFileData:(NSData *)data name:postName fileName:fileName mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    //    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST"  URLString:[[NSURL URLWithString:urlPath] absoluteString] parameters:parameters error:nil];
    self.afRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.afRequestOperation.responseSerializer = [self createResponseSerializer];
    
    DLog(@"\nHTTP Requesting === %@, %@", [request.URL absoluteString] , parameters);
    [self.afRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //DLog(@"\nHTTP Request success === %@ , %@ \n Response === %@ ", urlPath, parameters , [[responseObject description] logUTF8String]);
        
        if (Dictionary(responseObject)) {
            if (responseObject[@"returnRoot"][@"resultCode"] && ([responseObject[@"returnRoot"][@"resultCode"] integerValue] == 0))
            {
                if(callBackBlock) callBackBlock(YES, responseObject, nil);
                return;
            }
        }
        
        if(callBackBlock) callBackBlock(YES, responseObject, nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [UtilityUI showHUDWithErrorText:@"网络好像不给力！"];
         DLog(@"\nHTTP Request End Failed === %@, %@, \n %@", urlPath, parameters , error);
         if(callBackBlock) callBackBlock(NO, nil, error);
     }];
    
    [self.afRequestOperation start];
}




@end
