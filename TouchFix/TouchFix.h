#ifndef __LP64__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "UITouch+Private.h"

@interface UIEvent (LunarCalendar_TouchFix)

- (instancetype)initWithTouch:(UITouch *)touch;

@end

@interface UITouch (LunarCalendar_TouchFix)

- (instancetype)initWithPoint:(CGPoint)point andView:(UIView *)view;
- (void)changeToPhase:(UITouchPhase)phase;

@end

#endif