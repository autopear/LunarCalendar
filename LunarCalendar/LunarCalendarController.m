//
//  LunarCalendarController.m
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LunarCalendarController.h"
#import <SpringBoard/SBBulletinListController.h>

@implementation LunarCalendarController

-(id)init
{
    if ((self = [super init]))
    {
    }

    return self;
}

-(void)dealloc
{
    [_view release];
    [super dealloc];
}

- (UIView *)view
{
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, 28)];

        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

        bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, 316, 28);
        [_view addSubview:bgView];
        [bgView release];

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, 308, 28)];
        scrollView.pagingEnabled = YES;

        pageView1 = [[UILabel alloc] initWithFrame:scrollView.frame];
        pageView1.backgroundColor = [UIColor clearColor];
        pageView1.textColor = [UIColor whiteColor];
        pageView1.text = @"";
        pageView1.textAlignment = UITextAlignmentCenter;
        [pageView1 setFont:[UIFont boldSystemFontOfSize:18]];
        pageView1.shadowColor = [UIColor blackColor];
        pageView1.shadowOffset = CGSizeMake(1.0,1.0);
        [pageView1 setNumberOfLines:1];
        pageView1.adjustsFontSizeToFitWidth = YES;
        [scrollView addSubview:pageView1];
        [pageView1 release];

        CGRect cgrect2 = scrollView.frame;
        cgrect2.origin.x = scrollView.frame.size.width;
        pageView2 = [[UILabel alloc] initWithFrame:cgrect2];
        pageView2.backgroundColor = [UIColor clearColor];
        pageView2.textColor = [UIColor whiteColor];
        pageView2.text = @"";
        pageView2.textAlignment = UITextAlignmentCenter;
        [pageView2 setFont:[UIFont boldSystemFontOfSize:18]];
        pageView2.shadowColor = [UIColor blackColor];
        pageView2.shadowOffset = CGSizeMake(1.0,1.0);
        [pageView2 setNumberOfLines:1];
        pageView2.adjustsFontSizeToFitWidth = YES;
        [scrollView addSubview:pageView2];
        [pageView2 release];

        CGRect cgrect3 = scrollView.frame;
        cgrect3.origin.x = scrollView.frame.size.width * 2;
        pageView3 = [[UILabel alloc] initWithFrame:cgrect3];
        pageView3.backgroundColor = [UIColor clearColor];
        pageView3.textColor = [UIColor whiteColor];
        pageView3.text = @"";
        pageView3.textAlignment = UITextAlignmentCenter;
        [pageView3 setFont:[UIFont boldSystemFontOfSize:18]];
        pageView3.shadowColor = [UIColor blackColor];
        pageView3.shadowOffset = CGSizeMake(1.0,1.0);
        [pageView3 setNumberOfLines:1];
        pageView3.adjustsFontSizeToFitWidth = YES;
        [scrollView addSubview:pageView3];
        [pageView3 release];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];

        bigButton = [[UIButton alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height)];
        [bigButton addGestureRecognizer:longPress];
        [bigButton addGestureRecognizer:tap];
        [scrollView addSubview:bigButton];
        [bigButton release];

        [longPress release];
        [tap release];

        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, 28);
        scrollView.showsHorizontalScrollIndicator = NO;

        [_view addSubview:scrollView];
        [scrollView release];

        currentDate = 0;
        dateFormat = 0;
    }

    return _view;
}

- (void)dismissAlert:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/"];

        NSString *message = NSLocalizedStringFromTableInBundle(@"Copied to clipboard.", nil, bundle, @"Copied to clipboard.");

        [bundle release];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];

        [alert show];

        NSArray *subViewArray = alert.subviews;

        UIView *alertView = [subViewArray objectAtIndex:0];
        alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y + alertView.frame.size.height / 2 - 40, alertView.frame.size.width, 80);
        UILabel *label = [subViewArray objectAtIndex:1];
        label.frame = alertView.frame;
        [label setTextAlignment:UITextAlignmentCenter];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.strings = [NSArray arrayWithObjects:pageView1.text, @"\n", pageView2.text, @"\n", pageView3.text, nil];

        [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:1.5];

        [alert release];
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        //Tap first page only
        if (scrollView.contentOffset.x < scrollView.frame.size.width)
        {
            [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
        }
    }
}

- (void)refreshLabel
{
    if (dateFormat <= 0)
        dateFormat = 1;
    else if (dateFormat > 2)
        dateFormat = 0;
    else
        dateFormat++;

    pageView1.text = [self customDatePrinter:dateFormat];
}

- (NSString *)customDatePrinter:(int)format
{
    NSString *str = @"";

    NSDate *today = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setLocale:[NSLocale currentLocale]];

    if (dateFormat == 0)
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    else
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];

    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    NSString *date = [dateFormatter stringFromDate:today];

    NSString *constellation = @"";
    if (dateFormat == 0 || dateFormat == 2)
    {
        NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/"];

        NSDateFormatter *constellationFormatter = [[NSDateFormatter alloc] init];

        [constellationFormatter setDateFormat:@"MMdd"];

        int intConstellation = [[constellationFormatter stringFromDate:today] intValue];

        [constellationFormatter release];

        if (intConstellation >= 121 && intConstellation <= 219)
            constellation = NSLocalizedStringFromTableInBundle(@"Aquarius", nil, bundle, @"Aquarius");
        else if (intConstellation >= 220 && intConstellation <= 320)
            constellation = NSLocalizedStringFromTableInBundle(@"Pisces", nil, bundle, @"Pisces");
        else if (intConstellation >= 321 && intConstellation <= 419)
            constellation = NSLocalizedStringFromTableInBundle(@"Aries", nil, bundle, @"Aries");
        else if (intConstellation >= 420 && intConstellation <= 520)
            constellation = NSLocalizedStringFromTableInBundle(@"Taurus", nil, bundle, @"Taurus");
        else if (intConstellation >= 521 && intConstellation <= 621)
            constellation = NSLocalizedStringFromTableInBundle(@"Gemini", nil, bundle, @"Gemini");
        else if (intConstellation >= 622 && intConstellation <= 722)
            constellation = NSLocalizedStringFromTableInBundle(@"Taurus", nil, bundle, @"Cancer");
        else if (intConstellation >= 723 && intConstellation <= 822)
            constellation = NSLocalizedStringFromTableInBundle(@"Leo", nil, bundle, @"Leo");
        else if (intConstellation >= 823 && intConstellation <= 922)
            constellation = NSLocalizedStringFromTableInBundle(@"Virgo", nil, bundle, @"Virgo");
        else if (intConstellation >= 923 && intConstellation <= 1023)
            constellation = NSLocalizedStringFromTableInBundle(@"Libra", nil, bundle, @"Libra");
        else if (intConstellation >= 1024 && intConstellation <= 1121)
            constellation = NSLocalizedStringFromTableInBundle(@"Scorpio", nil, bundle, @"Scorpio");
        else if (intConstellation >= 1122 && intConstellation <= 1220)
            constellation = NSLocalizedStringFromTableInBundle(@"Sagittarius", nil, bundle, @"Sagittarius");
        else
            constellation = NSLocalizedStringFromTableInBundle(@"Capricorn", nil, bundle, @"Capricorn");
        [bundle release];
    }
    if (dateFormat == 0)
    {
        //date + weekday + constellation
        str = [[date stringByAppendingString:@"  "] stringByAppendingString:constellation];
    }
    else if (dateFormat == 1)
    {
        //date + weekday
        NSCalendar* cal = [NSCalendar currentCalendar];
        NSDateComponents* weekday = [cal components:NSWeekdayCalendarUnit fromDate:today];
        NSString *wd = [[dateFormatter weekdaySymbols] objectAtIndex:([weekday weekday] + 6) % 7];
        str = [date stringByAppendingFormat:@"  %@", wd];
    }
    else if (dateFormat == 2)
    {
        //date + constellation
        str = [date stringByAppendingFormat:@"  %@", constellation];
    }
    else
    {
        //date only
        str = date;
    }

    [dateFormatter release];

    return str;
}

- (void)viewDidAppear
{
    CGFloat superWidth = _view.superview.bounds.size.width;

    if (superWidth != originalWidth)
    {
        NSLog(@"View reloaded");

        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.x = scrollView.contentOffset.x / (originalWidth - 12) * (superWidth - 12);

        _view.frame = CGRectMake(2, 0, (superWidth - 4), 28);
        bgView.frame = CGRectMake(0, 0, (superWidth - 4), 28);
        scrollView.frame = CGRectMake(4, 0, (superWidth - 12), 28);

        pageView1.frame = CGRectMake(0, 0, (superWidth - 12), 28);
        pageView2.frame = CGRectMake((superWidth - 12), 0, (superWidth - 12), 28);
        pageView3.frame = CGRectMake((superWidth - 12)*2, 0, (superWidth - 12), 28);
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, 28);
        [scrollView setContentOffset:contentOffset animated:NO];
        
        bigButton.frame = CGRectMake(4, 0, (superWidth - 12) * 3, 28);
        
        originalWidth = superWidth;
    }

    NSDate *today = [NSDate date];

    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];

    [currentFormatter setDateFormat:@"yyyyMMdd"];

    pageView1.text = [self customDatePrinter:dateFormat];

    if (currentDate != [[currentFormatter stringFromDate:today] intValue])
    {
        NSLog(@"Recalculate");
        currentDate = [[currentFormatter stringFromDate:today] intValue];
    }
    else
    {
        NSLog(@"Do nothing");
        [currentFormatter release];
        return;
    }

    [currentFormatter release];

    LunarCalendar *lunarCal = [[LunarCalendar alloc] init];

    [lunarCal loadWithDate:today];

    [lunarCal InitializeValue];

    bool isLeap = [lunarCal IsLeap];

    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/"];

    NSString *yearHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal YearHeavenlyStem], nil, bundle, [lunarCal YearHeavenlyStem]);
    NSString *yearEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal YearEarthlyBranch], nil, bundle, [lunarCal YearEarthlyBranch]);

    NSString *monthHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], nil, bundle, [lunarCal MonthHeavenlyStem]);
    NSString *monthEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], nil, bundle, [lunarCal MonthEarthlyBranch]);

    NSString *dayHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal DayHeavenlyStem], nil, bundle, [lunarCal DayHeavenlyStem]);
    NSString *dayEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal DayEarthlyBranch], nil, bundle, [lunarCal DayEarthlyBranche]);

    NSString *zodiacLunar = NSLocalizedStringFromTableInBundle([lunarCal ZodiacLunar], nil, bundle, [lunarCal ZodiacLunar]);

    NSString *solarTerm = NSLocalizedStringFromTableInBundle([lunarCal SolarTermTitle], nil, bundle, [lunarCal SolarTermTitle]);

    NSString *dateFormatNormal = NSLocalizedStringFromTableInBundle(@"DateFormatNormal", nil, bundle, @"DateFormatNormal");
    NSString *dateFormatTraditional = NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", nil, bundle, @"DateFormatTraditional");

    dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[H]" withString:yearHeavenlyStem];
    dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[E]" withString:yearEarthlyBranch];

    if (isLeap)
        dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[M]" withString:[NSLocalizedStringFromTableInBundle(@"LeapTitle", nil, bundle, @"LeapTitle") stringByAppendingString:NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], nil, bundle, [lunarCal MonthLunar])]];
    else
        dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[M]" withString:NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], nil, bundle, [lunarCal MonthLunar])];

    dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[D]" withString:NSLocalizedStringFromTableInBundle([lunarCal DayLunar], nil, bundle, [lunarCal DayLunar])];

    [lunarCal release];

    dateFormatNormal = [dateFormatNormal stringByReplacingOccurrencesOfString:@"[Z]" withString:zodiacLunar];

    //"DateFormatTraditional" = "[YH]-[YE]/[MH]-[ME]/[DH]-[DE]";
    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[YH]" withString:yearHeavenlyStem];
    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[YE]" withString:yearEarthlyBranch];

    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[MH]" withString:monthHeavenlyStem];
    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[ME]" withString:monthEarthlyBranch];

    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[DH]" withString:dayHeavenlyStem];
    dateFormatTraditional = [dateFormatTraditional stringByReplacingOccurrencesOfString:@"[DE]" withString:dayEarthlyBranch];

    [bundle release];

    if ([solarTerm isEqualToString:@""])
        [pageView2 setText:dateFormatNormal];
    else
        [pageView2 setText:[dateFormatNormal stringByAppendingFormat:@"  %@", solarTerm]];

    [pageView3 setText:dateFormatTraditional];
}

- (float)viewHeight
{
    return 28.0f;
}

@end