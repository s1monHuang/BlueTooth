//
//  BaseRequestOperator.h
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"

#define kSVRDefaultTimeout           60.0f

typedef void (^BaseNetworkCallBack)( BOOL success, id responseObject, NSError *error);

@class AFHTTPResponseSerializer;
@class AFHTTPRequestOperation;

@interface BaseRequestOperator : NSObject

+ (NSString *)serverDomain;
+ (instancetype)requestOperator;

- (void)cancelRequest;
- (AFHTTPResponseSerializer *)createResponseSerializer;

-(void)requestNetworkWithPath:(NSString *)path
                   parameters:(NSDictionary *)parameters
                callBackBlock:(BaseNetworkCallBack)callBackBlock;

-(void)requestNetworkWithHost:(NSString *)host
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters
                callBackBlock:(BaseNetworkCallBack)callBackBlock;

-(void)requestNetworkWithHost:(NSString *)host
                         path:(NSString *)path
                       isPost:(BOOL)isPost
                   parameters:(NSDictionary *)parameters
                      timeOut:(CGFloat)timeOut
                  reserveInfo:(id)reserveInfo
                callBackBlock:(BaseNetworkCallBack)callBackBlock;

// 上传图片等二进制文件
-(void)requestMultipartFormPostWithHost:(NSString *)host
                                   path:(NSString *)path
                             parameters:(NSDictionary *)parameters
                                   data:(id )data
                               postName:(NSString *)postName
                               fileName:(NSString *)fileName
                          callBackBlock:(BaseNetworkCallBack)callBackBlock;



@end
