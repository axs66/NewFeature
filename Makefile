export TARGET = iphone:clang:latest
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0
// DEBUG = 1  调试构建模式  即+debug

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NewFeature
#NewFeature_CODESIGN = ldid -S

NewFeature_FILES = NewFeature.xm CS1InputTextSettingsViewController.m CSSettingTableViewCell.m WCTimeLineMessageTail.xm
NewFeature_CFLAGS = -fobjc-arc -Wno-error -Wno-nonnull -Wno-deprecated-declarations -Wno-incompatible-pointer-types -Wno-unicode-whitespace
NewFeature_FRAMEWORKS = UIKit Foundation LocalAuthentication UserNotifications

include $(THEOS_MAKE_PATH)/tweak.mk
