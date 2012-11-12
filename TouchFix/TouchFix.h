@interface UIEvent (Creation)
- (id)initWithTouch:(UITouch *)touch;
@end

@interface UITouch (Creation)
- (id)initWithPoint:(CGPoint)point andView:(UIView*)view;
- (void)setPhase:(UITouchPhase)phase;
@end


/* How to fix the Touch bug:
Add TouchFix.m in your makefile, and import TouchFix.h
Then in your widget controller implementation add:

- (id)launchURLForTapLocation:(CGPoint)point
{
    // Hack to fix the touch bug
    UITouch *touch = [[UITouch alloc] initWithPoint:[[self view] convertPoint:point toView:[self view].window] andView:[self view]];
    UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesBegan:[eventDown allTouches] withEvent:eventDown];
    [touch setPhase:UITouchPhaseEnded];
    UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesEnded:[eventUp allTouches] withEvent:eventUp];
    [eventDown release];
    [eventUp release];
    [touch release];
    return nil;
}


Enjoy.
~qwertyoruiop

*/
