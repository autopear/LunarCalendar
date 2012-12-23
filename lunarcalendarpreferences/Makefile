SDKVERSION = 5.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

include theos/makefiles/common.mk

BUNDLE_NAME = LunarCalendarPreferences
LunarCalendarPreferences_FILES = LunarCalendarPreferences.mm
LunarCalendarPreferences_INSTALL_PATH = /Library/PreferenceBundles
LunarCalendarPreferences_FRAMEWORKS = UIKit
LunarCalendarPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LunarCalendarPreferences.plist$(ECHO_END)
