#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WCPluginsHeader.h"
#import "WeChatEnhanceMainController.h"

// ============== 第一部分：声明原始函数指针 ==============
static BOOL (*orig_shouldHideSelfAvatar)(void);
static BOOL (*orig_shouldHideOtherAvatar)(void);
static id (*orig_kNavigationShowAvatarKey)(void);
static CGFloat (*orig_kDefaultAvatarSize)(void);

// ============== 第二部分：Objective-C 类 Hook ==============
%hook CSAccountDetailViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"WeChatEnhance: Hooked CSAccountDetailViewController");
}
%end

%hook CSAvatarSettingsViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"WeChatEnhance: Hooked CSAvatarSettingsViewController");
}
%end

// ============== 第三部分：C 函数 Hook 实现 ==============
__attribute__((constructor)) static void init() {
    // 1. 获取原始函数地址
    orig_shouldHideSelfAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z20shouldHideSelfAvatarv");
    orig_shouldHideOtherAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z21shouldHideOtherAvatarv");
    orig_kNavigationShowAvatarKey = (id(*)(void))MSFindSymbol(NULL, "_kNavigationShowAvatarKey");
    orig_kDefaultAvatarSize = (CGFloat(*)(void))MSFindSymbol(NULL, "_kDefaultAvatarSize");
    
    // 2. 检查是否找到所有符号
    if (!orig_shouldHideSelfAvatar || !orig_shouldHideOtherAvatar || 
        !orig_kNavigationShowAvatarKey || !orig_kDefaultAvatarSize) {
        NSLog(@"WeChatEnhance: Failed to find required symbols!");
        return;
    }
}

// 3. 实现Hook函数
BOOL new_shouldHideSelfAvatar() {
    NSLog(@"WeChatEnhance: Force show self avatar");
    return NO; // 强制显示头像
}

BOOL new_shouldHideOtherAvatar() {
    NSLog(@"WeChatEnhance: Force show other avatar");
    return NO; // 强制显示头像
}

id new_kNavigationShowAvatarKey() {
    return @"WeChatEnhance_ShowAvatar";
}

CGFloat new_kDefaultAvatarSize() {
    return 50.0;
}

// 4. 使用 MSHookFunction 进行替换
__attribute__((constructor)) static void setupHooks() {
    MSHookFunction((void *)orig_shouldHideSelfAvatar, (void *)new_shouldHideSelfAvatar, NULL);
    MSHookFunction((void *)orig_shouldHideOtherAvatar, (void *)new_shouldHideOtherAvatar, NULL);
    MSHookFunction((void *)orig_kNavigationShowAvatarKey, (void *)new_kNavigationShowAvatarKey, NULL);
    MSHookFunction((void *)orig_kDefaultAvatarSize, (void *)new_kDefaultAvatarSize, NULL);
}
