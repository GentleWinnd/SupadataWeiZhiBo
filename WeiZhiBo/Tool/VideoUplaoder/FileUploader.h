//
//  FileUploader.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/7.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileUploaderDelegate <NSObject>

- (void)fileUploadingState:(BOOL) state fileName:(NSString *)fileName;

@end

@interface FileUploader : NSObject

@property (assign, nonatomic) id<FileUploaderDelegate>delegate;

+ (instancetype)shareFileUploader;

- (void)uploadFileAtPath:(NSString *)path;

@end
