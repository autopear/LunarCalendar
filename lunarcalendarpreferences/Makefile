export TARGET=iphone:7.0:5.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = LunarCalendar
LunarCalendar_FILES = LunarCalendar.mm
LunarCalendar_INSTALL_PATH = /Library/PreferenceBundles
LunarCalendar_FRAMEWORKS = UIKit
LunarCalendar_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LunarCalendar.plist$(ECHO_END)
