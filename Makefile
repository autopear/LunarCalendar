SDKVERSION = 5.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

include theos/makefiles/common.mk

LIBRARY_NAME = LunarCalendar
LunarCalendar_FILES = LunarCalendarController.m TouchFix/TouchFix.m LunarCalendar/LunarCalendar.m
LunarCalendar_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendar_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/library.mk $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	mv -f _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar

after-package::
	rm -fr .theos/packages/*