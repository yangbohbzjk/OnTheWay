//
//  CoreTextView.m
//  CoreText
//
//  Created by liangliang on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CoreTextView.h"
#include <CoreText/CoreText.h>

@implementation CoreTextView

- (id)initWithString:(NSString *)contentString textColor:(UIColor *)color width:(float)textWidth
{
    self = [super init];
    if (self) {
        // Initialization code
        //创建要输出的字符串f
        self.backgroundColor = [UIColor clearColor];
        if (!contentString) {
            contentString = @"  ";
        }
        //按换行符分隔
        NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
        NSArray *arr_str = [contentString componentsSeparatedByCharactersInSet:newline];
        NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];   //非空
        NSArray *filteredArray = [arr_str filteredArrayUsingPredicate:noEmptyStrings];  

        NSString *resultString = @"";
        for (int i = 0 ; i < [filteredArray count]; i++)
        {
            NSString *str = [filteredArray objectAtIndex:i];
            if ([str length] > 2) {
                //去除空格符
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                resultString = [resultString stringByAppendingString:[NSString stringWithFormat:@"%@\n",str]];
            }
        }
        
        CTFontRef helvetica = CTFontCreateWithName(CFSTR("Helvetica"), 14.0, NULL);
        NSNumber *underline = [NSNumber numberWithInt:kCTUnderlineStyleNone];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)helvetica, (id)kCTFontAttributeName,
                                    underline, (id)kCTUnderlineStyleAttributeName, nil];
        //创建AttributeString
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                             initWithString:resultString attributes:attributes];
        //创建文本对齐方式
        CTTextAlignment alignment = kCTTextAlignmentJustified;//这种对齐方式会自动调整，使左右始终对齐
        CTParagraphStyleSetting alignmentStyle;
        alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
        alignmentStyle.valueSize=sizeof(alignment);
        alignmentStyle.value=&alignment;
        
        [string addAttribute:(id)kCTForegroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(0, [string length])];
        
        //创建文本行间距
        CGFloat lineSpace= 5.0f;//间距数据
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;//指定为行间距属性
        lineSpaceStyle.valueSize=sizeof(lineSpace);//内存容量度量函数
        lineSpaceStyle.value=&lineSpace;
        
        //设置文本段间距
        
        CGFloat paragraphSpacing = 10.0;
        CTParagraphStyleSetting paragraphSpaceStyle;
        paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
        paragraphSpaceStyle.valueSize = sizeof(CGFloat);
        paragraphSpaceStyle.value = &paragraphSpacing;
        
        //段落第一行开头
        CGFloat headIndent = 28.0;
        CTParagraphStyleSetting paragraphHeadIndent;
        paragraphHeadIndent.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
        paragraphHeadIndent.valueSize = sizeof(headIndent);
        paragraphHeadIndent.value = &headIndent;
        
        //创建样式数组
        CTParagraphStyleSetting settings[]={
            alignmentStyle,lineSpaceStyle,paragraphSpaceStyle,paragraphHeadIndent
        };
        
        //设置样式
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        
        //给字符串添加样式attribute
        [string addAttribute:(id)kCTParagraphStyleAttributeName
                       value:(id)paragraphStyle
                       range:NSMakeRange(0, [string length])];
        
        // layout master
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
        //计算文本绘制size
        CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(textWidth, 500 * 20), NULL);
        //创建textBoxSize以设置view的frame
        CGSize textBoxSize = CGSizeMake((int)tmpSize.width + 6, (int)tmpSize.height + 10);
        self.frame = CGRectMake(6, 0, textBoxSize.width , textBoxSize.height);
        [string release];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    CGPathAddRect(leftColumnPath, NULL,
                  CGRectMake(0, 0,
                             self.bounds.size.width,
                             self.bounds.size.height));
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0),
                                                    leftColumnPath, NULL);
    
    // flip the coordinate system
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // draw
    CTFrameDraw(leftFrame, context);
    
//    // log the base-line distances
//	NSArray *lines = (NSArray *)CTFrameGetLines(leftFrame);
//	CGPoint *origins = calloc([lines count], sizeof(CGPoint));
//	
//	CTFrameGetLineOrigins(leftFrame, CFRangeMake(0, 0), origins);
//	
//	for (NSInteger i=1; i<[lines count]; i++)
//	{
//		CGFloat distance = origins[i].y - origins[i-1].y;
//		NSLog(@"Line %d: %f", i, distance);
//	}
    // cleanup
    
    CGPathRelease(leftColumnPath);
    CFRelease(framesetter);
    //CFRelease(helvetica);
    // CFRelease(helveticaBold);
    
    UIGraphicsPushContext(context);
}


@end
