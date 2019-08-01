//
//  UIViewController+Swizzle.h
//  
//
//  Created by Zhu Shengqi on 29/7/2019.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, ViewControllerAppearanceState) {
  ViewControllerAppearanceStateInitial = 0,
  ViewControllerAppearanceStateWillAppear,
  ViewControllerAppearanceStateDidAppear,
  ViewControllerAppearanceStateWillDisappear,
  ViewControllerAppearanceStateDidDisappear
};

@interface UIViewController (Swizzle)

@property (nonatomic, assign) ViewControllerAppearanceState appearanceState;

@end

NS_ASSUME_NONNULL_END
