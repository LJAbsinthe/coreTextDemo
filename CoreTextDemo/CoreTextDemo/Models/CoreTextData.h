//
//  CoreTextData.h
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFrameParserConfig.h"
#import <CoreText/CoreText.h>

@interface CoreTextData : NSObject
//绘制需要的CTFrameRef实例
@property (assign, nonatomic) CTFrameRef ctFrame;
//高度
@property (assign, nonatomic) CGFloat height;
//图片信息
@property (strong, nonatomic) NSArray * imageArray;
//链接信息
@property (strong, nonatomic) NSArray * linkArray;
//文本
@property (strong, nonatomic) NSAttributedString *content;

@end
