//
//  NSWindowController+Swizzle.h
//  
//
//  Created by Zhu Shengqi on 2023/2/15.
//

@import Foundation;

#if TARGET_OS_OSX

@import AppKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSWindowController (Swizzle)

@end

NS_ASSUME_NONNULL_END

#endif
