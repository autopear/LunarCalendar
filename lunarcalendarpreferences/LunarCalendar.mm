#import <Preferences/Preferences.h>
#import <objc/runtime.h>

@interface LunarCalendarListController: PSListController {
}
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

@end

@interface LunarCalendarTextStyleListController : PSListController {
}
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
                if ([key isEqualToString:@"FontStyle"]) {
                    if (kCFCoreFoundationVersionNumber < 847.20)
                        [spec setProperty:[NSNumber numberWithInt:1] forKey:@"default"]; //iOS 5 & 6
                    else
                        [spec setProperty:[NSNumber numberWithInt:0] forKey:@"default"]; //iOS 7
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
        
        for (PSSpecifier *spec in _specifiers)
        {
            if (kCFCoreFoundationVersionNumber < 847.20) //iOS 5 & 6
            {
                if ([[spec propertyForKey:@"id"] isEqualToString:@"SHAREWIDGET7_GROUP"])
                {
                    shareWidet7GroupSpec = spec;
                    continue;
                }
                if ([[spec propertyForKey:@"id"] isEqualToString:@"SHAREWIDGET7_CELL"])
                {
                    shareWidet7CellSpec = spec;
                    continue;
                }
            }
            else
            {
                if ([[spec propertyForKey:@"id"] isEqualToString:@"LYRICSFORIPAD_GROUP"])
                {
                    lyricsForiPadGroupSpec = spec;
                    continue;
                }
                if ([[spec propertyForKey:@"id"] isEqualToString:@"LYRICSFORIPAD_CELL"])
                {
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

-(void)openActionSlider:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.actionslider"]];
}

-(void)openWeeCloseApps:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.weecloseapps"]];
}

-(void)openIPAInstaller:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.installipa"]];
}

-(void)openLunarCalendar:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.lunarcalendar"]];
}

-(void)openRemoveBadges:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.removebadges"]];
}

-(void)openQuickShare:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.quickshare"]];
}

-(void)openImListening:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.bigboss.imlistening"]];
}

-(void)openShareWidget7:(PSSpecifier*)specifier {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.sharewidget7"]];
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