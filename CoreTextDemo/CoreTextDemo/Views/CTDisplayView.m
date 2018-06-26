//
//  CTDisplayView.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "CTDisplayView.h"
#import "CoreTextImageData.h"
#import "CoreTextUtils.h"

NSString *const CTDisplayViewImagePressedNotification = @"CTDisplayViewImagePressedNotification";

NSString *const CTDisplayViewLinkPressedNotification = @"CTDisplayViewLinkPressedNotification";

@implementation CTDisplayView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupEvents];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.data == nil) {
        return;
    }
    //因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    //翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
    //设置文本不进行变换
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    //向下平移整个画布单位
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //对平移后的画布进行翻转
    CGContextScaleCTM(context, 1.0, -1.0);
    //绘制
    CTFrameDraw(self.data.ctFrame, context);
    //绘制所有图片到占位符处
    for (CoreTextImageData * imageData in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
}

//添加点击手势
- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}

//点击View时调用
- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    //获取点击处的位置
    CGPoint point = [recognizer locationInView:self];
    //遍历imageArray，判断点击处是否在图片的Rect范围之内
    for (CoreTextImageData * imageData in self.data.imageArray) {
        // 翻转坐标系，因为imageData中的坐标是CoreText的坐标系
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        //此处为计算在UIKit坐标系中图片原点的纵坐标，比较抽象，可画图理解下
        imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
        //这个Rect是CoreText坐标转换后的UIKit坐标
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        // 检测点击位置 Point 是否在rect之内
        if (CGRectContainsPoint(rect, point)) {
            NSLog(@"hit image");
            // 在这里处理点击后的逻辑
            NSDictionary *userInfo = @{ @"imageData": imageData };
            [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewImagePressedNotification
                                                                object:self userInfo:userInfo];
            return;
        }
    }
    //代码到此处说明点击处不在图片上，下一步检查是否在链接上
    //返回为空的话说明不在，这里不进行处理点击事件，有返回值则发送通知消息给Controller，执行跳转操作
    CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    if (linkData) {
         NSDictionary *userInfo = @{ @"linkData": linkData };
        [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewLinkPressedNotification
                                                            object:self userInfo:userInfo];
        return;
    }
}

@end
