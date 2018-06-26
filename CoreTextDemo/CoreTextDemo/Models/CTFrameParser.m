//
//  CTFrameParser.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "CTFrameParser.h"
#import "CoreTextData.h"
#import "CTFrameParserConfig.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"

@implementation CTFrameParser

// CTRun代理方法，获取当前run的上行高度
static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

// CTRun代理方法，获取当前run的下行高度
static CGFloat descentCallback(void *ref){
    return 0;
}

// CTRun代理方法，获取当前run的宽度
static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}
//全局配置
+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    //创建字体 包括字形和大小
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    //行高
    CGFloat lineSpacing = config.lineSpace;
    //段落属性
    const CFIndex kNumberOfSettings = 3;
    //创建段落属性的结构体数组 具体的段落属性值参考苹果官方文档
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    //创建段落属性
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    //属性放入字典
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    //内存管理
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

// 对外接口，传入json文件路径和全局配置，返回绘制需要的CoreTextData对象
+ (CoreTextData *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig*)config {
    //存放图片CoreTextImageData
    NSMutableArray *imageArray = [NSMutableArray array];
    //存放链接CoreTextImageData
    NSMutableArray *linkArray = [NSMutableArray array];
    //解析json文件，获取绘制需要的AttributedString
    NSAttributedString *content = [self loadTemplateFile:path config:config
                                              imageArray:imageArray linkArray:linkArray];
    //根据AttributedString来创建CoreTextData
    CoreTextData *data = [self parseAttributedContent:content config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;
}

//解析json文件，获取绘制需要的AttributedString
+ (NSAttributedString *)loadTemplateFile:(NSString *)path
                                  config:(CTFrameParserConfig*)config
                              imageArray:(NSMutableArray *)imageArray
                               linkArray:(NSMutableArray *)linkArray {
    //json解析
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    //纯文本的处理
                    //此方法作用：1、内部首先会调用attributesWithConfig增加全局属性 2、根据解析结果给对应的文本增加Attribute
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                                   config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"img"]) {
                    //图片
                    // 创建 CoreTextImageData用于存放图片属性
                    CoreTextImageData *imageData = [[CoreTextImageData alloc] init];
                    imageData.name = dict[@"name"];
                    //result的长度即为图片的range.location
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    // 创建空白占位符，并且设置它的CTRunDelegate信息. 对于图片的排版，其实 CoreText 本质上不是直接支持的，但是，我们可以在要显示文本的地方，用一个特殊的空白字符代替，同时设置该字体的CTRunDelegate信息为要显示的图片的宽度和高度信息，这样最后生成的CTFrame实例，就会在绘制时将图片的位置预留出来。
                    //因为我们的CTDisplayView的绘制代码是在drawRect里面的，所以我们可以方便地把需要绘制的图片，用CGContextDrawImage方法直接绘制出来就可以了。
                    //此处最终的返回字符串为与需要绘制图片同等大小的占位符（空白字符）
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"link"]) {
                    //链接处理
                    //链接开始位置的index为拼接之前的长度
                    NSUInteger startPos = result.length;
                    //同纯文本处理方式
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                                   config:config];
                    [result appendAttributedString:as];
                    // 创建 CoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    //计算出链接在整个文本中的Range保存到linkData中，目的是方便判断点击位置是否在链接的范围内，在的话则跳转对应的链接。
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

//解析图片数据，设置CTRun的代理。（图文混排核心内容）
+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                                config:(CTFrameParserConfig*)config {
    //结构体类型，其中包含了CTRun的所有回调函数
    CTRunDelegateCallbacks callbacks;
    //给结构体分配内存空间
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    //文档解释为 This field should always be set to kCTRunDelegateCurrentVersion. 传入kCTRunDelegateVersion1即可 （kCTRunDelegateCurrentVersion = kCTRunDelegateVersion1）
    callbacks.version = kCTRunDelegateVersion1;
    //设置获取文字上行高度的回调方法
    callbacks.getAscent = ascentCallback;
    //设置获取文字下行高度的回调方法
    callbacks.getDescent = descentCallback;
    //设置获取文字宽度的回调方法
    callbacks.getWidth = widthCallback;
    //创建代理，传入回调方法结构体。第二个参数可以随便填写我们需要传入的数据，注意类型为void *
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    //给字符添加全局属性
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    //设置代理
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    //内存管理
    CFRelease(delegate);
    return space;
}

//解析原始数据，返回AttributedString
+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                        config:(CTFrameParserConfig*)config {
    //增加全局属性
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    // 以下为增加自定义属性
    
    //根据字典的key值返回对应的颜色
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    // 设置字体大小
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        //创建字体对象，包含了字形和字体大小
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    //返回经过自定义需要局部处理的字符串
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}
//根据字典的key值返回对应的颜色
+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return nil;
    }
}

// 根据之前解析出来的AttributedString创建绘制所需要的CoreTextData
+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig*)config {
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    //第二个参数表示文本范围，CFRangeMake(0,0)代表整个文本
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的CTFrameRef实例和计算好的缓制高度保存到CoreTextData实例中，最后返回CoreTextData实例
    CoreTextData *data = [[CoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    data.content = content;
    
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

//创建CTFrameRef实例
+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(CTFrameParserConfig *)config
                                  height:(CGFloat)height {
    //画布的路径（轮廓或者范围）
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    //最终生成绘制需要的frame，第二个参数表示文本范围，CFRangeMake(0,0)代表整个文本，最后一个参数为开发者自定义额外的属性，不需要填NULL即可。
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end
