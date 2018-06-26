//
//  ViewController.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "ViewController.h"
#import "CTDisplayView.h"
#import "CTFrameParserConfig.h"
#import "UIViewExt.h"
#import "CoreTextData.h"
#import "CTFrameParser.h"
#import "ImageViewController.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"
#import "WebContentViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CTDisplayView *ctView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUserInterface];
    [self setupNotifications];
    
}

//注册图片点击和链接点击通知
- (void)setupNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePressed:)
                                                 name:CTDisplayViewImagePressedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkPressed:)
                                                 name:CTDisplayViewLinkPressedNotification object:nil];
    
}

- (void)setupUserInterface {
    //CoreText文本全局配置信息
    CTFrameParserConfig *config = [[CTFrameParserConfig alloc] init];
    config.width = self.ctView.ql_width;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    //解析json文件，获取绘制文本所需要的CoreTextData数据
    CoreTextData *data = [CTFrameParser parseTemplateFile:path config:config];
    self.ctView.data = data;
    self.ctView.ql_height = data.height;
    self.ctView.backgroundColor = [UIColor whiteColor];
}
//图片点击事件
- (void)imagePressed:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    CoreTextImageData *imageData = userInfo[@"imageData"];
    
    ImageViewController *vc = [[ImageViewController alloc] init];
    vc.image = [UIImage imageNamed:imageData.name];
    [self presentViewController:vc animated:YES completion:nil];
}
//链接点击事件
- (void)linkPressed:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    CoreTextLinkData *linkData = userInfo[@"linkData"];
    
    WebContentViewController *vc = [[WebContentViewController alloc] init];
    vc.urlTitle = linkData.title;
    vc.url = linkData.url;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
