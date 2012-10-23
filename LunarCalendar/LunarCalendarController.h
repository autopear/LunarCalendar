//
//  LunarCalendarController.h
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012 autopear. All rights reserved.
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
    UIButton *bigButton;

    struct DateInfo
    {
        int GregorianYear;
        int GregorianMonth;
        int GregorianDay;
        int Weekday;
        NSString *LunarMonth;
        NSString *LunarDay;
        NSString *YearHeavenlyStem;
        NSString *YearEarthlyBranch;
        NSString *MonthHeavenlyStem;
        NSString *MonthEarthlyBranch;
        NSString *DayHeavenlyStem;
        NSString *DayEarthlyBranch;
        bool IsLeap;
        NSString *Constellation;
        NSString *Zodiac;
        NSString *SolarTerm;
        NSString *LeapTitle;
    };
}

- (UIView *)view;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
- (void)tap:(UITapGestureRecognizer *)gesture;
- (NSString *)customDatePrinter:(int)format;
- (void)dismissAlert:(UIAlertView *)alert;
- (void)refreshLabel;
- (NSString *)calculateDate:(NSString *)template;

@end