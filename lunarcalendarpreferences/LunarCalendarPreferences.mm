#import <Preferences/Preferences.h>
#import <objc/runtime.h>

@interface LunarCalendarPreferencesListController: PSListController {
}
@end

@implementation LunarCalendarPreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LunarCalendar" target:self] retain];
	}
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
    {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MoreInfo" target:self] retain];
    }
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