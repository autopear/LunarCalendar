#import <Preferences/Preferences.h>
#import <objc/runtime.h>

@interface LunarCalendarListController: PSListController
{
}
@end

@implementation LunarCalendarListController
- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)specifiers
{
    if (_specifiers == nil)
    {
        NSArray *specs = [self loadSpecifiersFromPlistName:@"LunarCalendar" target:self];

        NSMutableArray *actualSpecs = [[NSMutableArray alloc] init];
        
        PSSpecifier *gestureSpec = nil;
        PSSpecifier *gesture7Spec = nil;
        
        for (unsigned int i=0; i<[specs count] ;i++)
        {
            PSSpecifier *spec = (PSSpecifier *)[specs objectAtIndex:i];
        
            if ([[spec propertyForKey:@"id"] isEqualToString:@"GESTURE"])
            {
                gestureSpec = spec;
                if (kCFCoreFoundationVersionNumber >= 847.20)
                    continue;
            }
            if ([[spec propertyForKey:@"id"] isEqualToString:@"GESTURE7"])
            {
                gesture7Spec = spec;
                if (kCFCoreFoundationVersionNumber < 847.20)
                    continue;
            }
            [actualSpecs addObject:spec];
        }
        if (kCFCoreFoundationVersionNumber < 847.20)
            [self removeSpecifier:gesture7Spec];
        else
            [self removeSpecifier:gesture7Spec];
        _specifiers = actualSpecs;
    }

	return _specifiers;
}

@end

@interface LunarCalendarSpecificationsListController: PSListController
{
}
@end

@implementation LunarCalendarSpecificationsListController
- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)specifiers
{
	if(_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"Specifications" target:self] retain];
	return _specifiers;
}

@end

@interface LunarCalendarMoreInfoListController: PSListController
{
}
@end

@implementation LunarCalendarMoreInfoListController
- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)specifiers
{
	if(_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"MoreInfo" target:self] retain];
	return _specifiers;
}

-(void)openActionSlider:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.actionslider"]];
}

-(void)openWeeCloseApps:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.weecloseapps"]];
}

-(void)openIPAInstaller:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.installipa"]];
}

-(void)openLunarCalendar:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.lunarcalendar"]];
}

-(void)openRemoveBadges:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.autopear.removebadges"]];
}

-(void)openQuickShare:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.quickshare"]];
}

-(void)openImListening:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.bigboss.imlistening"]];
}

@end

#define WBSAddMethod(_class, _sel, _imp, _type) \
if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)

void $PSViewController$hideNavigationBarButtons(PSRootController *self, SEL _cmd)
{
}

id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize)
{
    return [self init];
}

static __attribute__((constructor)) void __wbsInit()
{
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");
}