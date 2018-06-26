//
//  CTFrameParserConfig.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "CTFrameParserConfig.h"
#import "UIColor+Extend.h"

@implementation CTFrameParserConfig

- (id)init {
    self = [super init];
    if (self) {
        _width = 200.0f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = [UIColor colorFromHexRGB:@"333333"];
    }
    return self;
}
@end
