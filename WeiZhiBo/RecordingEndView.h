//
//  RecordingEndView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

typedef NS_ENUM(NSInteger, EndViewBtnType) {
    EndViewBtnTypeUpload = 1,
    EndViewBtnTypeRemove,
    EndViewBtnTypeBack,

};

#import <UIKit/UIKit.h>

@interface RecordingEndView : UIView

@property (strong, nonatomic) IBOutlet UIButton *uploadBtn;

@property (strong, nonatomic) IBOutlet UIButton *reomveBtn;

@property (strong, nonatomic) IBOutlet UIButton *backRecoderBtn;


@property (copy, nonatomic) void(^endViewBtnBlock)(EndViewBtnType type);

@end
