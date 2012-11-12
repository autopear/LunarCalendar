//
//  LunarCalendarController.h
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012 autopear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import "LunarCalendar/LunarCalendar.h"
#import "TouchFix/TouchFix.h"

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

@interface SBBulletinListController
+ (id)sharedInstance;
- (id)listView;
@end

@interface LunarCalendarController : NSObject <BBWeeAppController>
{
	UIView *_view;
	UIImageView *bgView;
	UIScrollView *scrollView;
	UILabel *pageView1, *pageView2, *pageView3;
	UIButton *bigButton;
}

- (UIView *)view;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
- (void)singleTap:(UITapGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;
- (NSString *)customDatePrinter:(int)format;
- (void)dismissAlert:(UIAlertView *)alert;
- (void)refreshLabel;
- (NSString *)calculateDate:(NSString *)template;
@end

static NSMutableDictionary *preferences = nil;
static NSBundle *localizedBundle = nil;

static struct DateInfo dateInfo;
static int currentDate = 0;

static float viewHeight = 28.0f;
static int fontSize = 18;
static int switchGesture = NO;
static int pageNo = 0;

static BOOL viewHeightChanged = NO, fontSizeChanged = NO, formatChanged1 = NO, formatChanged2 = NO, formatChanged3 = NO;
static NSString *localeIdentifier = @"";

static NSString *displayDate1 = @"", *displayDate2 = @"", *displayDate3 = @"";

#define PreferencesChangedNotification "com.autopear.lunarcalendar/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.lunarcalendar.plist"]

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	if (preferences)
	{
		int readSwitchGesture = [preferences objectForKey:@"SwitchGesture"] ? [[preferences objectForKey:@"SwitchGesture"] intValue] : 0;
		if (readSwitchGesture > 2 || readSwitchGesture < 0)
			readSwitchGesture = 0;
		if (readSwitchGesture != switchGesture)
		{
			NSArray *gestures = [NSArray arrayWithObjects:@"Swipe", @"Single Tap", @"Double Tap", nil];
			NSLog(@"Switch gesture changed from \"%@\" to \"%@\".", [gestures objectAtIndex:switchGesture], [gestures objectAtIndex:readSwitchGesture]);
			switchGesture = readSwitchGesture;
		}

		float readViewHeight = [preferences objectForKey:@"ViewHeight"] ? [[preferences objectForKey:@"ViewHeight"] floatValue] : 28.0f;
		if (readViewHeight < 20.0f || readViewHeight > 60.0f)
			readViewHeight = 28.0f;
		if (readViewHeight != viewHeight)
		{
			viewHeightChanged = YES;
			NSLog(@"View height changed from %f to %f.", viewHeight, readViewHeight);
			viewHeight = readViewHeight;
		}

		int readFontSize = [preferences objectForKey:@"FontSize"] ? [[preferences objectForKey:@"FontSize"] intValue] : 18;
		if (readFontSize < 15 || readFontSize > 40)
			readFontSize = 18;
		if (readFontSize != fontSize)
		{
			fontSizeChanged = YES;
			NSLog(@"Font size changed from %d to %d.", fontSize, readFontSize);
			fontSize = readFontSize;
		}

		NSString *readFormat1 = [preferences objectForKey:@"CustomFormat1"] ? [preferences objectForKey:@"CustomFormat1"] : @"";
		if (![readFormat1 isEqualToString:displayDate1])
		{
			formatChanged1 = YES;
			NSLog(@"Format 1 changed from \"%@\" to \"%@\".", displayDate1, readFormat1);
			displayDate1 = readFormat1;
		}

		NSString *readFormat2 = [preferences objectForKey:@"CustomFormat2"] ? [preferences objectForKey:@"CustomFormat2"] : @"";
		readFormat2 = ([readFormat2 length] == 0) ? NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]") : readFormat2;
		if (![readFormat2 isEqualToString:displayDate2])
		{
			formatChanged2 = YES;
			NSLog(@"Format 2 changed from \"%@\" to \"%@\".", displayDate2, readFormat2);
			displayDate2 = readFormat2;
		}

		NSString *readFormat3 = [preferences objectForKey:@"CustomFormat3"] ? [preferences objectForKey:@"CustomFormat3"] : @"";
		readFormat3 = ([readFormat3 length] == 0) ? NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]") : readFormat3;
		if (![readFormat3 isEqualToString:displayDate3])
		{
			formatChanged3 = YES;
			NSLog(@"Format 3 changed from \"%@\" to \"%@\".", displayDate3, readFormat3);
			displayDate3 = readFormat3;
		}
	}
}

@implementation LunarCalendarController

-(id)init
{
	if ((self = [super init]))
	{
		preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];

		localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceLoader/Preferences/LunarCalendar/"];

		if (preferences == nil)
		{
			displayDate2 = NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]");
			displayDate3 = NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]");
			switchGesture = 0;
		}
		else
		{
			switchGesture = [preferences objectForKey:@"SwitchGesture"] ? [[preferences objectForKey:@"SwitchGesture"] intValue] : 0;
			if (switchGesture > 2 || switchGesture < 0)
				switchGesture = 0;
	
			viewHeight = [preferences objectForKey:@"ViewHeight"] ? [[preferences objectForKey:@"ViewHeight"] floatValue] : 28.0f;
			if (viewHeight < 20.0f || viewHeight > 60.0f)
				viewHeight = 28.0f;

			fontSize = [preferences objectForKey:@"FontSize"] ? [[preferences objectForKey:@"FontSize"] intValue] : 18;
			if (fontSize < 15 || fontSize > 40)
				fontSize = 18;

			pageNo = [preferences objectForKey:@"PageNo"] ? [[preferences objectForKey:@"PageNo"] intValue] : 0;
			if (pageNo < 0 || pageNo > 2)
				pageNo = 0;
	
			displayDate1 = ([[preferences objectForKey:@"CustomFormat1"] length] == 0) ? @"" : [preferences objectForKey:@"CustomFormat1"];
			displayDate2 = ([[preferences objectForKey:@"CustomFormat2"] length] == 0) ? NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]") : [preferences objectForKey:@"CustomFormat2"];
			displayDate3 = ([[preferences objectForKey:@"CustomFormat3"] length] == 0) ? NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]") : [preferences objectForKey:@"CustomFormat3"];
		}

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}

	return self;
}

-(void)dealloc
{
	[localizedBundle release];
	[preferences release];
	[_view release];
	[super dealloc];
}

- (UIView *)view
{
	if (_view == nil)
	{
		CGFloat superWidth = [[[objc_getClass("SBBulletinListController") sharedInstance] listView] tableView].bounds.size.width;

		_view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, (superWidth - 4), viewHeight)];

		UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

		bgView = [[UIImageView alloc] initWithImage:bg];
		bgView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
		[_view addSubview:bgView];
		[bgView release];

		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (superWidth - 4), viewHeight)];
		scrollView.pagingEnabled = YES;
		scrollView.bounces = YES;
		scrollView.showsHorizontalScrollIndicator = NO;

		pageView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (superWidth - 4), viewHeight)];
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

		pageView2 = [[UILabel alloc] initWithFrame:CGRectMake((superWidth - 4), 0, (superWidth - 4), viewHeight)];
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

		pageView3 = [[UILabel alloc] initWithFrame:CGRectMake((superWidth - 4) * 2, 0, (superWidth - 4), viewHeight)];
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

		UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
		doubleTapGestureRecognizer.numberOfTapsRequired = 2;

		UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		[singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

		bigButton = [[UIButton alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height)];
		[bigButton addGestureRecognizer:longPress];
		[bigButton addGestureRecognizer:doubleTapGestureRecognizer];
		[bigButton addGestureRecognizer:singleTapGestureRecognizer];
		[scrollView addSubview:bigButton];
		[bigButton release];

		[longPress release];
		[doubleTapGestureRecognizer release];
		[singleTapGestureRecognizer release];

		scrollView.contentSize = CGSizeMake((superWidth - 4) * 3, viewHeight);
		scrollView.showsHorizontalScrollIndicator = NO;

		[_view addSubview:scrollView];
		[scrollView release];
	}

	return _view;
}

- (void)dismissAlert:(UIAlertView *)alert
{
	[alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded)
	{
		NSString *message = NSLocalizedStringFromTableInBundle(@"Copied to clipboard.", @"LunarCalendar", localizedBundle, @"Copied to clipboard.");

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

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 1)
	{
		[self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
	}
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 2)
	{
		[self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
	}
}

- (void)refreshLabel
{
	if (pageNo <= 0)
		pageNo = 1;
	else if (pageNo > 1)
		pageNo = 0;
	else
		pageNo++;

	[pageView1 setText:[self customDatePrinter:pageNo]];
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
	template = [template stringByReplacingOccurrencesOfString:@"[L]" withString:(dateInfo.IsLeap ? dateInfo.LeapTitle : @"")];
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
	NSDate *today = [NSDate date];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setLocale:[NSLocale currentLocale]];

	[dateFormatter setDateStyle:NSDateFormatterFullStyle];

	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	NSString *date = [dateFormatter stringFromDate:today];

	[dateFormatter release];

	if (format == 0) //date + weekday + constellation
		return ([displayDate1 length] == 0) ? [[date stringByAppendingString:@"  "] stringByAppendingString:dateInfo.Constellation] : [self calculateDate:displayDate1];
	else if (format == 1)
		return [self calculateDate:displayDate2];
	else
		return [self calculateDate:displayDate3];
}

- (void)viewDidAppear
{
	if (fontSizeChanged)
	{
		[pageView1 setFont:[UIFont boldSystemFontOfSize:fontSize]];
		[pageView2 setFont:[UIFont boldSystemFontOfSize:fontSize]];
		[pageView3 setFont:[UIFont boldSystemFontOfSize:fontSize]];
		fontSizeChanged = NO;
	}

	if (viewHeightChanged)
	{
		pageView1.frame = CGRectMake(0, 0, scrollView.frame.size.width, viewHeight);
		pageView2.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, viewHeight);
		pageView3.frame = CGRectMake(scrollView.frame.size.width * 2, 0, scrollView.frame.size.width, viewHeight);
		viewHeightChanged = NO;
	}

	BOOL willRefresh = NO;

	NSDate *today = [NSDate date];

	NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];

	[currentFormatter setDateFormat:@"yyyyMMdd"];

	if ([[currentFormatter stringFromDate:today] intValue] != currentDate || formatChanged1 || formatChanged2 || formatChanged3 || ![[[NSLocale currentLocale] localeIdentifier] isEqualToString:localeIdentifier])
	{
		willRefresh = YES;
		currentDate = [[currentFormatter stringFromDate:today] intValue];
		[currentFormatter release];
		formatChanged1 = NO;
		formatChanged2 = NO;
		formatChanged3 = NO;
		localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
	}
	else
		[currentFormatter release];

	if (willRefresh)
	{
		//recalculate
		LunarCalendar *lunarCal = [[LunarCalendar alloc] init];

		[lunarCal loadWithDate:today];

		[lunarCal InitializeValue];

		dateInfo.GregorianYear = [lunarCal GregorianYear];
		dateInfo.GregorianMonth = [lunarCal GregorianMonth];
		dateInfo.GregorianDay = [lunarCal GregorianDay];

		dateInfo.Weekday = [lunarCal Weekday];

		dateInfo.Constellation = NSLocalizedStringFromTableInBundle([lunarCal Constellation], @"LunarCalendar", localizedBundle, [lunarCal Constellation]);

		dateInfo.YearHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal YearHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal YearHeavenlyStem]);
		dateInfo.YearEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal YearEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal YearEarthlyBranch]);

		dateInfo.MonthHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal MonthHeavenlyStem]);
		dateInfo.MonthEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal MonthEarthlyBranch]);

		dateInfo.DayHeavenlyStem = NSLocalizedStringFromTableInBundle([lunarCal DayHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal DayHeavenlyStem]);
		dateInfo.DayEarthlyBranch = NSLocalizedStringFromTableInBundle([lunarCal DayEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal DayEarthlyBranche]);

		dateInfo.IsLeap = [lunarCal IsLeap];

		dateInfo.Zodiac = NSLocalizedStringFromTableInBundle([lunarCal ZodiacLunar], @"LunarCalendar", localizedBundle, [lunarCal ZodiacLunar]);

		dateInfo.SolarTerm = NSLocalizedStringFromTableInBundle([lunarCal SolarTermTitle], @"LunarCalendar", localizedBundle, [lunarCal SolarTermTitle]);

		dateInfo.LeapTitle = NSLocalizedStringFromTableInBundle(@"LeapTitle", @"LunarCalendar", localizedBundle, @"LeapTitle");

		dateInfo.LunarMonth = NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], @"LunarCalendar", localizedBundle, [lunarCal MonthLunar]);
		dateInfo.LunarDay = NSLocalizedStringFromTableInBundle([lunarCal DayLunar], @"LunarCalendar", localizedBundle, [lunarCal DayLunar]);

		[lunarCal release];
	}

	if (switchGesture == 0)
	{
		CGPoint contentOffset = scrollView.contentOffset;

		contentOffset.x = ([preferences objectForKey:@"PageNo"] ? [[preferences objectForKey:@"PageNo"] intValue] : 0) * scrollView.frame.size.width;

		[scrollView setContentOffset:contentOffset animated:NO];

		[pageView1 setText:[self customDatePrinter:0]];

		[pageView2 setText:[self customDatePrinter:1]];

		[pageView3 setText:[self customDatePrinter:2]];
		scrollView.scrollEnabled = YES;
	}
	else
	{
		CGPoint contentOffset = scrollView.contentOffset;
		contentOffset.x = 0;
		[scrollView setContentOffset:contentOffset animated:NO];

		[pageView1 setText:[self customDatePrinter:pageNo]];
		scrollView.scrollEnabled = NO;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1
{
	CGFloat superWidth = [[[objc_getClass("SBBulletinListController") sharedInstance] listView] tableView].bounds.size.width;

	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		superWidth = UIInterfaceOrientationIsLandscape(arg1) ? 480.0f : 320.0f;

	_view.frame = CGRectMake(2, 0, (superWidth - 4), viewHeight);
	bgView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
	scrollView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);

	pageView1.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
	pageView2.frame = CGRectMake((superWidth - 4), 0, (superWidth - 4), viewHeight);
	pageView3.frame = CGRectMake((superWidth - 4) * 2, 0, (superWidth - 4), viewHeight);

	scrollView.contentSize = CGSizeMake((superWidth - 4) * 3, viewHeight);

	bigButton.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height);
}

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

- (void)viewDidDisappear
{
	//Save settings
	if (switchGesture == 0)
		pageNo = (int)(scrollView.contentOffset.x / (_view.superview.bounds.size.width - 12));

	[preferences setValue:[NSNumber numberWithInt:pageNo] forKey:@"PageNo"];

	[preferences writeToFile:PreferencesFilePath atomically:YES];
}

- (float)viewHeight
{
	return viewHeight;
}

@end