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
		_view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, 30)];

        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

		bgView = [[UIImageView alloc] initWithImage:bg];
		bgView.frame = CGRectMake(0, 0, 316, 30);
		[_view addSubview:bgView];
		[bgView release];

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, 308, 30)];
        scrollView.pagingEnabled = YES;

        pageView1 = [[UILabel alloc] initWithFrame:scrollView.frame];
        pageView1.backgroundColor = [UIColor clearColor];
		pageView1.textColor = [UIColor whiteColor];
		pageView1.text = @"";
		pageView1.textAlignment = UITextAlignmentCenter;
        [pageView1 setFont:[UIFont boldSystemFontOfSize:18]];
        pageView1.shadowColor = [UIColor blackColor];
        pageView1.shadowOffset = CGSizeMake(1.5,1.5);
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
        pageView2.shadowOffset = CGSizeMake(1.5,1.5);
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
        pageView3.shadowOffset = CGSizeMake(1.5,1.5);
        [pageView3 setNumberOfLines:1];
        pageView3.adjustsFontSizeToFitWidth = YES;
		[scrollView addSubview:pageView3];
        [pageView3 release];
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, 30);
        scrollView.showsHorizontalScrollIndicator = NO;

        [_view addSubview:scrollView];
        [scrollView release];
        
        currentDate = 0;
    }

	return _view;
}

- (void)viewDidAppear
{
    CGFloat superWidth = _view.superview.bounds.size.width;
    
    if (superWidth != originalWidth)
    {
        NSLog(@"View reloaded");
        
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.x = scrollView.contentOffset.x / (originalWidth - 12) * (superWidth - 12);

        _view.frame = CGRectMake(2, 0, (superWidth - 4), 30);
        bgView.frame = CGRectMake(0, 0, (superWidth - 4), 30);
        scrollView.frame = CGRectMake(4, 0, (superWidth - 12), 30);
        
        pageView1.frame = CGRectMake(0, 0, (superWidth - 12), 30);
        pageView2.frame = CGRectMake((superWidth - 12), 0, (superWidth - 12), 30);
        pageView3.frame = CGRectMake((superWidth - 12)*2, 0, (superWidth - 12), 30);
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, 30);

        [scrollView setContentOffset:contentOffset animated:NO];
        
        originalWidth = superWidth;
    }
    
    NSDate *today = [NSDate date];
    
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    
    [currentFormatter setDateFormat:@"yyyyMMdd"];
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
    NSString *date = [dateFormatter stringFromDate:today];    

    [dateFormatter release];
    
    NSString *constellation = @"";
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
    
    NSString *str = [[date stringByAppendingString:@"  "] stringByAppendingString:constellation];
    pageView1.text = str;

    if (currentDate != [[currentFormatter stringFromDate:today] intValue])
    {
        NSLog(@"Recalculate");
        currentDate = [[currentFormatter stringFromDate:today] intValue];
    }
    else
    {
        NSLog(@"Do nothing");
        [currentFormatter release];
        [bundle release];
        return;
    }
    
    [currentFormatter release];

    LunarCalendar *lunarCal = [[LunarCalendar alloc] init];
    
    [lunarCal loadWithDate:today];
    
    [lunarCal InitializeValue];
    
    bool isLeap = [lunarCal IsLeap];
    
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
        [pageView2 setText:[dateFormatNormal stringByAppendingFormat:@"    %@", solarTerm]];
        
    [pageView3 setText:dateFormatTraditional];
}

- (float)viewHeight
{
	return 30.0f;
}

@end