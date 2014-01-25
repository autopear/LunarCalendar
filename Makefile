export TARGET=iphone:7.0:5.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

LIBRARY_NAME = LunarCalendar LunarCalendar7

LunarCalendar_FILES = LunarCalendarController.m \
					  TouchFix/TouchFix.m \
					  LunarCalendar/LunarCalendar.m
LunarCalendar_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendar_FRAMEWORKS = Foundation UIKit CoreGraphics

LunarCalendar7_FILES = LunarCalendarWidgetController.m \
					   LunarCalendar/LunarCalendar.m
LunarCalendar7_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendar7_FRAMEWORKS = Foundation UIKit CoreGraphics
LunarCalendar7_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include $(THEOS_MAKE_PATH)/library.mk

SUBPROJECTS += lunarcalendarpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	mv _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar
	mv _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar7.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar7
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.png" -exec chmod 0644 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -exec touch -r _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar {} \;
	
after-package::
	rm -fr .theos/packages/*
	
