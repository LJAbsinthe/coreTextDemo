//
//  CoreTextUtils.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "CoreTextUtils.h"

@implementation CoreTextUtils

// 检测点击位置是否在链接上
+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data {
    //将点击的位置转换成字符串的偏移量
    CFIndex idx = [self touchContentOffsetInView:view atPoint:point data:data];
    if (idx == -1) {
        //不在文本上
        return nil;
    }
    //如果能找到点击处的index，则执行对link的遍历，查看index是否在link的Range范围之内
    CoreTextLinkData * foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
    return foundLink;
}

// 将点击的位置转换成字符串的偏移量，如果没有找到，则返回-1
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data {
    //获取当前的CTFrameRef实例
    CTFrameRef textFrame = data.ctFrame;
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    //获取总共的行数
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        //如果点击处在当前行的范围之内
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移，这里特别注意，第二个参数是相对当前行的坐标，不是相对整个frame坐标，故需要之前的转换
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}

//获取当前行的位置和尺寸，注意这里的返回的坐标都是CoreText坐标，和UIKit的坐标系不同
+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    //后面三个参数分别为上行高度、下行高度、行间距的地址
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}
//遍历linkArray，查看点击处是否在link的Range范围之内
+ (CoreTextLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray {
    CoreTextLinkData *link = nil;
    for (CoreTextLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            //找到之后直接跳出循环，没有则返回空
            break;
        }
    }
    return link;
}

@end
