#ifndef __LP64__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIEvent (LunarCalendar__TouchFix)
- (UIEvent *)initWithTouch:(UITouch *)touch;
@end

@interface UITouch (LunarCalendar__TouchFix)
- (UITouch *)initWithPoint:(CGPoint)point andView:(UIView *)view;
- (void)setPhase:(UITouchPhase)phase;
@end

#endif