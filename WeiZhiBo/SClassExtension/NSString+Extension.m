//
//  NSString+Extension.m
//  KTMExpertCheck
//
//  Created by fangling on 15/9/9.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)safeString:(NSString *)string {
    if ([NSString isBlankString:string]) {
        return @"";
    }else{
        return string;
    }
}

+ (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    if([string isEqualToString:@"<null>"]){
        return YES;
    }
    
    return NO;
}

+ (NSString *)safeNumber:(NSNumber *)number {
    if ([NSString isBlankNumber:number]) {
        return @"";
    }
    return [number stringValue];
}

+ (BOOL)isBlankNumber:(NSNumber *)number{
    NSString *string = [NSString stringWithFormat:@"%@", number];
    
    if ([string isEqualToString:@"0"]) {
        return YES;
    }
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    if([string isEqualToString:@"<null>"]){
        return YES;
    }

    return NO;
}

- (NSString *)stringByReplaceCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string {
    NSString *result = self;
    NSRange range = [result rangeOfCharacterFromSet:characterset];
    
    while (range.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:range withString:string];
        range = [result rangeOfCharacterFromSet:characterset];
    }
    return result;
}


#pragma mark - 计算cell高度  str 字符串长度 typefaceName字体内容 typefaceSize字体大小 scopeWidth显示范围的宽  scopeHeight显示范围的高
- (NSInteger )HeightStr:(NSString *)str typefaceName:(NSString *)typefaceName typefaceSize:(NSInteger)typefaceSize scopeWidth:(NSInteger)scopeWidth scopeHeight:(NSInteger)scopeHeight {
    
    NSDictionary * dic = [NSDictionary dictionary];
    
    //1.获得要显示的文本 str
    NSString * CellStr = str;
    
    //计算高度
    if (typefaceName == nil) {
        dic = @{NSFontAttributeName:[UIFont systemFontOfSize:typefaceSize]};
    }else{
        //字体类型 大小
        dic = @{NSFontAttributeName:[UIFont fontWithName:typefaceName size:typefaceSize]};
    }
    
    //字符串的显示范围
    CGSize scope = CGSizeMake(scopeWidth, scopeHeight);
    
    CGRect rect = [CellStr boundingRectWithSize:scope options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    int cellH = rect.size.height + 20;
    
    return cellH;

}

/**
 * 计算文字高度，可以处理计算带行间距的
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.length)];
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attributeString boundingRectWithSize:size options:options context:nil];
    
    //    NSLog(@"size:%@", NSStringFromCGSize(rect.size));
    
    //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
    if ((rect.size.height - font.lineHeight) <= paragraphStyle.lineSpacing) {
        if ([self containChinese:self]) {  //如果包含中文
            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-paragraphStyle.lineSpacing);
        }
    }
    
    
    return rect.size;
}



//判断如果包含中文
- (BOOL)containChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){ int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}

/**
 *  计算最大行数文字高度,可以处理计算带行间距的
 */
- (CGFloat)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing maxLines:(NSInteger)maxLines{
    
    if (maxLines <= 0) {
        return 0;
    }
    
    CGFloat maxHeight = font.lineHeight * maxLines + lineSpacing * (maxLines - 1);
    
    CGSize orginalSize = [self boundingRectWithSize:size font:font lineSpacing:lineSpacing];
    
    if ( orginalSize.height >= maxHeight ) {
        return maxHeight;
    }else{
        return orginalSize.height;
    }
}

/**
 *  计算是否超过一行   用于给Label 赋值attribute text的时候 超过一行设置lineSpace
 */
- (BOOL)isMoreThanOneLineWithSize:(CGSize)size font:(UIFont *)font lineSpaceing:(CGFloat)lineSpacing{
    
    if ( [self boundingRectWithSize:size font:font lineSpacing:lineSpacing].height > font.lineHeight  ) {
        return YES;
    }else{
        return NO;
    }
}

@end
