//
//  UIView+Swizzle.h
//  
//
//  Created by Zhu Shengqi on 2019/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Swizzle)

+ (void)flow_addViewDidMoveToWindowHandler:(void (^)(UIView *))handler
NS_SWIFT_NAME(flow_addViewDidMoveToWindowHandler(_:));

@end

NS_ASSUME_NONNULL_END

