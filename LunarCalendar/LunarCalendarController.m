//
//  LunarCalendarController.m
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LunarCalendarController.h"
#import <SpringBoard/SBBulletinListController.h>

static NSDictionary *preferences = nil;

static struct DateInfo dateInfo;
static int dateFormat, currentDate;
static NSString *customDate;

#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.lunarcalendar.plist"]

@implementation LunarCalendarController

-(id)init
{
    if ((self = [super init]))
    {
        viewHeight = 28.0f;
        fontSize = 18;
    }
    
    return self;
}

-(void)dealloc
{
	[preferences release];
    [_view release];
    [super dealloc];
}

- (UIView *)view
{
    if (_view == nil)
    {
        preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
        if (preferences == nil)
        {
            dateFormat = 0;
            viewHeight = 28.0f;
            fontSize = 18;
        }
        else
        {
            if ([preferences objectForKey:@"ViewHeight"])
                viewHeight = [[preferences objectForKey:@"ViewHeight"] floatValue];
            else
                viewHeight = 28.0f;
            if ([preferences objectForKey:@"FontSize"])
                fontSize = [[preferences objectForKey:@"FontSize"] intValue];
            else
                fontSize = 18;
        }
        
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, viewHeight)];
        
        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, 316, viewHeight);
        [_view addSubview:bgView];
        [bgView release];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, 308, viewHeight)];
        scrollView.pagingEnabled = YES;
        
        pageView1 = [[UILabel alloc] initWithFrame:scrollView.frame];
        pageView1.backgroundColor = [UIColor clearColor];
        pageView1.textColor = [UIColor whiteColor];
        pageView1.text = @"";
        pageView1.textAlignment = UITextAlignmentCenter;
        [pageView1 setFont:[UIFont boldSystemFontOfSize:fontSize]];
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
        [pageView2 setFont:[UIFont boldSystemFontOfSize:fontSize]];
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
        [pageView3 setFont:[UIFont boldSystemFontOfSize:fontSize]];
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
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, viewHeight);
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [_view addSubview:scrollView];
        [scrollView release];
        
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
        pasteboard.string = [NSString stringWithFormat:@"%@\n%@\n%@", pageView1.text, pageView2.text, pageView3.text];
        
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
    
    [pageView1 setText:[self customDatePrinter:dateFormat]];
}

- (NSString *)calculateDate:(NSString *)template
{
    template = [template stringByReplacingOccurrencesOfString:@"[GY]" withString:[NSString stringWithFormat:@"%d", dateInfo.GregorianYear]];
    template = [template stringByReplacingOccurrencesOfString:@"[GM]" withString:[NSString stringWithFormat:@"%d", dateInfo.GregorianMonth]];
    template = [template stringByReplacingOccurrencesOfString:@"[GD]" withString:[NSString stringWithFormat:@"%d", dateInfo.GregorianDay]];
    template = [template stringByReplacingOccurrencesOfString:@"[LM]" withString:dateInfo.LunarMonth];
    template = [template stringByReplacingOccurrencesOfString:@"[LD]" withString:dateInfo.LunarDay];
    template = [template stringByReplacingOccurrencesOfString:@"[HY]" withString:dateInfo.YearHeavenlyStem];
    template = [template stringByReplacingOccurrencesOfString:@"[EY]" withString:dateInfo.YearEarthlyBranch];
    template = [template stringByReplacingOccurrencesOfString:@"[HM]" withString:dateInfo.MonthHeavenlyStem];
    template = [template stringByReplacingOccurrencesOfString:@"[EM]" withString:dateInfo.MonthEarthlyBranch];
    template = [template stringByReplacingOccurrencesOfString:@"[HD]" withString:dateInfo.DayHeavenlyStem];
    template = [template stringByReplacingOccurrencesOfString:@"[ED]" withString:dateInfo.DayEarthlyBranch];
    if (dateInfo.IsLeap)
        template = [template stringByReplacingOccurrencesOfString:@"[L]" withString:dateInfo.LeapTitle];
    else
        template = [template stringByReplacingOccurrencesOfString:@"[L]" withString:@""];
    template = [template stringByReplacingOccurrencesOfString:@"[C]" withString:dateInfo.Constellation];
    template = [template stringByReplacingOccurrencesOfString:@"[Z]" withString:dateInfo.Zodiac];
    template = [template stringByReplacingOccurrencesOfString:@"[S]" withString:dateInfo.SolarTerm];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    template = [template stringByReplacingOccurrencesOfString:@"[WD]" withString:[[dateFormatter weekdaySymbols] objectAtIndex:(dateInfo.Weekday + 6) % 7]];
    [dateFormatter release];
    
    return [template stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    
    NSString *weekday = [[dateFormatter weekdaySymbols] objectAtIndex:(dateInfo.Weekday + 6) % 7];

    [dateFormatter release];

    if (dateFormat == 0)
    {
        //date + weekday + constellation
        str = [[date stringByAppendingString:@"  "] stringByAppendingString:dateInfo.Constellation];
    }
    else if (dateFormat == 1)
    {
        str = [date stringByAppendingFormat:@"  %@", weekday];
    }
    else if (dateFormat == 2)
    {
        //date + constellation
        str = [date stringByAppendingFormat:@"  %@", dateInfo.Constellation];
    }
    else
    {
        if ([customDate isEqualToString:@""])
        {
            //date only
            str = date;            
        }
        else
        {
            str = [self calculateDate:customDate];
        }
    }
    
    return str;
}

- (void)viewDidAppear
{
    preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
    CGFloat superWidth = _view.superview.bounds.size.width;
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    if (preferences == nil)
        contentOffset.x = 0;
    else if ([preferences objectForKey:@"PageNo"])
        contentOffset.x = [[preferences objectForKey:@"PageNo"] intValue] * (superWidth - 12);
    else
        contentOffset.x = 0;        
    
    if ([preferences objectForKey:@"ViewHeight"])
        viewHeight = [[preferences objectForKey:@"ViewHeight"] floatValue];
    if ([preferences objectForKey:@"FontSize"])
        fontSize = [[preferences objectForKey:@"FontSize"] intValue];
    
    _view.frame = CGRectMake(2, 0, (superWidth - 4), viewHeight);
    bgView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
    scrollView.frame = CGRectMake(4, 0, (superWidth - 12), viewHeight);
    
    pageView1.frame = CGRectMake(0, 0, (superWidth - 12), viewHeight);
    [pageView1 setFont:[UIFont boldSystemFontOfSize:fontSize]];
    pageView2.frame = CGRectMake((superWidth - 12), 0, (superWidth - 12), viewHeight);
    [pageView2 setFont:[UIFont boldSystemFontOfSize:fontSize]];
    pageView3.frame = CGRectMake((superWidth - 12)*2, 0, (superWidth - 12), viewHeight);
    [pageView3 setFont:[UIFont boldSystemFontOfSize:fontSize]];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, viewHeight);
    [scrollView setContentOffset:contentOffset animated:NO];
        
    bigButton.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height);

    if (preferences == nil)
    {
        dateFormat = 0;
        customDate = @"";
    }
    else
    {
        if ([preferences objectForKey:@"DateFormat"])
            dateFormat = [[preferences objectForKey:@"DateFormat"] intValue];
        else
            dateFormat = 0;
        if ([preferences objectForKey:@"CustomFormat"])
            customDate = [preferences objectForKey:@"CustomFormat"];
        else
            customDate = @"";
    }
        
    NSDate *today = [NSDate date];
    
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    
    [currentFormatter setDateFormat:@"yyyyMMdd"];
    currentDate = [[currentFormatter stringFromDate:today] intValue];
    [currentFormatter release];

    //recalculate
    LunarCalendar *lunarCal = [[LunarCalendar alloc] init];
    
    [lunarCal loadWithDate:today];
    
    [lunarCal InitializeValue];

    dateInfo.GregorianYear = [lunarCal GregorianYear];
    dateInfo.GregorianMonth = [lunarCal GregorianMonth];
    dateInfo.GregorianDay = [lunarCal GregorianDay];
    
    dateInfo.Weekday = [lunarCal Weekday];
    
    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/"];
    
    dateInfo.Constellation = NSLocalizedStringFromTableInBundle([lunarCal Constellation], nil, bundle, [lunarCal Constellation]);
    
    dateInfo.YearHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal YearHeavenlyStem], nil, bundle, [lunarCal YearHeavenlyStem]);
    dateInfo.YearEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal YearEarthlyBranch], nil, bundle, [lunarCal YearEarthlyBranch]);
    
    dateInfo.MonthHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], nil, bundle, [lunarCal MonthHeavenlyStem]);
    dateInfo.MonthEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], nil, bundle, [lunarCal MonthEarthlyBranch]);
    
    dateInfo.DayHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal DayHeavenlyStem], nil, bundle, [lunarCal DayHeavenlyStem]);
    dateInfo.DayEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal DayEarthlyBranch], nil, bundle, [lunarCal DayEarthlyBranche]);
    
    dateInfo.IsLeap = [lunarCal IsLeap];
    
    dateInfo.Zodiac = NSLocalizedStringFromTableInBundle([lunarCal ZodiacLunar], nil, bundle, [lunarCal ZodiacLunar]);
    
    dateInfo.SolarTerm = NSLocalizedStringFromTableInBundle([lunarCal SolarTermTitle], nil, bundle, [lunarCal SolarTermTitle]);
    
    NSString *dateFormatNormal = NSLocalizedStringFromTableInBundle(@"DateFormatNormal", nil, bundle, @"DateFormatNormal");
    NSString *dateFormatTraditional = NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", nil, bundle, @"DateFormatTraditional");
    
    dateInfo.LeapTitle = NSLocalizedStringFromTableInBundle(@"LeapTitle", nil, bundle, @"LeapTitle");
    
    dateInfo.LunarMonth = NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], nil, bundle, [lunarCal MonthLunar]);
    dateInfo.LunarDay = NSLocalizedStringFromTableInBundle([lunarCal DayLunar], nil, bundle, [lunarCal DayLunar]);
    
    [lunarCal release];
    
    [bundle release];
    
    [pageView2 setText:[self calculateDate:dateFormatNormal]];
    
    [pageView3 setText:[self calculateDate:dateFormatTraditional]];
    
    [pageView1 setText:[self customDatePrinter:dateFormat]];
}

- (void)viewDidDisappear
{
    //Save settings
    int newPage = scrollView.contentOffset.x / (_view.superview.bounds.size.width - 12);
    [preferences setValue:[NSNumber numberWithInt:newPage] forKey:@"PageNo"];
    [preferences setValue:[NSNumber numberWithInt:dateFormat] forKey:@"DateFormat"];
    
    [preferences writeToFile:PreferencesFilePath atomically:YES];
}

- (float)viewHeight
{
    return viewHeight;
}

@end