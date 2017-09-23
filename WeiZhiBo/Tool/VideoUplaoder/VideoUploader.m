//
//  VideoUploader.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/24.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "VideoUploader.h"

@interface VideoUploader()
@property (nonatomic, strong) NSMutableArray *uploadingArr;
@property (nonatomic, assign) NSInteger maxCount;

@end

static VideoUploader *uploader;
@implementation VideoUploader

+ (instancetype)shareUploader {

      return [[self alloc] init];
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        uploader = [super allocWithZone:zone];
    });

    return uploader;
}

- (id)copyWithZone:(NSZone *)zone {
    return uploader;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return uploader;
}

- (NSMutableArray *)uploadingArr {
    
    if (!_uploadingArr) {
        _uploadingArr = [NSMutableArray arrayWithCapacity:5];
    }
    return _uploadingArr;
}


- (void)getUploadShortVideoUrlWithParamater:(NSDictionary *)parameter withVideoInfo:(NSDictionary *)videoInfo {//获取视频的上传路径
    
    if (self.uploadingArr.count == 5) {
        [Progress progressShowcontent:@"同时最多只能上传五个视频"];
        return;
    }
    NSString *videoPath = videoInfo[VIDEO_PATH];

    
    [WZBNetServiceAPI getShortVideoUplaodPathWithParameters:parameter success:^(id reponseObject) {
            if ([reponseObject[@"status"] integerValue] == 1) {
                NSString *videoId = [NSString safeString:reponseObject[@"data"][@"vodId"]];
                NSString *url = [NSString safeString:reponseObject[@"data"][@"uploadUrl"]];
                
                if (url.length>0) {
                    NSDictionary *videoDic = @{VIDEO_ID:videoId,
                                                VIDEO_PATH:videoPath,
                                                UPLOAD_URL:url,
                                                UPLOAD_STATE:[NSNumber numberWithBool:NO]};
                    [self.uploadingArr addObject:videoDic];
                    [self uploadVideoWithVIdeoInfo:videoDic];
                } else {
                    [Progress progressShowcontent:@"视频上传失败，请稍后重试"];
                }
            } else {
                if (self.uploadResult) {
                    self.uploadResult(NO, videoInfo);
                }
                [Progress progressShowcontent:reponseObject[@"message"]];
            }
            
        } failure:^(NSError *error) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            self.uploadResult(NO, videoInfo);
            [KTMErrorHint showNetError:error inView:window];
        }];
        
}


- (BOOL)uploadingOfVideo:(NSDictionary *)videoInfo {
    NSString *videoPath = videoInfo[VIDEO_PATH];
    
    for (NSDictionary *videoDic in self.uploadingArr) {
        if ([videoDic[VIDEO_PATH] isEqualToString:videoPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)uploadVideoWithVIdeoInfo:(NSDictionary *)videoInfo  {
    
    
    NSString *videoPath = videoInfo[VIDEO_PATH];
    NSData *data = [NSData dataWithContentsOfFile:videoPath];
    NSString *fileStr = [videoPath lastPathComponent];
    NSString *url = videoInfo[UPLOAD_URL];
    
    [WZBNetServiceAPI postUploadFileWithURL:url paramater:nil fileData:data nameOfData:@"test" nameOfFile:fileStr mimeOfType:@"video/mp4" progress:^(NSProgress *uploadProgress) {
        if (self.uploadProgress) {
            self.uploadProgress(uploadProgress,videoInfo);
        }
        
    } sucess:^(id responseObject) {
        //        NSLog(@"_________uploaded success______/n %@",responseObject);
       
        if (self.uploadResult) {
            self.uploadResult(YES, videoInfo);
        }
        NSArray *uploadArr = [self.uploadingArr mutableCopy];
        for (NSDictionary *videoInfo in uploadArr) {
            if ([videoInfo[VIDEO_PATH] isEqualToString:videoPath]) {
                [self.uploadingArr removeObject:videoInfo];
                break;
            }
        }

    } failure:^(NSError *error) {
        //        NSLog(@"_________uploaded filad______ /n  %@",[error description]);
        if (self.uploadResult) {
            self.uploadResult(NO, videoInfo);
        }
        NSArray *uploadArr = [self.uploadingArr mutableCopy];
        for (NSDictionary *videoInfo in uploadArr) {
            if ([videoInfo[VIDEO_PATH] isEqualToString:videoPath]) {
                [self.uploadingArr removeObject:videoInfo];
                break;
            }
        }
    }];
    //    [self upload:url filename:@"video" mimeType:@"video/mp4" data:data filePath:filePath];
}

@end
