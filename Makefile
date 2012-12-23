SDKVERSION = 5.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

include theos/makefiles/common.mk

LIBRARY_NAME = LunarCalendar
LunarCalendar_FILES = LunarCalendarController.m TouchFix/TouchFix.m LunarCalendar/LunarCalendar.m
LunarCalendar_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendar_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/library.mk $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += lunarcalendarpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	mv -f _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.png" -exec chmod 0644 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -exec touch -r _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar {} \;
	
after-package::
	rm -fr .theos/packages/*
	
