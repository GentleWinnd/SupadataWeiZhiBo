//
//  reloadView.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/30.
//  Copyright © 2017年 YH. All rights reserved.
//

typedef NS_ENUM(NSInteger , LoadFailStatu) {

    LoadFailStatuNet,
    LoadFailStatuData,
    LoadFailStatuNoData
};

#import <UIKit/UIKit.h>


@interface ReloadView : UIView

@property (nonatomic, assign) LoadFailStatu loadState;
@property (nonatomic, copy) void (^ reloadView)();
@property (strong, nonatomic) IBOutlet UIImageView *loadImageView;



@end
