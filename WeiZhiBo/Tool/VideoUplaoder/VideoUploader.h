//
//  VideoUploader.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/24.
//  Copyright © 2017年 YH. All rights reserved.
//
static NSString *VIDEO_ID = @"videoId";
static NSString *UPLOAD_STATE = @"uploadState";
static NSString *VIDEO_PATH = @"videoPath";
static NSString *UPLOAD_URL = @"uploadUrl";

#import <Foundation/Foundation.h>

@interface VideoUploader : NSObject

@property (copy, nonatomic) void (^uploadProgress)(NSProgress *progress, NSDictionary *videoInfo);

@property (copy, nonatomic) void (^uploadResult)(BOOL result, NSDictionary *videoInfo);

+ (instancetype)shareUploader;
- (BOOL)uploadingOfVideo:(NSDictionary *)videoInfo;
- (void)uploadVideoWithVIdeoInfo:(NSDictionary *)videoInfo;
- (void)getUploadShortVideoUrlWithParamater:(NSDictionary *)parameter withVideoInfo:(NSDictionary *)videoInfo;
@end
