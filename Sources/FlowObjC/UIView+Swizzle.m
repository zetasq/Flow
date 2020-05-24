//
//  UIView+Swizzle.m
//  
//
//  Created by Zhu Shengqi on 2019/12/5.
//

#import "UIView+Swizzle.h"

@import ConcreteObjC;

@implementation UIView (Swizzle)

static NSMutableArray<void (^)(UIView *)> *sViewDidMoveToWindowHandlers;

+ (void)load
{
  SwizzleInstanceMethod(self, @selector(didMoveToWindow), @selector(flow_swizzled_didMoveToWindow));
}

- (void)flow_swizzled_didMoveToWindow
{
  [self flow_swizzled_didMoveToWindow];
  
  foreach(handler, sViewDidMoveToWindowHandlers) {
    handler(self);
  }
}

+ (void)flow_addViewDidMoveToWindowHandler:(void (^)(UIView *))handler
{
  if (sViewDidMoveToWindowHandlers == nil) {
    sViewDidMoveToWindowHandlers = [NSMutableArray array];
  }
  
  [sViewDidMoveToWindowHandlers addObject:handler];
}

@end

@interface UIResponder (Test)

@end

@implementation UIResponder (Test)


+ (void)load
{
  SwizzleInstanceMethod(self, @selector(canPerformAction:withSender:), @selector(swizzled_canPerformAction:withSender:));
}
- (BOOL)swizzled_canPerformAction:(SEL)action withSender:(id)sender
{
  return [self swizzled_canPerformAction:action withSender:sender];
}
@end
