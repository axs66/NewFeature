export TARGET = iphone:clang:latest
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0
DEBUG = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WenBen
#WCDGDIY_CODESIGN = ldid -S

WenBen_FILES = InputTextHooks.xm CS1InputTextSettingsViewController.m CSSettingTableViewCell.m
WenBen_LOGOS_DEFAULT_GENERATOR = internal
WenBen_CFLAGS = -fobjc-arc -Wno-error -Wno-nonnull -Wno-deprecated-declarations -Wno-incompatible-pointer-types -Wno-unicode-whitespace
xiaoxi_FRAMEWORKS = UIKit Foundation LocalAuthentication UserNotifications

include $(THEOS_MAKE_PATH)/tweak.mk

