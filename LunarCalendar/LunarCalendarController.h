//
//  LunarCalendarController.h
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SpringBoard/BBWeeAppController.h"
#import "LunarCalendar.h"

@interface LunarCalendarController : NSObject <BBWeeAppController>
{
    UIView *_view;
    UIImageView *bgView;
    UIScrollView *scrollView;
    UILabel *pageView1, *pageView2, *pageView3;
    
    int currentDate;
    
    CGFloat originalWidth;
}

- (UIView *)view;

@end