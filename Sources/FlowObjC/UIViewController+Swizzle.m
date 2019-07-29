//
//  UIViewController+Swizzle.m
//  
//
//  Created by Zhu Shengqi on 29/7/2019.
//

#import "UIViewController+Swizzle.h"
#import <objc/runtime.h>

@import ConcreteObjC;

@implementation UIViewController (Swizzle)

+ (void)load
{
  SwizzleInstanceMethod(self, @selector(viewWillAppear:), @selector(_flow_swizzled_viewWillAppear:));
  SwizzleInstanceMethod(self, @selector(viewDidAppear:), @selector(_flow_swizzled_viewDidAppear:));
  SwizzleInstanceMethod(self, @selector(viewWillDisappear:), @selector(_flow_swizzled_viewWillDisappear:));
  SwizzleInstanceMethod(self, @selector(viewDidDisappear:), @selector(_flow_swizzled_viewDidDisappear:));
}

- (void)_flow_swizzled_viewWillAppear:(BOOL)animated
{
  [self _flow_swizzled_viewWillAppear:animated];
  
  self.appearState = ViewControllerAppearStateWillAppear;
}

- (void)_flow_swizzled_viewDidAppear:(BOOL)animated
{
  [self _flow_swizzled_viewDidAppear:animated];
  
  self.appearState = ViewControllerAppearStateDidAppear;
}

- (void)_flow_swizzled_viewWillDisappear:(BOOL)animated
{
  [self _flow_swizzled_viewWillDisappear:animated];
  
  self.appearState = ViewControllerAppearStateWillDisappear;
}

- (void)_flow_swizzled_viewDidDisappear:(BOOL)animated
{
  [self _flow_swizzled_viewDidDisappear:animated];
  
  self.appearState = ViewControllerAppearStateDidDisappear;
}

- (ViewControllerAppearState)appearState
{
  let number = DynamicCast(objc_getAssociatedObject(self, @selector(appearState)), NSNumber);
  
  return number.unsignedIntegerValue;
}

- (void)setAppearState:(ViewControllerAppearState)appearState
{
  let number = @(appearState);
  
  objc_setAssociatedObject(self, @selector(appearState), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
