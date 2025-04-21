#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Headers（你已集成的微信插件头文件）
#import "WCPluginsHeader.h"
#import "WeChatEnhanceMainController.h"
#import "Headers/MMUINavigationController.h"
#import "Headers/MMMessageCellView.h"
#import "Headers/CMessageMgr.h"
#import "Headers/WCPersonalInfoItemViewLogic.h"

// ====================== 第一部分：声明原始函数指针 ======================
static BOOL (*orig_shouldHideSelfAvatar)(void);
static BOOL (*orig_shouldHideOtherAvatar)(void);
static id (*orig_kNavigationShowAvatarKey)(void);
static CGFloat (*orig_kDefaultAvatarSize)(void);

// ====================== 第二部分：Objective-C 类 Hook ======================

%hook CSAccountDetailViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[WeChatEnhance] ✅ Hooked CSAccountDetailViewController");
}
%end

%hook CSAvatarSettingsViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"[WeChatEnhance] ✅ Hooked CSAvatarSettingsViewController");
}
%end

// ====================== 第三部分：替换目标函数逻辑 ======================

// 强制显示自己的头像
BOOL new_shouldHideSelfAvatar() {
    NSLog(@"[WeChatEnhance] 👤 Force show self avatar");
    return NO;
}

// 强制显示他人的头像
BOOL new_shouldHideOtherAvatar() {
    NSLog(@"[WeChatEnhance] 👥 Force show other avatar");
    return NO;
}

// 替换导航栏头像开关对应的Key
id new_kNavigationShowAvatarKey() {
    NSLog(@"[WeChatEnhance] 🔑 Return custom avatar key");
    return @"WeChatEnhance_ShowAvatar";
}

// 修改默认头像尺寸
CGFloat new_kDefaultAvatarSize() {
    NSLog(@"[WeChatEnhance] 📏 Return custom avatar size");
    return 50.0;
}

// ====================== 第四部分：符号Hook主入口 ======================

__attribute__((constructor)) static void setupHooks() {
    NSLog(@"[WeChatEnhance] 🔧 Initializing symbol hooks...");

    // 查找符号地址
    orig_shouldHideSelfAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z20shouldHideSelfAvatarv");
    orig_shouldHideOtherAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z21shouldHideOtherAvatarv");
    orig_kNavigationShowAvatarKey = (id(*)(void))MSFindSymbol(NULL, "_kNavigationShowAvatarKey");
    orig_kDefaultAvatarSize = (CGFloat(*)(void))MSFindSymbol(NULL, "_kDefaultAvatarSize");

    // 校验符号是否全部找到
    if (!orig_shouldHideSelfAvatar || !orig_shouldHideOtherAvatar ||
        !orig_kNavigationShowAvatarKey || !orig_kDefaultAvatarSize) {
        NSLog(@"[WeChatEnhance] ❌ Failed to locate one or more required symbols!");
        return;
    }

    // 安装 Hook
    MSHookFunction((void *)orig_shouldHideSelfAvatar, (void *)new_shouldHideSelfAvatar, NULL);
    MSHookFunction((void *)orig_shouldHideOtherAvatar, (void *)new_shouldHideOtherAvatar, NULL);
    MSHookFunction((void *)orig_kNavigationShowAvatarKey, (void *)new_kNavigationShowAvatarKey, NULL);
    MSHookFunction((void *)orig_kDefaultAvatarSize, (void *)new_kDefaultAvatarSize, NULL);

    NSLog(@"[WeChatEnhance] ✅ Avatar display hooks installed successfully.");
}
