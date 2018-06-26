//
//  CoreTextUtils.h
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextLinkData.h"
#import "CoreTextData.h"

@interface CoreTextUtils : NSObject

/**
 获取点击处CoreTextLinkData，如果点击的不是链接，返回空

 @param view 当前点击所在的View
 @param point 点击位置
 @param data 当前文本信息
 @return 获取点击处CoreTextLinkData，如果点击的不是链接，返回空
 */
+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

/**
 @param view 点击所在View
 @param point 点击位置
 @param data 当前文本信息
 @return 点击字符处的index
 */
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

@end
