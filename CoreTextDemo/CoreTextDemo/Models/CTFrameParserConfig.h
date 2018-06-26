//
//  CTFrameParserConfig.h
//  CoreTextDemo
//  
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTFrameParserConfig : NSObject
/**
 颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 宽度
 */
@property (nonatomic, assign) CGFloat width;

/**
 字号
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 行高
 */
@property (nonatomic, assign) CGFloat lineSpace;


@end
