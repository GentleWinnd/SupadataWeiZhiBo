//
//  KTMWebService.h
//  KTMExpertCheck
//
//  Created by fangling on 15/8/24.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTMWebService : NSObject

+ (void)postWithURL:(NSString *)URLString
         parameters:(id)parametes
             sucess:(void(^)(id responseObject))success
            failure:(void(^)(NSError *error))failure;

+ (void)getWithURL:(NSString *)URLString
        parameters:(id)parametes
            sucess:(void(^)(id responseObject))success
           failure:(void(^)(NSError *error))failure;

+ (void)postUploadingWithURL:(NSString *)URLString
                  parameters:(id)parametes
                   imageData:(NSData *)imageData
                 nameOfimage:(NSString *)name
                    progress:(void (^) (NSProgress *uploadProgress))progress
                      sucess:(void(^)(id responseObject))success
                     failure:(void(^)(NSError *error))failure;;

+ (void)postFormWithURL:(NSString *)URLString
             parameters:(id)parametes
                 sucess:(void(^)(id responseObject))success
                failure:(void(^)(NSError *error))failure;

// 普通的post请求（没有token的情况）
+ (void)CMPostWithURL:(NSString *)URLString
               parameters:(id)parametes
                   sucess:(void(^)(id responseObject))success
                  failure:(void(^)(NSError *error))failure;
//dont need accessToken - GET
+ (void)CMGetWithURL:(NSString *)URLString
          parameters:(id)parametes
              sucess:(void(^)(id responseObject))success
             failure:(void(^)(NSError *error))failure;

// 新版本上传图片
+ (void)postUploadImageWithURL:(NSString *)URLString
                     imageData:(NSData *)imageData
                   nameOfImage:(NSString *)name
                    fileOfName:(NSString *)fileName
                    mimeOfType:(NSString *)mineType
                      progress:(void (^) (NSProgress *uploadProgress))progress
                        sucess:(void(^)(id responseObject))success
                       failure:(void(^)(NSError *error))failure;

//批量上传图片
+ (void)postUploadBatchImagesWithURL:(NSString *)URLString
                          imagesData:(NSArray *)imagesData
                         nameOfImage:(NSString *)name
                          fileOfName:(NSString *)fileName
                          mimeOfType:(NSString *)mineType
                            progress:(void (^) (NSProgress *uploadProgress))progress
                              sucess:(void(^)(id responseObject))success
                             failure:(void(^)(NSError *error))failure;

@end
