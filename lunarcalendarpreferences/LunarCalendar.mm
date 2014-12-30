#import <Preferences/Preferences.h>
#import <objc/runtime.h>

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.autopear.lunarcalendar.plist"
#define SETTIGNS_CHANGED "com.autopear.lunarcalendar/prefs"

@interface PSSliderTableCell : PSControlTableCell
@end

@interface LunarCalendarListController: PSListController <UIAlertViewDelegate> {
    NSString *_confirmContent;
    NSString *_confirmOK;
    NSString *_confirmCancel;
}
- (void)updateInterface;
@end

@implementation LunarCalendarListController

- (id)init {
	if ((self = [super init])) {
        NSBundle *localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LunarCalendar.bundle/"];
        _confirmContent = [NSLocalizedStringFromTableInBundle(@"Are you sure you want to reset all settings to default?", @"LunarCalendar", localizedBundle, @"Are you sure you want to reset all settings to default?") retain];
        _confirmOK = [NSLocalizedStringFromTableInBundle(@"OK", @"LunarCalendar", localizedBundle, @"OK") retain];
        _confirmCancel = [NSLocalizedStringFromTableInBundle(@"Cancel", @"LunarCalendar", localizedBundle, @"Cancel") retain];
        [localizedBundle release];
	}

	return self;
}

- (void)dealloc {
    [_confirmContent release];
    [_confirmOK release];
    [_confirmCancel release];
	[super dealloc];
}

- (id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        for (PSSpecifier *specifier in [self loadSpecifiersFromPlistName:@"LunarCalendar" target:self]) {
            if ([specifier propertyForKey:@"key"]) {
                NSString *key = [specifier propertyForKey:@"key"];
                if ([key isEqualToString:@"SwitchGesture"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [specifier setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 5 & 6
                    else
                        [specifier setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 7 & 8
                }
                if ([key isEqualToString:@"TextAlign"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [specifier setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [specifier setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7 & 8
                }
                if ([key isEqualToString:@"SideMargin"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20) {
                        //iOS 5 & 6
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            [specifier setProperty:[NSNumber numberWithInt:250] forKey:@"max"];
                        else
                            [specifier setProperty:[NSNumber numberWithInt:150] forKey:@"max"];
                        [specifier setProperty:[NSNumber numberWithInt:0] forKey:@"default"];
                    } else {
                        //iOS 7 & 8
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            [specifier setProperty:[NSNumber numberWithInt:250] forKey:@"max"];
                        else
                            [specifier setProperty:[NSNumber numberWithInt:150] forKey:@"max"];
                        [specifier setProperty:[NSNumber numberWithInt:45] forKey:@"default"];
                    }
                }
            }
            [specifiers addObject:specifier];
        }
        _specifiers = [specifiers retain];
    }

	return _specifiers;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateInterface];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateInterface];
}

- (void)updateInterface {
    UITableViewCell *fontCell = (UITableViewCell *)[self cachedCellForSpecifierID:@"Font"];
    NSString *fontName = fontCell.detailTextLabel.text;
    if ([fontName length] > 0)
        fontCell.detailTextLabel.font = [UIFont fontWithName:fontName size:[UIFont smallSystemFontSize]];

    if (kCFCoreFoundationVersionNumber < 847.20) {
        NSArray *sliderCells = [NSArray arrayWithObjects:@"ViewHeight", @"SideMargin", nil];

        for (NSString *cellId in sliderCells) {
            PSSliderTableCell *cell = (PSSliderTableCell *)[self cachedCellForSpecifierID:cellId];
            for (UIView *view in cell.control.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    CGRect labelFrame = view.frame;
                    labelFrame.origin.x = cell.control.frame.size.width - labelFrame.size.width;
                    view.frame = labelFrame;
                }
            }
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    if ([dict objectForKey:[specifier propertyForKey:@"key"]])
        return [dict objectForKey:[specifier propertyForKey:@"key"]];
    else
        return [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    [defaults setObject:value forKey:[specifier propertyForKey:@"key"]];
    [defaults writeToFile:PREFS_PATH atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTIGNS_CHANGED), NULL, NULL, YES);
}

- (void)resetDefault:(PSSpecifier*)specifier {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:_confirmContent
                                                   delegate:self
                                          cancelButtonTitle:_confirmCancel
                                          otherButtonTitles:_confirmOK, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!alertView)
        return;

    [alertView release];

    if (buttonIndex == 1) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:PREFS_PATH])
            return;

        NSMutableDictionary *dict =  [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH];

        NSObject *format1 = [dict objectForKey:@"CustomFormat1"];
        NSObject *format2 = [dict objectForKey:@"CustomFormat2"];
        NSObject *format3 = [dict objectForKey:@"CustomFormat3"];
        NSObject *pageNo = [dict objectForKey:@"PageNo"];

        [dict removeAllObjects];

        if (format1)
            [dict setObject:format1 forKey:@"CustomFormat1"];
        if (format2)
            [dict setObject:format2 forKey:@"CustomFormat2"];
        if (format3)
            [dict setObject:format3 forKey:@"CustomFormat3"];
        if (pageNo)
            [dict setObject:pageNo forKey:@"PageNo"];

        [dict setObject:(kCFCoreFoundationVersionNumber < 847.20 ? @"Helvetica-Bold" : @"Helvetica") forKey:@"FontName"];

        [dict writeToFile:PREFS_PATH atomically:YES];

        [self reloadSpecifiers];

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTIGNS_CHANGED), NULL, NULL, YES);
    }
}

@end

@interface LunarCalendarTextStyleListController : PSListController- (void)updateInterface;
@end

@implementation LunarCalendarTextStyleListController

- (id)init {
	if ((self = [super init])) {
	}

	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (id)specifiers {
	if(_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        for (PSSpecifier *specifier in [self loadSpecifiersFromPlistName:@"TextStyle" target:self]) {
            if ([specifier propertyForKey:@"key"]) {
                NSString *key = [specifier propertyForKey:@"key"];
                if ([key isEqualToString:@"FontName"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [specifier setProperty:@"Helvetica-Bold" forKey:@"default"]; //iOS 5 & 6
                    else
                        [specifier setProperty:@"Helvetica" forKey:@"default"]; //iOS 7 & 8
                }
                if ([key isEqualToString:@"ShadowWidth"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [specifier setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [specifier setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7 & 8
                }
                if ([key isEqualToString:@"ShadowHeight"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [specifier setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [specifier setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7 & 8
                }
            }
            [specifiers addObject:specifier];
        }
        _specifiers = [specifiers retain];
    }
	return _specifiers;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateInterface];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateInterface];
}

- (void)updateInterface {
    NSDictionary *_settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    NSString *fontName = [_settings objectForKey:@"FontName"];
    UITableViewCell *fontCell = (UITableViewCell *)[self cachedCellForSpecifierID:@"Font"];
    if ([fontName length] > 0) {
        fontCell.detailTextLabel.font = [UIFont fontWithName:fontName size:[UIFont smallSystemFontSize]];
        fontCell.detailTextLabel.text = fontName;
    }

    if (kCFCoreFoundationVersionNumber < 847.20) {
        NSArray *sliderCells = [NSArray arrayWithObjects:@"FontSize", @"ColorRed", @"ColorGreen", @"ColorBlue", @"ColorAlpha", @"ShadowWidth", @"ShadowHeight", @"ShadowRed", @"ShadowGreen", @"ShadowBlue", @"ShadowAlpha", nil];

        for (NSString *cellId in sliderCells) {
            PSSliderTableCell *cell = (PSSliderTableCell *)[self cachedCellForSpecifierID:cellId];
            for (UIView *view in cell.control.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    CGRect labelFrame = view.frame;
                    labelFrame.origin.x = cell.control.frame.size.width - labelFrame.size.width;
                    view.frame = labelFrame;
                }
            }
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    if ([dict objectForKey:[specifier propertyForKey:@"key"]])
        return [dict objectForKey:[specifier propertyForKey:@"key"]];
    else
        return [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    [defaults setObject:value forKey:[specifier propertyForKey:@"key"]];
    [defaults writeToFile:PREFS_PATH atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTIGNS_CHANGED), NULL, NULL, YES);
}

@end

@interface LunarCalendarSpecificationsListController: PSListController
@end

@implementation LunarCalendarSpecificationsListController
- (id)init {
	if ((self = [super init])) {
	}

	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Specifications" target:self] retain];

        if (kCFCoreFoundationVersionNumber >= 847.20) {
            for (PSSpecifier *specifier in _specifiers) {
                NSString *specId = [specifier propertyForKey:@"id"];
                if (specId && [specId isEqualToString:@"COPYRIGHT"])
                    continue;

                NSString *labelText = specifier.name;
                [specifier setProperty:labelText forKey:@"footerText"];
                specifier.name = nil;
            }
        }
    }
	return _specifiers;
}

@end

@interface LunarCalendarMoreInfoListController: PSListController
@end

@implementation LunarCalendarMoreInfoListController

- (id)init {
	if ((self = [super init])) {
	}

	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (id)specifiers {
	if(_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        for (PSSpecifier *specifier in [self loadSpecifiersFromPlistName:@"MoreInfo" target:self]) {
            NSString *specId = [specifier propertyForKey:@"id"];
            if (specId) {
                if (kCFCoreFoundationVersionNumber < 847.20) {
                    //iOS 5 & 6
                    if ([specId isEqualToString:@"SHAREWIDGET7_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET7_CELL"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET8_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET8_CELL"])
                        continue;
                } else if (kCFCoreFoundationVersionNumber < 1140.10) {
                    //iOS 7
                    if ([specId isEqualToString:@"LYRICSFORIPAD_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"LYRICSFORIPAD_CELL"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET8_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET8_CELL"])
                        continue;
                } else {
                    //iOS 8
                    if ([specId isEqualToString:@"LYRICSFORIPAD_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"LYRICSFORIPAD_CELL"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET7_GROUP"])
                        continue;
                    if ([specId isEqualToString:@"SHAREWIDGET7_CELL"])
                        continue;
                }
            }
            [specifiers addObject:specifier];
        }
        _specifiers = [specifiers retain];
    }
	return _specifiers;
}

- (void)openActionSlider:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.actionslider"]];
}

- (void)openWeeCloseApps:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.weecloseapps"]];
}

- (void)openIPAInstaller:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.installipa"]];
}

- (void)openLunarCalendar:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.lunarcalendar"]];
}

- (void)openRemoveBadges:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.removebadges"]];
}

- (void)openQuickShare:(PSSpecifier*)specifier {
    if (kCFCoreFoundationVersionNumber < 847.20) //iOS 5 & 6
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.quickshare"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.quickshare2"]];
}

- (void)openImListening:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.bigboss.imlistening"]];
}

- (void)openShareWidget7:(PSSpecifier*)specifier {
    if (kCFCoreFoundationVersionNumber >= 847.20 && kCFCoreFoundationVersionNumber < 1140.10)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.sharewidget7"]];
}

- (void)openShareWidget8:(PSSpecifier*)specifier {
    if (kCFCoreFoundationVersionNumber >= 1140.10)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.sharewidget8"]];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    if ([dict objectForKey:[specifier propertyForKey:@"key"]])
        return [dict objectForKey:[specifier propertyForKey:@"key"]];
    else
        return [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
    [defaults setObject:value forKey:[specifier propertyForKey:@"key"]];
    [defaults writeToFile:PREFS_PATH atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTIGNS_CHANGED), NULL, NULL, YES);
}

@end

@interface LunarCalendarFontListController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_fontList;
	NSInteger _selectedRow;
    NSString *_stringDefault;
    NSString *_stringTitle;
    NSString *_defaultFont;
}
@property (nonatomic, retain) NSMutableArray *fontList;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (void)refreshList;
@end

@implementation LunarCalendarFontListController

@synthesize fontList = _fontList;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {
        _defaultFont = [(kCFCoreFoundationVersionNumber < 847.20 ? @"Helvetica-Bold" : @"Helvetica") retain];

        NSBundle *localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LunarCalendar.bundle/"];
        _stringDefault = [NSLocalizedStringFromTableInBundle(@" (Default)", @"TextStyle", localizedBundle, @" (Default)") retain];
        _stringTitle = [NSLocalizedStringFromTableInBundle(@"Font", @"TextStyle", localizedBundle, @"Font") retain];
        [localizedBundle release];

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];

        if (![[NSFileManager defaultManager] fileExistsAtPath:PREFS_PATH]) {
            NSMutableDictionary *defaultPrefs =  [NSMutableDictionary dictionaryWithObjectsAndKeys:_defaultFont, @"FontName", nil];
            NSData *data = [NSPropertyListSerialization dataFromPropertyList:defaultPrefs format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
            [defaultPrefs release];
            if (!data)
                return nil;
            if (![data writeToFile:PREFS_PATH atomically:YES])
                return nil;
        }

		[self refreshList];
	}
	return self;
}

- (void)refreshList {
	self.fontList = [NSMutableArray arrayWithCapacity:5];

    for (NSString *familyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName])
            [self.fontList addObject:fontName];
    }

    [self.fontList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSMutableDictionary *_settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH];

    NSString *fontName = [_settings objectForKey:@"FontName"];

	_selectedRow = [self.fontList indexOfObject:fontName];

	if (_selectedRow == NSNotFound) {
        fontName = _defaultFont;
		_selectedRow = [self.fontList indexOfObject:fontName];
        [_settings setObject:fontName forKey:@"FontName"];
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
        if (!data)
            return;
        if (![data writeToFile:PREFS_PATH atomically:YES])
            return;
    }

    if (_selectedRow == NSNotFound) {
        _selectedRow = 0;
        fontName = @"";
    }

    UITableViewCell *cell = (UITableViewCell *)[(PSListController *)self.parentController cachedCellForSpecifierID:@"Font"];
    [((PSTableCell *)cell) setValue:fontName];
    cell.detailTextLabel.font = [UIFont fontWithName:fontName size:[UIFont smallSystemFontSize]];
    cell.detailTextLabel.text = fontName;
}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshList];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)dealloc {
    [_defaultFont release];
    [_stringDefault release];
    [_stringTitle release];
	self.fontList = nil;
	[super dealloc];
}

- (id)view {
	return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)title {
    return _stringTitle;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.fontList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FontCell"];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FontCell"] autorelease];

    NSString *fontName = [self.fontList objectAtIndex:indexPath.row];

    cell.textLabel.font = [UIFont fontWithName:fontName size:[UIFont labelFontSize]];
    if ([fontName isEqualToString:_defaultFont]) {
        cell.textLabel.text = [fontName stringByAppendingString:_stringDefault];
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.text = fontName;
        cell.textLabel.textColor = [UIColor blackColor];
    }

	if (indexPath.row == _selectedRow)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
	if (old != cell)
		old.accessoryType = UITableViewCellAccessoryNone;

    if (_selectedRow != indexPath.row) {
        NSMutableDictionary *_settings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH];

        NSString *fontName = [self.fontList objectAtIndex:indexPath.row];

        [_settings setObject:fontName forKey:@"FontName"];

        NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];

        if (!data)
            return;
        if (![data writeToFile:PREFS_PATH atomically:YES])
            return;

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(SETTIGNS_CHANGED), NULL, (CFDictionaryRef)_settings, YES);

        UITableViewCell *cell = (UITableViewCell *)[(PSListController *)self.parentController cachedCellForSpecifierID:@"Font"];
        [((PSTableCell *)cell) setValue:fontName];
        cell.detailTextLabel.font = [UIFont fontWithName:fontName size:[UIFont smallSystemFontSize]];
        cell.detailTextLabel.text = fontName;

        _selectedRow = indexPath.row;
    }
}

@end

#define WBSAddMethod(_class, _sel, _imp, _type) \
if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)

void $PSViewController$hideNavigationBarButtons(PSRootController *self, SEL _cmd) {
}

id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize) {
    return [self init];
}

static __attribute__((constructor)) void __wbsInit() {
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");
}