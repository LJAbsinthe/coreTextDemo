//
//  CoreTextData.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "CoreTextData.h"
#import "CoreTextImageData.h"

@implementation CoreTextData
// CTFrameRef 属于CoreText框架，需要自己手动管理内存。ARC机制在此不在适用，所以需要重写Settter
- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self fillImagePosition];
}

// 计算所有图片的位置和尺寸
- (void)fillImagePosition {
    if (self.imageArray.count == 0) {
        return;
    }
    //获取所有CTLine对象
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSUInteger lineCount = [lines count];
    // 每个CTLine对应的origin
    CGPoint lineOrigins[lineCount];
    // 获取所有origin，第二个参数传入文本的范围，CFRangeMake(0, 0)代表整个CTFrame的范围
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    int imgIndex = 0;
    CoreTextImageData * imageData = self.imageArray[0];
    
    for (int i = 0; i < lineCount; ++i) {
        if (imageData == nil) {
            break;
        }
        // 当前第 i个 CTLine
        CTLineRef line = (__bridge CTLineRef)lines[i];
        // 获取line当中所有的CTRun对象
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        //遍历所有的CTRun对象
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            // 获取当前CTRun对象的Attributes
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            // 获取当前CTRun的代理 （因为代理方法中传入了我们需要的图片位置字典）
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                //判断代理是否存在，不存在则说明当前CTRun不是图片，继续循环查找下一个，存在则继续获取CTRun的各属性值
                continue;
            }
            //metDic为CTFrameParser类中解析图片时传入代理的参数
            NSDictionary * metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            //CTRunGetTypographicBounds:获取CTRun的参数，第二个Range传入CFRangeMake(0, 0)表示整个CTRun
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            //CTRun的高度则为上行高度 + 下行高度，各常用属性详解参考文章
            runBounds.size.height = ascent + descent;
            //CTLineGetOffsetForStringIndex 获取特定Index处字符的偏移量
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            // CTRun（图片）的横坐标位置为 基础原点(Origin)的x + 偏移量
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            //纵坐标为基础原点(Origin)的y值 - 下行高度 （目的是保证图片底部和文字的最底部对齐。也可以不减去descent，此时图片的底部和文字的基线(baseline) 对齐）
            runBounds.origin.y -= descent;
            // 获取当前CTFrame的路径
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            //获取路径的尺寸
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            //相对父视图进行偏移，获取图片相对坐标系的位置
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            imageData.imagePosition = delegateBounds;
            imgIndex++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            } else {
                imageData = self.imageArray[imgIndex];
            }
        }
    }
}

@end
