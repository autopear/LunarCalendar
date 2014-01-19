#ifndef __LP64__

#import <objc/runtime.h>
#import "UITouch+Private.h"
#import "TouchFix.h"

@interface LunarCalendar__GSEvent : NSObject {
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end

@implementation LunarCalendar__GSEvent
@end

@interface UIEvent ()
- (UIEvent *)_initWithEvent:(LunarCalendar__GSEvent *)fp8 touches:(id)fp12;
@end

@implementation UITouch (LunarCalendar__TouchFix)

- (UITouch *)initWithPoint:(CGPoint)point andView:(UIView *)view {
    self = [super init];
    if (self) {
        CGRect frameInWindow;
        
        if ([view isKindOfClass:[UIWindow class]])
            frameInWindow = view.frame;
        else
            frameInWindow = [view.window convertRect:view.frame fromView:view.superview];
        
        _tapCount = 1;
        _locationInWindow = point;
        _previousLocationInWindow = _locationInWindow;
        UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
#if !__has_feature(objc_arc)
        _view = [target retain];
        _window = [view.window retain];
#else
        _view = target;
        _window = view.window;
#endif
        _phase = UITouchPhaseBegan;
        _touchFlags._firstTouchForView = 1;
        _touchFlags._isTap = 1;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void)setPhase:(UITouchPhase)phase {
    _phase = phase;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end

@implementation UIEvent (LunarCalendar__TouchFix)

- (UIEvent *)initWithTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:touch.window];
    
    LunarCalendar__GSEvent *gsEventProxy = [[LunarCalendar__GSEvent alloc] init];
    
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0f;
    gsEventProxy->sizeY = 1.0f;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;
    
#if !__has_feature(objc_arc)
    [self release];
#endif
    
    self = nil;
    
    self = [[objc_getClass("UITouchesEvent") alloc] _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
    
#if !__has_feature(objc_arc)
    [gsEventProxy release];
#endif
    
    return self;
}

@end

#endif
