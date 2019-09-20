//
//  UIView+MotionBlur.swift
//  
//
//  Created by Zhu Shengqi on 2019/9/5.
//

import Foundation
import UIKit

private func createMotionBlurImage(originalImage: UIImage, angle: CGFloat) -> CGImage {
    CIContext *context = [CIContext contextWithOptions:@{ kCIContextPriorityRequestLow : @YES }];
    CIImage *inputImage = [CIImage imageWithCGImage:snapshotImage.CGImage];
    
    let motionBlurFilter = [[DTKMotionBlurFilter alloc] init];
    [motionBlurFilter setDefaults];
    motionBlurFilter.inputAngle = @(angle);
    motionBlurFilter.inputImage = inputImage;
    
    CIImage *outputImage = motionBlurFilter.outputImage;
    CGImageRef blurredImgRef = [context createCGImage:outputImage fromRect:outputImage.extent] ;
    return blurredImgRef;
}

extension UIView {
  
  public func enableMotionBlur() {
    
  }
  
  public func disableMotionBlur() {
    
  }


  static CGFloat positionDelta(CGPoint previousPosition, CGPoint currentPosition)
  {
      const CGFloat dx = fabs(currentPosition.x - previousPosition.x);
      const CGFloat dy = fabs(currentPosition.y - previousPosition.y);
      return sqrt(pow(dx, 2) + pow(dy, 2));
  }

  static CGFloat opacityFromPositionDelta(CGFloat delta, CFTimeInterval tickDuration)
  {
      const NSInteger expectedFPS = 60;
      const CFTimeInterval expectedDuration = 1.0 / expectedFPS;
      const CGFloat normalizedDelta = delta * expectedDuration / tickDuration;
      
      // A rough approximation of an opacity for a good looking blur. The larger the delta (movement velocity), the larger opacity of the blur layer.
      const CGFloat unboundedOpacity = log2(normalizedDelta) / 5.0f;
      return (CGFloat)fmax(fmin(unboundedOpacity, 1.0), 0.0);
  }


  @implementation UIView (DTKMotionBlur)

  - (void)setDtk_motionBlurSnapshotImage:(UIImage *)dtk_motionBlurSnapshotImage
  {
      objc_setAssociatedObject(self, @selector(dtk_motionBlurSnapshotImage), dtk_motionBlurSnapshotImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  - (UIImage *)dtk_motionBlurSnapshotImage
  {
      return DTKRequiredCast(UIImage, objc_getAssociatedObject(self, @selector(dtk_motionBlurSnapshotImage)));
  }

  - (void)setDtk_motionBlurLayer:(CALayer *)dtk_motionBlurLayer
  {
      objc_setAssociatedObject(self, @selector(dtk_motionBlurLayer), dtk_motionBlurLayer ? [[DTKWeakObject alloc] initWithObject:dtk_motionBlurLayer] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  - (CALayer *)dtk_motionBlurLayer
  {
      return DTKRequiredCast(CALayer, DTKRequiredCast(DTKWeakObject, objc_getAssociatedObject(self, @selector(dtk_motionBlurLayer))).object);
  }

  - (void)setDtk_motionBlurDisplayLink:(CADisplayLink *)dtk_motionBlurDisplayLink
  {
      objc_setAssociatedObject(self, @selector(dtk_motionBlurDisplayLink), dtk_motionBlurDisplayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  - (CADisplayLink *)dtk_motionBlurDisplayLink
  {
      return DTKRequiredCast(CADisplayLink, objc_getAssociatedObject(self, @selector(dtk_motionBlurDisplayLink)));
  }

  - (void)setDtk_motionBlurLastPosition:(NSValue *)dtk_motionBlurLastPosition
  {
      objc_setAssociatedObject(self, @selector(dtk_motionBlurLastPosition), dtk_motionBlurLastPosition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  - (NSValue *)dtk_motionBlurLastPosition
  {
      return objc_getAssociatedObject(self, @selector(dtk_motionBlurLastPosition));
  }


  #pragma mark - Public

  - (void)dtk_enableMotionBlur
  {
      // snapshot has to be performed on the main thread
      self.dtk_motionBlurSnapshotImage = [self dtk_takeSnapshotUseGPUBasedTask:NO];
       
      let blurLayer = [[CALayer alloc] init];
      blurLayer.opacity = 0;
      blurLayer.actions = @{ NSStringFromSelector(@selector(opacity)) : [NSNull null] };
      [self.layer addSublayer:blurLayer];
      self.dtk_motionBlurLayer = blurLayer;
      
      let currentPosition = self.layer.presentationLayer.position;
      self.dtk_motionBlurLastPosition = @(currentPosition);

      // WARNING: CADisplayLink will run indefinitely, unless `-disableBlur` is called.
      let displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dtk_motionBlurDisplayLinkFired:)];
      [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
      if (@available(iOS 10.0, *)) {
          displayLink.preferredFramesPerSecond = 60;
      } else {
          // Fallback on earlier versions
      }
      displayLink.paused = NO;
      self.dtk_motionBlurDisplayLink = displayLink;
      
      if (@available(iOS 10.0, *)) {
          NSLog(@"motionBlur displaylink target time = %@", @(displayLink.targetTimestamp));
      } else {
          // Fallback on earlier versions
      }
  }

  - (void)dtk_disableMotionBlur
  {
      [self.dtk_motionBlurDisplayLink invalidate];
      self.dtk_motionBlurDisplayLink = nil;
      
      [self.dtk_motionBlurLayer removeFromSuperlayer];
      self.dtk_motionBlurLayer = nil;
      
      self.dtk_motionBlurLastPosition = nil;
  }


  #pragma mark - Private

  - (CGRect)blurredLayerFrameWithBlurredImage:(CGImageRef)blurredImgRef
  {
      CGFloat scale = [UIScreen mainScreen].scale;
      // Difference in size between the blurred image and the view.
      CGSize difference = CGSizeMake(CGImageGetWidth(blurredImgRef) / scale - CGRectGetWidth(self.frame), CGImageGetHeight(blurredImgRef) / scale - CGRectGetHeight(self.frame));
      CGRect blurLayerFrame = CGRectInset(self.bounds, -difference.width / 2, -difference.height / 2);
      return blurLayerFrame;
  }

  - (void)dtk_motionBlurDisplayLinkFired:(CADisplayLink *)displayLink
  {
      let currentPosition = self.layer.presentationLayer.position;
      const CGPoint previousPosition = [self.dtk_motionBlurLastPosition CGPointValue];
      
      if (self.dtk_motionBlurLastPosition
          && (currentPosition.x != previousPosition.x || currentPosition.y != previousPosition.y)) {
          let snapshotImage = self.dtk_motionBlurSnapshotImage;
          if (snapshotImage != nil) {
              const CGFloat delta = positionDelta(previousPosition, currentPosition);
              
              CGFloat angle = asin((previousPosition.y - currentPosition.y) / sqrt(pow(currentPosition.x - previousPosition.x, 2) + pow(currentPosition.y - previousPosition.y, 2)));
              let blurredImgRef = CGImageCreateByApplyingMotionBlur(snapshotImage, angle);
              DTK_DEFER { CGImageRelease(blurredImgRef); };
              let blurLayer = self.dtk_motionBlurLayer;
              
              blurLayer.contents = (__bridge id)(blurredImgRef);
              blurLayer.frame = [self blurredLayerFrameWithBlurredImage:blurredImgRef];
              blurLayer.opacity = (float)opacityFromPositionDelta(delta, displayLink.duration);
          }
      }
      
      self.dtk_motionBlurLastPosition = @(currentPosition);
  }
  
}
