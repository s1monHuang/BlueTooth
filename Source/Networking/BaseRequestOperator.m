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
//    return kAppApiServer;
    return kAppDomain;
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
    AFHTTPResponseSerializer * ResponseSerializer = [AppResponseSerializer serializer];
    return ResponseSerializer;
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
    
    //设置请求头
    if ([self systemLanguageIsEnglish]) {
        [requestSerializer setValue:@"1" forHTTPHeaderField:@"yuyan"];
    }
    
    requestSerializer.timeoutInterval = timeOut > 0 ? timeOut : kSVRDefaultTimeout;
    
    parameters = [self appendHeaderParams:parameters];
    NSString *urlPath = [NSString stringWithFormat:@"%@/%@", host, path];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:(isPost ? @"GET" : @"GET") URLString:[[NSURL URLWithString:urlPath] absoluteString] parameters:parameters error:nil];
    
    self.afRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    self.afRequestOperation.responseSerializer = [self createResponseSerializer];
    
    DLog(@"\nHTTP Requesting === %@, %@", [request.URL absoluteString] , parameters);
    [self.afRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    
    //设置请求头
    if ([self systemLanguageIsEnglish]) {
        [requestSerializer setValue:@"1" forHTTPHeaderField:@"yuyan"];
    }
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

- (BOOL)systemLanguageIsEnglish
{
    //获取系统当前语言版本（中文zh-Hans,英文en)
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage isEqualToString:@"en-CN"]) {
        return YES;
    }else{
        return NO;
    }

}

//- (void)sethettpHeader
//{
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    
//    [request setHTTPMethod:@"GET"];
//    [request setValue:kTParamObject.authorization forHTTPHeaderField:@"Authorization"];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
//    [operation start];
//}




@end
