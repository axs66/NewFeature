export TARGET = iphone:clang:latest
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0
DEBUG = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatinputbox
#WeChatinputbox_CODESIGN = ldid -S

WeChatinputbox_FILES = InputTextHooks.xm CS1InputTextSettingsViewController.m CSSettingTableViewCell.m
WeChatinputbox_LOGOS_DEFAULT_GENERATOR = internal
WeChatinputbox_CFLAGS = -fobjc-arc -Wno-error -Wno-nonnull -Wno-deprecated-declarations -Wno-incompatible-pointer-types -Wno-unicode-whitespace
xiaoxi_FRAMEWORKS = UIKit Foundation LocalAuthentication UserNotifications

include $(THEOS_MAKE_PATH)/tweak.mk

