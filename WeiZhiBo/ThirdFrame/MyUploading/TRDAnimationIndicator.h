//
//  TRDAnimationIndicator.h
//  KTMExpertCheck
//
//  Created by Jarvan on 15/9/21.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRDAnimationIndicator;

@protocol TRDAnimationIndicatorDelegate <NSObject>

- (void)reloadDataWithAnimationView:(TRDAnimationIndicator *)Indicator;

@end

@interface TRDAnimationIndicator : UIView

@property (nonatomic, assign) id<TRDAnimationIndicatorDelegate>delegate;

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * Infolabel;


// use this to init
- (id)initWithFrame:(CGRect)frame;
- (void)setLoadText:(NSString *)text;

- (void)startAnimation;
- (void)stopAnimation;
- (void)stopAnimationWithLoadText:(NSString *)text withType:(BOOL)type;

@end
