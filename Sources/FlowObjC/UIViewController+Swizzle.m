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
  
  self.appearanceState = ViewControllerAppearanceStateWillAppear;
}

- (void)_flow_swizzled_viewDidAppear:(BOOL)animated
{
  [self _flow_swizzled_viewDidAppear:animated];
  
  self.appearanceState = ViewControllerAppearanceStateDidAppear;
}

- (void)_flow_swizzled_viewWillDisappear:(BOOL)animated
{
  [self _flow_swizzled_viewWillDisappear:animated];
  
  self.appearanceState = ViewControllerAppearanceStateWillDisappear;
}

- (void)_flow_swizzled_viewDidDisappear:(BOOL)animated
{
  [self _flow_swizzled_viewDidDisappear:animated];
  
  self.appearanceState = ViewControllerAppearanceStateDidDisappear;
}

- (ViewControllerAppearanceState)appearanceState
{
  let number = (NSNumber *)objc_getAssociatedObject(self, @selector(appearanceState));

  return number.unsignedIntegerValue;
}

- (void)setAppearanceState:(ViewControllerAppearanceState)appearanceState
{
  let number = @(appearanceState);
  
  objc_setAssociatedObject(self, @selector(appearanceState), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
