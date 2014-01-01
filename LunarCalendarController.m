//
//  LunarCalendarController.h
//  LunarCalendar
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012 autopear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BBWeeAppController-Protocol.h"
#import "LunarCalendar/LunarCalendar.h"
#import "_SBUIWidgetViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#define lcAlignCenter NSTextAlignmentCenter
#else
#define lcAlignCenter UITextAlignmentCenter
#endif

#define PreferencesChangedNotification "com.autopear.lunarcalendar/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.lunarcalendar.plist"]

//SpringBoard headers
@interface SBBulletinListController
+ (id)sharedInstance;
- (id)listView;
@end

@interface SBBulletinListView : UIView
- (id)linenView;
@end

//Controller for iOS 5 and iOS 6
@interface LunarCalendarController : NSObject <BBWeeAppController>
{
    UIView *_weeView;
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
- (void)viewDidAppear;
- (void)viewDidDisappear;
@end

//Controller for iOS 7
@interface LunarCalendarWidgetController: _SBUIWidgetViewController
{
    UIView *_weeView;
    UIScrollView *scrollView;
    UILabel *pageView1, *pageView2, *pageView3;
    UIButton *bigButton;
    CGFloat _initWidth;
    CGFloat _initHeight;
    CGFloat _lastWidth;
}
- (CGFloat)getWidth;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
- (void)singleTap:(UITapGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;
- (NSString *)customDatePrinter:(int)format;
- (void)dismissAlert:(UIAlertView *)alert;
- (void)refreshLabel;
- (NSString *)calculateDate:(NSString *)template;
- (void)updateLunarInfo;
@end

static NSBundle *localizedBundle = nil;
static NSMutableDictionary *preferences = nil;
static NSDictionary *languageStrings = nil;
static float viewHeight = 28.0f;
static int fontSize = 18;
static int switchGesture = 0;
static int pageNo = 0;
static BOOL viewHeightChanged = NO, fontSizeChanged = NO, formatChanged1 = NO, formatChanged2 = NO, formatChanged3 = NO;
static NSString *displayDate1 = @"", *displayDate2 = @"", *displayDate3 = @"";
static NSMutableDictionary *dateInfo;
static int currentDate = 0;

static void LoadPreferences()
{
    if (preferences)
        preferences = nil;
    if (languageStrings)
        languageStrings = nil;
    
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    if (preferences)
    {
        NSString *readLanguage = [preferences objectForKey:@"Language"] ? [preferences objectForKey:@"Language"] : @"default";
        if (![readLanguage isEqualToString:@"default"])
        {
            NSString *languagePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/LunarCalendar.bundle/%@.lproj/LunarCalendar.strings", readLanguage];
            if ([[NSFileManager defaultManager] fileExistsAtPath:languagePath])
                languageStrings = [[NSDictionary alloc] initWithContentsOfFile:languagePath];
        }

        int readSwitchGesture = [preferences objectForKey:@"SwitchGesture"] ? [[preferences objectForKey:@"SwitchGesture"] intValue] : 0;
        if (readSwitchGesture > 2 || readSwitchGesture < 0)
            readSwitchGesture = 0;
        if (kCFCoreFoundationVersionNumber >= 847.20 && readSwitchGesture == 0)
            readSwitchGesture = 1;
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
        if ([readFormat2 length] == 0)
        {
            if (languageStrings && [languageStrings objectForKey:@"DateFormatNormal"])
                readFormat2 = [languageStrings objectForKey:@"DateFormatNormal"];
            if ([readFormat2 length] == 0)
                readFormat2 =  NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]");
        }

        if (![readFormat2 isEqualToString:displayDate2])
        {
            formatChanged2 = YES;
            NSLog(@"Format 2 changed from \"%@\" to \"%@\".", displayDate2, readFormat2);
            displayDate2 = readFormat2;
        }

        NSString *readFormat3 = [preferences objectForKey:@"CustomFormat3"] ? [preferences objectForKey:@"CustomFormat3"] : @"";
        if ([readFormat3 length] == 0)
        {
            if (languageStrings && [languageStrings objectForKey:@"DateFormatTraditional"])
                readFormat3 = [languageStrings objectForKey:@"DateFormatTraditional"];
            if ([readFormat3 length] == 0)
                readFormat3 =  NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]");
        }

        if (![readFormat3 isEqualToString:displayDate3])
        {
            formatChanged3 = YES;
            NSLog(@"Format 3 changed from \"%@\" to \"%@\".", displayDate3, readFormat3);
            displayDate3 = readFormat3;
        }
    }
    else
    {
        displayDate2 = NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]");
        displayDate3 = NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]");
        switchGesture = kCFCoreFoundationVersionNumber < 847.20 ? 0 : 1;
;
    }
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadPreferences();
}

@implementation LunarCalendarController

- (id)init
{
    if (kCFCoreFoundationVersionNumber >= 847.20)
        return nil;

    if ((self = [super init]))
    {
        localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LunarCalendar.bundle/"];

        LoadPreferences();

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

        dateInfo = [[NSMutableDictionary alloc] initWithCapacity:17];

        CGFloat superWidth;
        if ([[[objc_getClass("SBBulletinListController") sharedInstance] listView] linenView])
            superWidth = ((UIView *)[[[objc_getClass("SBBulletinListController") sharedInstance] listView] linenView]).frame.size.width;
        else
            superWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 480.0f : 320.0f;

        _weeView = [[UIView alloc] initWithFrame:CGRectMake(2, 0, (superWidth - 4), viewHeight)];

        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/LunarCalendar.bundle/WeeAppBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

        bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
        [_weeView addSubview:bgView];
        [bgView release];

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (superWidth - 4), viewHeight)];
        scrollView.pagingEnabled = YES;
        scrollView.bounces = YES;
        scrollView.showsHorizontalScrollIndicator = NO;

        pageView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (superWidth - 4), viewHeight)];
        pageView1.backgroundColor = [UIColor clearColor];
        pageView1.textColor = [UIColor whiteColor];
        pageView1.text = @"";
        pageView1.textAlignment = lcAlignCenter;
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
        pageView2.textAlignment = lcAlignCenter;
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
        pageView3.textAlignment = lcAlignCenter;
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

        [_weeView addSubview:scrollView];
        [scrollView release];
    }

    return self;
}

- (void)dealloc
{
    if (languageStrings)
        [languageStrings release];
    [dateInfo release];
    [localizedBundle release];
    [preferences release];
    [_weeView release];
    [super dealloc];
}

- (UIView *)view
{
    return _weeView;
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
        [label setTextAlignment:lcAlignCenter];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (switchGesture == 0)
            pasteboard.string = [NSString stringWithFormat:@"%@\n%@\n%@", pageView1.text, pageView2.text, pageView3.text];
        else
            pasteboard.string = [NSString stringWithFormat:@"%@", pageView1.text];

        [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:1.5];

        [alert release];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 1)
        [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 2)
        [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
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
    template = [template stringByReplacingOccurrencesOfString:@"[GY]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianYear"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[GM]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianMonth"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[GD]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianDay"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[LM]" withString:[dateInfo objectForKey:@"LunarMonth"]];
    template = [template stringByReplacingOccurrencesOfString:@"[LD]" withString:[dateInfo objectForKey:@"LunarDay"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HY]" withString:[dateInfo objectForKey:@"YearHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[EY]" withString:[dateInfo objectForKey:@"YearEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HM]" withString:[dateInfo objectForKey:@"MonthHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[EM]" withString:[dateInfo objectForKey:@"MonthEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HD]" withString:[dateInfo objectForKey:@"DayHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[ED]" withString:[dateInfo objectForKey:@"DayEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[L]" withString:([[dateInfo objectForKey:@"IsLeap"] boolValue] ? [dateInfo objectForKey:@"LeapTitle"] : @"")];
    template = [template stringByReplacingOccurrencesOfString:@"[C]" withString:[dateInfo objectForKey:@"Constellation"]];
    template = [template stringByReplacingOccurrencesOfString:@"[Z]" withString:[dateInfo objectForKey:@"Zodiac"]];
    template = [template stringByReplacingOccurrencesOfString:@"[S]" withString:[dateInfo objectForKey:@"SolarTerm"]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    template = [template stringByReplacingOccurrencesOfString:@"[WD]" withString:[[dateFormatter weekdaySymbols] objectAtIndex:([[dateInfo objectForKey:@"Weekday"] intValue] + 6) % 7]];
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
        return ([displayDate1 length] == 0) ? [NSString stringWithFormat:@"%@  %@", date, [dateInfo objectForKey:@"Constellation"]] : [self calculateDate:displayDate1];
    else if (format == 1)
        return [self calculateDate:displayDate2];
    else
        return [self calculateDate:displayDate3];
}

- (void)viewDidAppear
{
    CGFloat superWidth;
    if ([[[objc_getClass("SBBulletinListController") sharedInstance] listView] linenView])
        superWidth = ((UIView *)[[[objc_getClass("SBBulletinListController") sharedInstance] listView] linenView]).frame.size.width;
    else
        superWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 480.0f : 320.0f;

    _weeView.frame = CGRectMake(2, 0, (superWidth - 4), viewHeight);
    bgView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
    scrollView.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);

    pageView1.frame = CGRectMake(0, 0, (superWidth - 4), viewHeight);
    pageView2.frame = CGRectMake((superWidth - 4), 0, (superWidth - 4), viewHeight);
    pageView3.frame = CGRectMake((superWidth - 4) * 2, 0, (superWidth - 4), viewHeight);

    scrollView.contentSize = CGSizeMake((superWidth - 4) * 3, viewHeight);

    bigButton.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height);

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

    if ([[currentFormatter stringFromDate:today] intValue] != currentDate || formatChanged1 || formatChanged2 || formatChanged3)
    {
        willRefresh = YES;
        currentDate = [[currentFormatter stringFromDate:today] intValue];
        [currentFormatter release];
        formatChanged1 = NO;
        formatChanged2 = NO;
        formatChanged3 = NO;
    }
    else
        [currentFormatter release];

    if (willRefresh)
    {
        //recalculate
        LunarCalendar *lunarCal = [[LunarCalendar alloc] init];

        [lunarCal loadWithDate:today];

        [lunarCal InitializeValue];

        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianYear]] forKey:@"GregorianYear"];
        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianMonth]] forKey:@"GregorianMonth"];
        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianDay]] forKey:@"GregorianDay"];

        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal Weekday]] forKey:@"Weekday"];

        NSString *localizedTemp = @"";
        if (languageStrings && [languageStrings objectForKey:[lunarCal Constellation]])
            localizedTemp = [languageStrings objectForKey:[lunarCal Constellation]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal Constellation], @"LunarCalendar", localizedBundle, [lunarCal Constellation]) forKey:@"Constellation"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"Constellation"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal YearHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal YearHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal YearHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal YearHeavenlyStem]) forKey:@"YearHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"YearHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal YearEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal YearEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal YearEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal YearEarthlyBranch]) forKey:@"YearEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"YearEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal MonthHeavenlyStem]) forKey:@"MonthHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal MonthEarthlyBranch]) forKey:@"MonthEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal MonthHeavenlyStem]) forKey:@"MonthHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal MonthEarthlyBranch]) forKey:@"MonthEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal DayHeavenlyStem]) forKey:@"DayHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"DayHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal DayEarthlyBranch]) forKey:@"DayEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"DayEarthlyBranch"];
            localizedTemp = @"";
        }

        [dateInfo setObject:[NSNumber numberWithBool:[lunarCal IsLeap]] forKey:@"IsLeap"];

        if (languageStrings && [languageStrings objectForKey:[lunarCal ZodiacLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal ZodiacLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal ZodiacLunar], @"LunarCalendar", localizedBundle, [lunarCal ZodiacLunar]) forKey:@"Zodiac"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"Zodiac"];
            localizedTemp = @"";
        }

        if ([lunarCal SolarTermTitle] && [[lunarCal SolarTermTitle] length] > 0)
        {
            if (languageStrings && [languageStrings objectForKey:[lunarCal SolarTermTitle]])
                localizedTemp = [languageStrings objectForKey:[lunarCal SolarTermTitle]];
            if ([localizedTemp length] == 0)
                [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal SolarTermTitle], @"LunarCalendar", localizedBundle, [lunarCal SolarTermTitle]) forKey:@"SolarTerm"];
            else
            {
                [dateInfo setObject:localizedTemp forKey:@"SolarTerm"];
                localizedTemp = @"";
            }
        }
        else
            [dateInfo setObject:@"" forKey:@"SolarTerm"];

        if (languageStrings && [languageStrings objectForKey:@"LeapTitle"])
            localizedTemp = [languageStrings objectForKey:@"LeapTitle"];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle(@"LeapTitle", @"LunarCalendar", localizedBundle, @"LeapTitle") forKey:@"LeapTitle"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LeapTitle"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], @"LunarCalendar", localizedBundle, [lunarCal MonthLunar]) forKey:@"LunarMonth"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LunarMonth"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayLunar], @"LunarCalendar", localizedBundle, [lunarCal DayLunar]) forKey:@"LunarDay"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LunarDay"];
            localizedTemp = @"";
        }

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

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIView *list = [[objc_getClass("SBBulletinListController") sharedInstance] listView];
        for (UIGestureRecognizer *gr in list.gestureRecognizers)
            gr.cancelsTouchesInView = NO;
    }
}

- (void)viewDidDisappear
{
    //Save settings
    if (switchGesture == 0)
        pageNo = (int)(scrollView.contentOffset.x / (_weeView.superview.bounds.size.width - 12));

    [preferences setValue:[NSNumber numberWithInt:pageNo] forKey:@"PageNo"];

    [preferences writeToFile:PreferencesFilePath atomically:YES];
}

- (float)viewHeight
{
    return viewHeight;
}

@end

@implementation LunarCalendarWidgetController

- (id)init
{
    if (kCFCoreFoundationVersionNumber < 847.20)
        return nil;
    
    if ((self = [super init]))
    {
        localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LunarCalendar.bundle/"];

        LoadPreferences();

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

        dateInfo = [[NSMutableDictionary alloc] initWithCapacity:17];

        _initWidth = [self getWidth];
        _initHeight = viewHeight + 10;

        _lastWidth = _initWidth;

        _weeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _initWidth, _initHeight)];
		_weeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, _initWidth, viewHeight)];
        scrollView.pagingEnabled = YES;
        scrollView.bounces = YES;
        scrollView.showsHorizontalScrollIndicator = NO;

        pageView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _initWidth, viewHeight)];
        pageView1.backgroundColor = [UIColor clearColor];
        pageView1.textColor = [UIColor whiteColor];
        pageView1.text = @"";
        pageView1.textAlignment = NSTextAlignmentCenter;
        [pageView1 setFont:[UIFont boldSystemFontOfSize:fontSize]];
        pageView1.shadowColor = [UIColor blackColor];
        pageView1.shadowOffset = CGSizeMake(1.0,1.0);
        [pageView1 setNumberOfLines:1];
        pageView1.adjustsFontSizeToFitWidth = YES;
        [scrollView addSubview:pageView1];
        [pageView1 release];

        pageView2 = [[UILabel alloc] initWithFrame:CGRectMake(_initWidth, 5, _initWidth, viewHeight)];
        pageView2.backgroundColor = [UIColor clearColor];
        pageView2.textColor = [UIColor whiteColor];
        pageView2.text = @"";
        pageView2.textAlignment = NSTextAlignmentCenter;
        [pageView2 setFont:[UIFont boldSystemFontOfSize:fontSize]];
        pageView2.shadowColor = [UIColor blackColor];
        pageView2.shadowOffset = CGSizeMake(1.0,1.0);
        [pageView2 setNumberOfLines:1];
        pageView2.adjustsFontSizeToFitWidth = YES;
        [scrollView addSubview:pageView2];
        [pageView2 release];

        pageView3 = [[UILabel alloc] initWithFrame:CGRectMake(_initWidth * 2, 5, _initWidth, viewHeight)];
        pageView3.backgroundColor = [UIColor clearColor];
        pageView3.textColor = [UIColor whiteColor];
        pageView3.text = @"";
        pageView3.textAlignment = NSTextAlignmentCenter;
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

        scrollView.contentSize = CGSizeMake(_initWidth * 3, viewHeight);
        scrollView.showsHorizontalScrollIndicator = NO;

        [_weeView addSubview:scrollView];
        [scrollView release];

		self.view = _weeView;
        
        [self updateLunarInfo];
	}
	return self;
}

static UIView *getSuperTableView(UIView *view)
{
    if (view)
    {
        if ([view isKindOfClass:[UITableView class]])
            return view;
        else
            return getSuperTableView(view.superview);
    }
    else
        return nil;
}

- (CGFloat)getWidth
{
    if (_weeView)
    {
        UIView *tableView = getSuperTableView(_weeView);
        if (tableView)
            return tableView.frame.size.width;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 580.0f;
    else
        return 280.0f;
}

- (CGSize)preferredViewSize
{
    return CGSizeMake(_initWidth, _initHeight);
}

-(void)dealloc
{
    if (languageStrings)
        [languageStrings release];
    [dateInfo release];
    [localizedBundle release];
    [preferences release];
    [_weeView release];
    [super dealloc];
}

- (void)hostDidDismiss
{
	[super hostDidDismiss];

    if (switchGesture == 0)
        pageNo = (int)(scrollView.contentOffset.x / _weeView.superview.bounds.size.width);
    
    [preferences setValue:[NSNumber numberWithInt:pageNo] forKey:@"PageNo"];
    
    [preferences writeToFile:PreferencesFilePath atomically:YES];
}

- (void)hostDidPresent
{
	[super hostDidPresent];
    
    [self updateLunarInfo];
}

- (void)updateLunarInfo
{
    CGFloat viewWidth = [self getWidth];
    
    _weeView.frame = CGRectMake(0, 0, viewWidth, viewHeight + 10);
    
    scrollView.frame = CGRectMake(0, 5, viewWidth, viewHeight);
    
    pageView1.frame = CGRectMake(0, 5, viewWidth, viewHeight);
    pageView2.frame = CGRectMake(viewWidth, 5, viewWidth, viewHeight);
    pageView3.frame = CGRectMake(viewWidth * 2, 5, viewWidth, viewHeight);
    
    scrollView.contentSize = CGSizeMake(viewWidth * 3, viewHeight);
    
    bigButton.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width * 3, scrollView.frame.size.height);
    
    if (fontSizeChanged)
    {
        [pageView1 setFont:[UIFont boldSystemFontOfSize:fontSize]];
        [pageView2 setFont:[UIFont boldSystemFontOfSize:fontSize]];
        [pageView3 setFont:[UIFont boldSystemFontOfSize:fontSize]];
        fontSizeChanged = NO;
    }
    
    if (viewHeightChanged || _lastWidth != viewWidth)
    {
        pageView1.frame = CGRectMake(0, 5, scrollView.frame.size.width, viewHeight);
        pageView2.frame = CGRectMake(scrollView.frame.size.width, 5, scrollView.frame.size.width, viewHeight);
        pageView3.frame = CGRectMake(scrollView.frame.size.width * 2, 5, scrollView.frame.size.width, viewHeight);

        _lastWidth = viewWidth;

        [self invalidatePreferredViewSize];

        viewHeightChanged = NO;
    }
    
    BOOL willRefresh = NO;
    
    NSDate *today = [NSDate date];
    
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    
    [currentFormatter setDateFormat:@"yyyyMMdd"];
    
    if ([[currentFormatter stringFromDate:today] intValue] != currentDate || formatChanged1 || formatChanged2 || formatChanged3)
    {
        willRefresh = YES;
        currentDate = [[currentFormatter stringFromDate:today] intValue];
        [currentFormatter release];
        formatChanged1 = NO;
        formatChanged2 = NO;
        formatChanged3 = NO;
    }
    else
        [currentFormatter release];
    
    if (willRefresh)
    {
        //recalculate
        LunarCalendar *lunarCal = [[LunarCalendar alloc] init];

        [lunarCal loadWithDate:today];

        [lunarCal InitializeValue];

        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianYear]] forKey:@"GregorianYear"];
        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianMonth]] forKey:@"GregorianMonth"];
        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal GregorianDay]] forKey:@"GregorianDay"];

        [dateInfo setObject:[NSNumber numberWithInt:[lunarCal Weekday]] forKey:@"Weekday"];

        NSString *localizedTemp = @"";
        if (languageStrings && [languageStrings objectForKey:[lunarCal Constellation]])
            localizedTemp = [languageStrings objectForKey:[lunarCal Constellation]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal Constellation], @"LunarCalendar", localizedBundle, [lunarCal Constellation]) forKey:@"Constellation"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"Constellation"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal YearHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal YearHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal YearHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal YearHeavenlyStem]) forKey:@"YearHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"YearHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal YearEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal YearEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal YearEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal YearEarthlyBranch]) forKey:@"YearEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"YearEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal MonthHeavenlyStem]) forKey:@"MonthHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal MonthEarthlyBranch]) forKey:@"MonthEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal MonthHeavenlyStem]) forKey:@"MonthHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal MonthEarthlyBranch]) forKey:@"MonthEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"MonthEarthlyBranch"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayHeavenlyStem]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayHeavenlyStem]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayHeavenlyStem], @"LunarCalendar", localizedBundle, [lunarCal DayHeavenlyStem]) forKey:@"DayHeavenlyStem"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"DayHeavenlyStem"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayEarthlyBranch]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayEarthlyBranch]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayEarthlyBranch], @"LunarCalendar", localizedBundle, [lunarCal DayEarthlyBranch]) forKey:@"DayEarthlyBranch"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"DayEarthlyBranch"];
            localizedTemp = @"";
        }

        [dateInfo setObject:[NSNumber numberWithBool:[lunarCal IsLeap]] forKey:@"IsLeap"];

        if (languageStrings && [languageStrings objectForKey:[lunarCal ZodiacLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal ZodiacLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal ZodiacLunar], @"LunarCalendar", localizedBundle, [lunarCal ZodiacLunar]) forKey:@"Zodiac"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"Zodiac"];
            localizedTemp = @"";
        }

        if ([lunarCal SolarTermTitle] && [[lunarCal SolarTermTitle] length] > 0)
        {
            if (languageStrings && [languageStrings objectForKey:[lunarCal SolarTermTitle]])
                localizedTemp = [languageStrings objectForKey:[lunarCal SolarTermTitle]];
            if ([localizedTemp length] == 0)
                [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal SolarTermTitle], @"LunarCalendar", localizedBundle, [lunarCal SolarTermTitle]) forKey:@"SolarTerm"];
            else
            {
                [dateInfo setObject:localizedTemp forKey:@"SolarTerm"];
                localizedTemp = @"";
            }
        }
        else
            [dateInfo setObject:@"" forKey:@"SolarTerm"];

        if (languageStrings && [languageStrings objectForKey:@"LeapTitle"])
            localizedTemp = [languageStrings objectForKey:@"LeapTitle"];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle(@"LeapTitle", @"LunarCalendar", localizedBundle, @"LeapTitle") forKey:@"LeapTitle"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LeapTitle"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal MonthLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal MonthLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal MonthLunar], @"LunarCalendar", localizedBundle, [lunarCal MonthLunar]) forKey:@"LunarMonth"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LunarMonth"];
            localizedTemp = @"";
        }

        if (languageStrings && [languageStrings objectForKey:[lunarCal DayLunar]])
            localizedTemp = [languageStrings objectForKey:[lunarCal DayLunar]];
        if ([localizedTemp length] == 0)
            [dateInfo setObject:NSLocalizedStringFromTableInBundle([lunarCal DayLunar], @"LunarCalendar", localizedBundle, [lunarCal DayLunar]) forKey:@"LunarDay"];
        else
        {
            [dateInfo setObject:localizedTemp forKey:@"LunarDay"];
            localizedTemp = @"";
        }

        [lunarCal release];
    }
    
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.x = 0;
    [scrollView setContentOffset:contentOffset animated:NO];
    
    [pageView1 setText:[self customDatePrinter:pageNo]];
    scrollView.scrollEnabled = NO;
}

- (void)dismissAlert:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        NSString *message = NSLocalizedStringFromTableInBundle(@"Copied to clipboard.", @"LunarCalendar", localizedBundle, @"Copied to clipboard.");

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];

        [alert show];

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@", pageView1.text];

        [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:1.5];

        [alert release];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 1)
        [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded && switchGesture == 2)
        [self performSelector:@selector(refreshLabel) withObject:nil afterDelay:0.3];
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
    template = [template stringByReplacingOccurrencesOfString:@"[GY]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianYear"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[GM]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianMonth"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[GD]" withString:[NSString stringWithFormat:@"%d", [[dateInfo objectForKey:@"GregorianDay"] intValue]]];
    template = [template stringByReplacingOccurrencesOfString:@"[LM]" withString:[dateInfo objectForKey:@"LunarMonth"]];
    template = [template stringByReplacingOccurrencesOfString:@"[LD]" withString:[dateInfo objectForKey:@"LunarDay"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HY]" withString:[dateInfo objectForKey:@"YearHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[EY]" withString:[dateInfo objectForKey:@"YearEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HM]" withString:[dateInfo objectForKey:@"MonthHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[EM]" withString:[dateInfo objectForKey:@"MonthEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[HD]" withString:[dateInfo objectForKey:@"DayHeavenlyStem"]];
    template = [template stringByReplacingOccurrencesOfString:@"[ED]" withString:[dateInfo objectForKey:@"DayEarthlyBranch"]];
    template = [template stringByReplacingOccurrencesOfString:@"[L]" withString:([[dateInfo objectForKey:@"IsLeap"] boolValue] ? [dateInfo objectForKey:@"LeapTitle"] : @"")];
    template = [template stringByReplacingOccurrencesOfString:@"[C]" withString:[dateInfo objectForKey:@"Constellation"]];
    template = [template stringByReplacingOccurrencesOfString:@"[Z]" withString:[dateInfo objectForKey:@"Zodiac"]];
    template = [template stringByReplacingOccurrencesOfString:@"[S]" withString:[dateInfo objectForKey:@"SolarTerm"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    template = [template stringByReplacingOccurrencesOfString:@"[WD]" withString:[[dateFormatter weekdaySymbols] objectAtIndex:([[dateInfo objectForKey:@"Weekday"] intValue] + 6) % 7]];
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
        return ([displayDate1 length] == 0) ? [NSString stringWithFormat:@"%@  %@", date, [dateInfo objectForKey:@"Constellation"]] : [self calculateDate:displayDate1];
    else if (format == 1)
        return [self calculateDate:displayDate2];
    else
        return [self calculateDate:displayDate3];
}

@end
