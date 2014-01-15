//
//  LunarCalendar.h
//
//  Created by Merlin on 12-3-13.
//  Copyright (c) 2012-2014 autopear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BBWeeAppController-Protocol.h"
#import "LunarCalendar/LunarCalendar.h"
#import "_SBUIWidgetViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#define lcAlignLeft NSTextAlignmentLeft
#define lcAlignCenter NSTextAlignmentCenter
#define lcAlignRight NSTextAlignmentRight
#else
#define lcAlignLeft UITextAlignmentLeft
#define lcAlignCenter UITextAlignmentCenter
#define lcAlignRight UITextAlignmentRight
#endif

#define PreferencesChangedNotification "com.autopear.lunarcalendar/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.lunarcalendar.plist"]

//Controller for iOS 5 & 6
@interface LunarCalendarController : UIViewController <BBWeeAppController> {
    UIView *_weeView;
    UIImageView *_backgroundImageView;
    UIScrollView *_scrollView;
    UILabel *_pageView1;
    UILabel *_pageView2;
    UILabel *_pageView3;
    UIAlertView *_alert;
    unsigned int _currentDate;
    NSMutableDictionary *_dateInfo;
}
- (id)init;
- (void)dealloc;
- (UIView *)view;
- (CGFloat)bulletinViewWidth;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
- (void)singleTap:(UITapGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;
- (NSString *)customDatePrinter:(int)format;
- (void)dismissAlert;
- (void)refreshLabel;
- (NSString *)calculateDate:(NSString *)template;
- (void)viewWillAppear;
- (void)viewWillDisappear;
@end

//Controller for iOS 7
@interface LunarCalendarWidgetController: _SBUIWidgetViewController {
    UIView *_weeView;
    UIScrollView *_scrollView;
    UILabel *_pageView1;
    UILabel *_pageView2;
    UILabel *_pageView3;
    UIAlertView *_alert;
    unsigned int _currentDate;
    NSMutableDictionary *_dateInfo;
}
- (id)init;
- (void)dealloc;
- (UIView *)view;
- (CGFloat)bulletinViewWidth;
- (CGSize)preferredViewSize;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
- (void)singleTap:(UITapGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;
- (NSString *)customDatePrinter:(int)format;
- (void)dismissAlert;
- (void)refreshLabel;
- (NSString *)calculateDate:(NSString *)template;
- (void)updateDate;
- (void)hostWillPresent;
- (void)hostWillDismiss;
@end

static NSBundle *localizedBundle = nil;
static NSDictionary *languageStrings = nil;
static double viewHeight = 28.0f;
static int fontSize = 18;
static int fontStyle = 1;
static int switchGesture = 0;
static int textAlign = 1;
static int pageNo = 0;
static CGFloat sideMargin = 0;
static CGFloat colorRed = 1.0f;
static CGFloat colorGreen = 1.0f;
static CGFloat colorBlue = 1.0f;
static CGFloat colorAlpha = 1.0f;
static CGFloat shadowWidth = 0.0f;
static CGFloat shadowHeight = 0.0f;
static CGFloat shadowRed = 0.0f;
static CGFloat shadowGreen = 0.0f;
static CGFloat shadowBlue = 0.0f;
static CGFloat shadowAlpha = 1.0f;
static BOOL viewHeightChanged = NO;
static BOOL fontChanged = NO;
static BOOL formatChanged1 = NO;
static BOOL formatChanged2 = NO;
static BOOL formatChanged3 = NO;
static BOOL textAlignChanged = NO;
static BOOL sideMarginChanged = NO;
static BOOL textColorChanged = NO;
static BOOL shadowChaned = NO;
static NSString *displayDate1 = @"";
static NSString *displayDate2 = @"";
static NSString *displayDate3 = @"";

static void LoadPreferences()
{
    if (languageStrings)
    {
        [languageStrings release];
        languageStrings = nil;
    }
    
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    if (preferences) {
        NSString *readLanguage = [preferences objectForKey:@"Language"] ? [preferences objectForKey:@"Language"] : @"default";
        if (![readLanguage isEqualToString:@"default"]) {
            NSString *languagePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/LunarCalendar.bundle/%@.lproj/LunarCalendar.strings", readLanguage];
            if ([[NSFileManager defaultManager] fileExistsAtPath:languagePath])
                languageStrings = [[NSDictionary alloc] initWithContentsOfFile:languagePath];
        }

        int readSwitchGesture = [preferences objectForKey:@"SwitchGesture"] ? [[preferences objectForKey:@"SwitchGesture"] intValue] : 0;
        if (readSwitchGesture > 2 || readSwitchGesture < 0)
            readSwitchGesture = 0;
        if (readSwitchGesture != switchGesture)
            switchGesture = readSwitchGesture;

        double readViewHeight = [preferences objectForKey:@"ViewHeight"] ? [[preferences objectForKey:@"ViewHeight"] doubleValue] : 28.0f;
        if (readViewHeight < 20.0f || readViewHeight > 60.0f)
            readViewHeight = 28.0f;
        if (readViewHeight != viewHeight) {
            viewHeightChanged = YES;
            viewHeight = readViewHeight;
        }

        int readFontSize = [preferences objectForKey:@"FontSize"] ? [[preferences objectForKey:@"FontSize"] intValue] : 18;
        if (readFontSize < 15 || readFontSize > 40)
            readFontSize = 18;
        if (readFontSize != fontSize) {
            fontChanged = YES;
            fontSize = readFontSize;
        }

        int readFontStyle = [preferences objectForKey:@"FontStyle"] ? [[preferences objectForKey:@"FontStyle"] intValue] : (kCFCoreFoundationVersionNumber < 847.20 ? 1 : 0);
        if (readFontStyle < 0 || readFontStyle > 2)
            readFontStyle = 1;
        if (readFontStyle != fontStyle) {
            fontChanged = YES;
            fontStyle = readFontStyle;
        }

        NSString *readFormat1 = [preferences objectForKey:@"CustomFormat1"] ? [preferences objectForKey:@"CustomFormat1"] : @"";
        if (![readFormat1 isEqualToString:displayDate1]) {
            formatChanged1 = YES;
            displayDate1 = [readFormat1 retain];
        }

        NSString *readFormat2 = [preferences objectForKey:@"CustomFormat2"] ? [preferences objectForKey:@"CustomFormat2"] : @"";
        if ([readFormat2 length] == 0) {
            if (languageStrings && [languageStrings objectForKey:@"DateFormatNormal"])
                readFormat2 = [languageStrings objectForKey:@"DateFormatNormal"];
            if ([readFormat2 length] == 0)
                readFormat2 =  NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]");
        }

        if (![readFormat2 isEqualToString:displayDate2]) {
            formatChanged2 = YES;
            displayDate2 = [readFormat2 retain];
        }

        NSString *readFormat3 = [preferences objectForKey:@"CustomFormat3"] ? [preferences objectForKey:@"CustomFormat3"] : @"";
        if ([readFormat3 length] == 0) {
            if (languageStrings && [languageStrings objectForKey:@"DateFormatTraditional"])
                readFormat3 = [languageStrings objectForKey:@"DateFormatTraditional"];
            if ([readFormat3 length] == 0)
                readFormat3 =  NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]");
        }

        if (![readFormat3 isEqualToString:displayDate3]) {
            formatChanged3 = YES;
            displayDate3 = [readFormat3 retain];
        }
        
        int readTextAlign = [preferences objectForKey:@"TextAlign"] ? [[preferences objectForKey:@"TextAlign"] intValue] : (kCFCoreFoundationVersionNumber < 847.20 ? 1 : 0);
        if (readTextAlign < 0 || readTextAlign > 2)
            readTextAlign = kCFCoreFoundationVersionNumber < 847.20 ? 1 : 0;
        if (readTextAlign != textAlign) {
            textAlignChanged = YES;
            textAlign = readTextAlign;
        }
        
        CGFloat readSideMargin = [preferences objectForKey:@"SideMargin"] ? [[preferences objectForKey:@"SideMargin"] doubleValue] : (kCFCoreFoundationVersionNumber < 847.20 ? 0 : 45.0f);
        if (readSideMargin < 0)
            readSideMargin = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (readSideMargin > 250.0f)
                readSideMargin = 250.0f;
        } else {
            if (readSideMargin > 150.0f)
                readSideMargin = 150.0f;
        }
        if (readSideMargin != sideMargin) {
            sideMarginChanged = YES;
            sideMargin = readSideMargin;
        }

        CGFloat readColorRed = [preferences objectForKey:@"ColorRed"] ? [[preferences objectForKey:@"ColorRed"] floatValue] : 1.0f;
        if (readColorRed < 0.0f || readColorRed > 1.0f)
            readColorRed = 1.0f;
        CGFloat readColorGreen = [preferences objectForKey:@"ColorGreen"] ? [[preferences objectForKey:@"ColorGreen"] floatValue] : 1.0f;
        if (readColorGreen < 0.0f || readColorGreen > 1.0f)
            readColorGreen = 1.0f;
        CGFloat readColorBlue = [preferences objectForKey:@"ColorBlue"] ? [[preferences objectForKey:@"ColorBlue"] floatValue] : 1.0f;
        if (readColorBlue < 0.0f || readColorBlue > 1.0f)
            readColorBlue = 1.0f;
        CGFloat readColorAlpha = [preferences objectForKey:@"ColorAlpha"] ? [[preferences objectForKey:@"ColorAlpha"] floatValue] : 1.0f;
        if (readColorAlpha < 0.0f || readColorAlpha > 1.0f)
            readColorAlpha = 1.0f;
        if (readColorRed != colorRed || readColorGreen != colorGreen || readColorBlue != colorBlue || readColorAlpha != colorAlpha) {
            textColorChanged = YES;
            colorRed = readColorRed;
            colorGreen = readColorGreen;
            colorBlue = readColorBlue;
            colorAlpha = readColorAlpha;
        }

        CGFloat readShadowWidth = [preferences objectForKey:@"ShadowWidth"] ? [[preferences objectForKey:@"ShadowWidth"] floatValue] : (kCFCoreFoundationVersionNumber < 847.20 ? 1.0f : 0.0f);
        if (readShadowWidth < -5.0f)
            readShadowWidth = -5.0f;
        if (readShadowWidth > 5.0f)
            readShadowWidth = 5.0f;
        CGFloat readShadowHeight = [preferences objectForKey:@"ShadowHeight"] ? [[preferences objectForKey:@"ShadowHeight"] floatValue] : (kCFCoreFoundationVersionNumber < 847.20 ? 1.0f : 0.0f);
        if (readShadowHeight < -5.0f)
            readShadowHeight = -5.0f;
        if (readShadowHeight > 5.0f)
            readShadowHeight = 5.0f;

        CGFloat readShadowRed = [preferences objectForKey:@"ShadowRed"] ? [[preferences objectForKey:@"ShadowRed"] floatValue] : 0.0f;
        if (readShadowRed < 0.0f || readShadowRed > 1.0f)
            readShadowRed = 1.0f;
        CGFloat readShadowGreen = [preferences objectForKey:@"ShadowGreen"] ? [[preferences objectForKey:@"ShadowGreen"] floatValue] : 0.0f;
        if (readShadowGreen < 0.0f || readShadowGreen > 1.0f)
            readShadowGreen = 1.0f;
        CGFloat readShadowBlue = [preferences objectForKey:@"ShadowBlue"] ? [[preferences objectForKey:@"ShadowBlue"] floatValue] : 0.0f;
        if (readShadowBlue < 0.0f || readShadowBlue > 1.0f)
            readShadowBlue = 1.0f;
        CGFloat readShadowAlpha = [preferences objectForKey:@"ShadowAlpha"] ? [[preferences objectForKey:@"ShadowAlpha"] floatValue] : 1.0f;
        if (readShadowAlpha < 0.0f || readShadowAlpha > 1.0f)
            readShadowAlpha = 1.0f;
        if (readShadowWidth != shadowWidth || readShadowHeight != shadowHeight || readShadowRed != shadowRed || readShadowGreen != shadowGreen || readShadowBlue != shadowBlue || readShadowAlpha != shadowAlpha) {
            shadowChaned = YES;
            shadowWidth = readShadowWidth;
            shadowHeight = readShadowHeight;
            shadowRed = readShadowRed;
            shadowGreen = readShadowGreen;
            shadowBlue = readShadowBlue;
            shadowAlpha = readShadowAlpha;
        }
    } else {
        displayDate1 = @"";
        displayDate2 = [NSLocalizedStringFromTableInBundle(@"DateFormatNormal", @"LunarCalendar", localizedBundle, @"[HY][EY]/[LM]/[LD] [Z]") retain];
        displayDate3 = [NSLocalizedStringFromTableInBundle(@"DateFormatTraditional", @"LunarCalendar", localizedBundle, @"[HY][EY]/[HM][EM]/[HD][ED]") retain];
        switchGesture = kCFCoreFoundationVersionNumber < 847.20 ? 0 : 1;
        fontSize = 18;
        fontStyle = (kCFCoreFoundationVersionNumber < 847.20 ? 1 : 0);
        textAlign = (kCFCoreFoundationVersionNumber < 847.20 ? 1 : 0);
        sideMargin = (kCFCoreFoundationVersionNumber < 847.20 ? 0 : 45.0f);
        colorRed = 1.0f;
        colorGreen = 1.0f;
        colorBlue = 1.0f;
        colorAlpha = 1.0f;
        shadowWidth = (kCFCoreFoundationVersionNumber < 847.20 ? 1.0f : 0.0f);
        shadowHeight = (kCFCoreFoundationVersionNumber < 847.20 ? 1.0f : 0.0f);
        shadowRed = 0.0f;
        shadowGreen = 0.0f;
        shadowBlue = 0.0f;
        shadowAlpha = 1.0f;
    }
    [preferences release];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LoadPreferences();
}
