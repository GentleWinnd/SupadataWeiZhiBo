//
//  Xib.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/21.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "XibWKWebView.h"

@implementation XibWKWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder {
    // An initial frame for initialization must be set, but it will be overridden
    // below by the autolayout constraints set in interface builder.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    //    window.webkit.messageHandlers.Supadata.postMessage({body:'schoolId'})
    config.preferences.minimumFontSize = 0;
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);document.cookie = 'fromapp=ios';document.cookie = 'channel=appstore';";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController addUserScript:wkUScript];
    
    // Set any configuration parameters here, e.g.
    // myConfiguration.dataDetectorTypes = WKDataDetectorTypeAll;
    
    self = [super initWithFrame:self.bounds configuration:config];
    
    // Apply constraints from interface builder.
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


@end
