//
//  ImageViewController.m
//  CoreTextDemo
//
//  Created by LJ on 2018/5/10.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import "ImageViewController.h"
#import "UIViewExt.h"
@interface ImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    [self adjustImageView];}

- (void)adjustImageView {
    CGPoint center = self.imageView.center;
    CGFloat height = self.image.size.height * self.image.size.width / self.imageView.ql_width;
    self.imageView.ql_height = height;
    self.imageView.center = center;
}

- (IBAction)close:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
