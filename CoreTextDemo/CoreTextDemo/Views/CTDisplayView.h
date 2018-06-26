//
//  CTDisplayView.h
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextData.h"
//点击图片通知
extern NSString *const CTDisplayViewImagePressedNotification;
//点击链接通知
extern NSString *const CTDisplayViewLinkPressedNotification;

@interface CTDisplayView : UIView

/**
 绘制需要的全部数据封装在CoreTextData中
 */
@property (strong, nonatomic) CoreTextData * data;

@end
