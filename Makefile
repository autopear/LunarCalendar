export TARGET=iphone:7.0:5.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = LunarCalendar
LunarCalendar_FILES = LunarCalendarController.m \
					  TouchFix/TouchFix.m \
					  LunarCalendarWidgetController.m \
					  LunarCalendar/LunarCalendar.m
LunarCalendar_INSTALL_PATH = /System/Library/WeeAppPlugins/
LunarCalendar_FRAMEWORKS = Foundation UIKit CoreGraphics
LunarCalendar_LDFLAGS = -weak_library $(TARGET_PRIVATE_FRAMEWORK_PATH)/SpringBoardUIServices.framework/SpringBoardUIServices

include $(THEOS_MAKE_PATH)/bundle.mk

SUBPROJECTS += lunarcalendarpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.png" -exec chmod 0644 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -exec touch -r _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar {} \;
	
after-package::
	rm -fr .theos/packages/*
	
