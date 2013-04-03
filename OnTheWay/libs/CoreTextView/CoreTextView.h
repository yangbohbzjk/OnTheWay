//
//  CoreTextView.h
//  CoreText
//
//  Created by liangliang on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CoreTextView : UIView{
    
    CTFramesetterRef framesetter;
}

- (id)initWithString:(NSString *)contentString textColor:(UIColor *)color width:(float)textWidth;

@end
