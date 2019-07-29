//
//  UIViewController+Swizzle.h
//  
//
//  Created by Zhu Shengqi on 29/7/2019.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, ViewControllerAppearState) {
  ViewControllerAppearStateInitial = 0,
  ViewControllerAppearStateWillAppear,
  ViewControllerAppearStateDidAppear,
  ViewControllerAppearStateWillDisappear,
  ViewControllerAppearStateDidDisappear
};

@interface UIViewController (Swizzle)

@property (nonatomic, assign, readonly) ViewControllerAppearState appearState;

@end

NS_ASSUME_NONNULL_END
