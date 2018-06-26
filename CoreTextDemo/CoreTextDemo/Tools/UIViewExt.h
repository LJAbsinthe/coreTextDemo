/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (ViewFrameGeometry)
@property CGPoint ql_origin;
@property CGSize ql_size;

@property (readonly) CGPoint ql_bottomLeft;
@property (readonly) CGPoint ql_bottomRight;
@property (readonly) CGPoint ql_topRight;

@property CGFloat ql_height;
@property CGFloat ql_width;

@property CGFloat ql_top;
@property CGFloat ql_left;

@property CGFloat ql_bottom;
@property CGFloat ql_right;
@property CGFloat ql_centerX;
@property CGFloat ql_centerY;

- (void)ql_moveBy:(CGPoint) delta;
- (void)ql_scaleBy:(CGFloat) scaleFactor;
- (void)ql_fitInSize:(CGSize) aSize;
@end
