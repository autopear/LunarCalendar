#import <Preferences/Preferences.h>
#import <objc/runtime.h>

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.autopear.lunarcalendar.plist"
#define SETTIGNS_CHANGED @"com.autopear.lunarcalendar/prefs"

@interface PSSliderTableCell : PSControlTableCell
@end

@interface LunarCalendarListController: PSListController {
}
- (void)updateInterface;
@end

@implementation LunarCalendarListController

- (id)init {
	if ((self = [super init])) {
	}

	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"LunarCalendar" target:self] retain];

        unsigned int count = 0;
        for (PSSpecifier *spec in _specifiers) {
            if ([spec propertyForKey:@"key"]) {
                NSString *key = [spec propertyForKey:@"key"];
                if ([key isEqualToString:@"SwitchGesture"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 7
                    count++;
                }
                if ([key isEqualToString:@"TextAlign"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7
                    count++;
                }
                if ([key isEqualToString:@"SideMargin"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20) {
                        //iOS 5 & 6
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            [spec setProperty:[NSNumber numberWithInt:250] forKey:@"max"];
                        else
                            [spec setProperty:[NSNumber numberWithInt:150] forKey:@"max"];
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"];
                    } else {
                        //iOS 7
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            [spec setProperty:[NSNumber numberWithInt:250] forKey:@"max"];
                        else
                            [spec setProperty:[NSNumber numberWithInt:150] forKey:@"max"];
                        [spec setProperty:[NSNumber numberWithInt:45] forKey:@"default"];
                    }
                    count++;
                }
            }
            if (count > 2)
                break;
        }
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

@end

@interface LunarCalendarTextStyleListController : PSListController {
}
- (void)updateInterface;
@end

@implementation LunarCalendarTextStyleListController
- (id)init
{
	if ((self = [super init])) {
	}

	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TextStyle" target:self] retain];

        unsigned int count = 0;
        for (PSSpecifier *spec in _specifiers) {
            if ([spec propertyForKey:@"key"]) {
                NSString *key = [spec propertyForKey:@"key"];
                if ([key isEqualToString:@"FontName"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:@"Helvetica-Bold" forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:@"Helvetica" forKey:@"default"]; //iOS 7
                    count++;
                }
                if ([key isEqualToString:@"ShadowWidth"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7
                    count++;
                }
                if ([key isEqualToString:@"ShadowHeight"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7
                    count++;
                }
            }
            if (count > 2)
                break;
        }
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

@end

@interface LunarCalendarSpecificationsListController: PSListController {
}
@end

@implementation LunarCalendarSpecificationsListController
- (id)init
{
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
            for (PSSpecifier *spec in _specifiers) {
                NSString *specId = [spec propertyForKey:@"id"];
                if (specId && [specId isEqualToString:@"COPYRIGHT"])
                    continue;
                
                NSString *labelText = spec.name;
                [spec setProperty:labelText forKey:@"footerText"];
                spec.name = nil;
            }
        }
    }
	return _specifiers;
}

@end

@interface LunarCalendarMoreInfoListController: PSListController {
}
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
		_specifiers = [[self loadSpecifiersFromPlistName:@"MoreInfo" target:self] retain];

        NSMutableArray *actualSpecs = [[NSMutableArray alloc] init];
        PSSpecifier *lyricsForiPadGroupSpec = nil;
        PSSpecifier *lyricsForiPadCellSpec = nil;
        PSSpecifier *shareWidet7GroupSpec = nil;
        PSSpecifier *shareWidet7CellSpec = nil;
        
        for (PSSpecifier *spec in _specifiers) {
            if (kCFCoreFoundationVersionNumber < 847.20) {
                //iOS 5 & 6
                if ([[spec propertyForKey:@"id"] isEqualToString:@"SHAREWIDGET7_GROUP"]) {
                    shareWidet7GroupSpec = spec;
                    continue;
                }
                if ([[spec propertyForKey:@"id"] isEqualToString:@"SHAREWIDGET7_CELL"]) {
                    shareWidet7CellSpec = spec;
                    continue;
                }
            } else {
                if ([[spec propertyForKey:@"id"] isEqualToString:@"LYRICSFORIPAD_GROUP"]) {
                    lyricsForiPadGroupSpec = spec;
                    continue;
                }
                if ([[spec propertyForKey:@"id"] isEqualToString:@"LYRICSFORIPAD_CELL"]) {
                    lyricsForiPadCellSpec = spec;
                    continue;
                }
            }
            
            [actualSpecs addObject:spec];
        }
        if (shareWidet7GroupSpec)
            [self removeSpecifier:shareWidet7GroupSpec];
        if (shareWidet7CellSpec)
            [self removeSpecifier:shareWidet7CellSpec];
        if (lyricsForiPadGroupSpec)
            [self removeSpecifier:lyricsForiPadGroupSpec];
        if (lyricsForiPadCellSpec)
            [self removeSpecifier:lyricsForiPadCellSpec];
        
        [_specifiers release];
        _specifiers = actualSpecs;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.sharewidget7"]];
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
        _defaultFont = (kCFCoreFoundationVersionNumber < 847.20 ? @"Helvetica-Bold" : @"Helvetica");
        
        NSBundle *localizedBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/LunarCalendar.bundle/"];
        _stringDefault = NSLocalizedStringFromTableInBundle(@" (Default)", @"TextStyle", localizedBundle, @" (Default)");
        _stringTitle = NSLocalizedStringFromTableInBundle(@"Font", @"TextStyle", localizedBundle, @"Font");
        [localizedBundle release];
        
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];
        
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:PREFS_PATH isDirectory:&isDir]) {
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
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            [self.fontList addObject:fontName];
        }
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
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)SETTIGNS_CHANGED, NULL, (CFDictionaryRef)_settings, true);

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