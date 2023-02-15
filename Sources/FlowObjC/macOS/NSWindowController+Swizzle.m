//
//  NSWindowController+Swizzle.m
//  
//
//  Created by Zhu Shengqi on 2023/2/15.
//


#include <TargetConditionals.h>

#if TARGET_OS_OSX

#import "NSWindowController+Swizzle.h"

@import ObjectiveC.runtime;
@import ConcreteObjC;

@implementation NSWindowController (Swizzle)

+ (void)load
{
  SwizzleInstanceMethod(self, @selector(windowDidLoad), @selector(flow_swizzled_windowDidLoad));
}

- (NSWindowController *)selfOwnedRef
{
  return objc_getAssociatedObject(self, @selector(selfOwnedRef));
}

- (void)setSelfOwnedRef:(NSWindowController *)ref
{
  objc_setAssociatedObject(self, @selector(selfOwnedRef), ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)flow_swizzled_windowDidLoad
{
  [self flow_swizzled_windowDidLoad];

  // Fix the issue that window controller as a root object will be released immediately after window is shown.
  // With this fix we will retain self when window is loaded and release self when window is closed.
  // More info in this thread: https://www.mail-archive.com/search?l=cocoa-dev@lists.apple.com&q=subject:%22Re%5C%3A+Release+a+NSWindowController+after+the+window+is+closed%22&o=newest&f=1

  self.selfOwnedRef = self;

  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(flow_windowWillClose:)
                                             name:NSWindowWillCloseNotification
                                           object:self.window];
}

- (void)flow_windowWillClose:(NSNotification *)notification
{
  self.selfOwnedRef = nil;
}

@end

#endif
