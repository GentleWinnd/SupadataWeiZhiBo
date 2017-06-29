//
//  SaveDataManager.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/26.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveDataManager : NSObject


/**
 创建一个单例

 @return 创建单例
 */
+ (instancetype)shareSaveRecoder;

/**
 保存视频录播班级信息

 @param videoId 班级信息
 */
- (void)saveRecoderVodeoClass:(NSArray *)classArr withVideoId:(NSString *)videoId;
- (void)saveRecoderTitle:(NSString *)title withVideoId:(NSString *)videoId;
- (void)saveRecoderUploadState:(BOOL )state withVideoId:(NSString *)videoId;
/**
 获取录播视频对应的班级信息

 @param videoId 根据classID获取班级信息
 @return 获取的班级信息
 */
- (NSArray *)getVideoClassesWithVideoId:(NSString *)videoId;
- (NSString *)getRecoderTitleWithVideoId:(NSString *)videoId;
- (BOOL)getRecoderUploadStateWithVideoId:(NSString *)videoId;

/**
  删除视频对应的班级信息

 @param videoId 视频对应的classID
 */
- (void)removeRecoderVideoWithVideoId:(NSString *)videoId;

@end
