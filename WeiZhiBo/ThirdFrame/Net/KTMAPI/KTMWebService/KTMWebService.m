//
//  KTMWebService.m
//  KTMExpertCheck
//
//  Created by fangling on 15/8/24.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import "KTMWebService.h"
#import "AFNetworking.h"

@implementation KTMWebService
//
//+ (void)postWithURL:(NSString *)URLString
//         parameters:(id)parametes
//             sucess:(void(^)(id responseObject))success
//            failure:(void(^)(NSError *error))failure {
//    
//    if ([AccessTokenManager accessTokenIsValid]) { // access token 有效
//        [self tokenPostWithURL:URLString parameters:parametes sucess:^(id responseObject) {
//            if (success) {
//                success(responseObject);
//            }
//        } failure:^(NSError *error) {
//            if (failure) {
//                failure(error);
//            }
//        }];
//        
//    } else { // access token 无效
//        
//        [AccessTokenManager refreshToken:^(bool getToken) {
//            if (getToken) {
//                [self tokenPostWithURL:URLString parameters:parametes sucess:^(id responseObject) {
//                    if (success) {
//                        success(responseObject);
//                    }
//                } failure:^(NSError *error) {
//                    if (failure) {
//                        failure(error);
//                    }
//                }];
//            }
//        } failure:^(NSError *error) {
//            if (failure) {
//                failure(error);
//            }
//        }];
//    }
//}
//
//+ (void)getWithURL:(NSString *)URLString
//        parameters:(id)parametes
//            sucess:(void(^)(id responseObject))success
//           failure:(void(^)(NSError *error))failure {
//    
//    if ([AccessTokenManager accessTokenIsValid]) { // access token 有效
//        [self tokenGetWithURL:URLString parameters:parametes sucess:^(id responseObject) {
//            if (success) {
//                success(responseObject);
//            }
//        } failure:^(NSError *error) {
//            if (failure) {
//                failure(error);
//            }
//        }];
//        
//    } else { // access token 无效
//        [AccessTokenManager refreshToken:^(bool getToken) {
//            if (getToken) {
//                [self tokenGetWithURL:URLString parameters:parametes sucess:^(id responseObject) {
//                    if (success) {
//                        success(responseObject);
//                    }
//                } failure:^(NSError *error) {
//                    if (failure) {
//                        failure(error);
//                    }
//                }];
//            }
//        } failure:^(NSError *error) {
//            if (failure) {
//                failure(error);
//            }
//        }];
//    }
//}

+ (void)tokenPostWithURL:(NSString *)URLString
              parameters:(id)parametes
                  sucess:(void(^)(id responseObject))success
                 failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer  = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
//    [session.requestSerializer setValue:[self getAccessToken] forHTTPHeaderField:@"AccessToken"];
//    NSString *URL = [NSString stringWithFormat:@"%@&AccessToken=%@",URLString,[self getAccessToken]];
    
    [session POST:URLString parameters:parametes progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

+ (void)tokenGetWithURL:(NSString *)URLString
        parameters:(id)parametes
            sucess:(void(^)(id responseObject))success
           failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
//    [session.requestSerializer setValue:[self getAccessToken] forHTTPHeaderField:@"AccessToken"];
//     NSString *URL = [NSString stringWithFormat:@"%@&AccessToken=%@",URLString,[self getAccessToken]];
    [session GET:URLString parameters:parametes progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
   
}

//uploadImage

+ (void)postUploadingWithURL:(NSString *)URLString
                  parameters:(id)parameters
                   imageData:(NSData *)imageData
                 nameOfimage:(NSString *)name
                    progress:(void (^) (NSProgress *))progress
                      sucess:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:date];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", dateString];
        
        [formData appendPartWithFileData:imageData
                                    name:name
                                fileName:fileName
                                mimeType:@"jpg/png"];
        
    } progress:^(NSProgress *uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)postFormWithURL:(NSString *)URLString
             parameters:(id)parametes
                 sucess:(void(^)(id responseObject))success
                failure:(void(^)(NSError *error))failure {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parametes error:nil];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            if (failure) {
                failure(error);
            }
            
        } else {
            if (success) {
                success(responseObject);
            }
        }
    }];
    
    [dataTask resume];
}

// 新版本上传图片
+ (void)postUploadImageWithURL:(NSString *)URLString
                     imageData:(NSData *)imageData
                   nameOfImage:(NSString *)name
                    fileOfName:(NSString *)fileName
                    mimeOfType:(NSString *)mineType
                      progress:(void (^) (NSProgress *uploadProgress))progress
                        sucess:(void(^)(id responseObject))success
                       failure:(void(^)(NSError *error))failure {
    
//    NSDictionary *parameter = @{@"AccessToken":[self getAccessToken]};

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager POST:URLString parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData
                                    name:name
                                fileName:fileName
                                mimeType:mineType];
        
    } progress:^(NSProgress *uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

// 批量上传图片
+ (void)postUploadBatchImagesWithURL:(NSString *)URLString
                          imagesData:(NSArray *)imagesData
                         nameOfImage:(NSString *)name
                          fileOfName:(NSString *)fileName
                          mimeOfType:(NSString *)mineType
                            progress:(void (^) (NSProgress *uploadProgress))progress
                              sucess:(void(^)(id responseObject))success
                             failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:URLString parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        
        for (int i = 0; i < imagesData.count; i++) {
            NSData *imgData = imagesData[i];
            /*! 拼接data */
            if (imgData != nil) {
                [formData appendPartWithFileData:imgData name:name fileName:[NSString stringWithFormat:@"%@-%d",fileName,i] mimeType:mineType];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            // progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}
/*******************dot have token********************/
// 普通的post请求（没有token的情况）
+ (void)CMPostWithURL:(NSString *)URLString
           parameters:(id)parametes
               sucess:(void(^)(id responseObject))success
              failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer  = [AFJSONRequestSerializer serializer];
    [session.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [session POST:URLString parameters:parametes progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)CMGetWithURL:(NSString *)URLString
          parameters:(id)parametes
              sucess:(void(^)(id responseObject))success
             failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session GET:URLString parameters:parametes progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

//+ (NSString *)getAccessToken {
//    return [UserData getAccessToken];
//}

@end
