ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatEnhance
WeChatEnhance_FILES = Tweak.xm WeChatEnhanceMainController.m
WeChatEnhance_CFLAGS = -fobjc-arc
WeChatEnhance_FRAMEWORKS = UIKit Foundation
WeChatEnhance_LDFLAGS = -Wl,-undefined,dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk
