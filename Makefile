export TARGET=iphone:7.1:5.0
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

LIBRARY_NAME = LunarCalendar LunarCalendarToday LunarCalendarAll

LunarCalendar_FILES = LunarCalendarController.m \
					  TouchFix/TouchFix.m \
					  LunarCalendar/LunarCalendar.m
LunarCalendar_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendar_FRAMEWORKS = Foundation UIKit CoreGraphics

LunarCalendarToday_FILES = LunarCalendarTodayController.m \
					   	   LunarCalendar/LunarCalendar.m
LunarCalendarToday_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendar.bundle
LunarCalendarToday_FRAMEWORKS = Foundation UIKit CoreGraphics
LunarCalendarToday_PRIVATE_FRAMEWORKS = SpringBoardUIServices

LunarCalendarAll_FILES = LunarCalendarAllController.m \
					     LunarCalendar/LunarCalendar.m
LunarCalendarAll_INSTALL_PATH = /System/Library/WeeAppPlugins/LunarCalendarAll.bundle
LunarCalendarAll_FRAMEWORKS = Foundation UIKit CoreGraphics
LunarCalendarAll_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include $(THEOS_MAKE_PATH)/library.mk

SUBPROJECTS += lunarcalendarpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	mv _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar
	mv _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendarToday.dylib _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendarToday
	mv _/System/Library/WeeAppPlugins/LunarCalendarAll.bundle/LunarCalendarAll.dylib _/System/Library/WeeAppPlugins/LunarCalendarAll.bundle/LunarCalendarAll
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.png" -exec chmod 0644 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -exec touch -r _/System/Library/WeeAppPlugins/LunarCalendar.bundle/LunarCalendar {} \;
	sudo chown -R 0:0 _
	
after-package::
	sudo chown -R merlin:staff _
	rm -fr .theos/packages/*
	
