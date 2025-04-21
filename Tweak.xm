#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ======================
// 1. 声明 C++ 函数原型（避免重复定义）
// ======================
extern "C" {
    BOOL __Z20shouldHideSelfAvatarv(void);
    BOOL __Z21shouldHideOtherAvatarv(void);
    id _kNavigationShowAvatarKey(void);
    CGFloat _kDefaultAvatarSize(void);
}

// ======================
// 2. Objective-C 类 Hook
// ======================
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

// ======================
// 3. C++ 函数 Hook（使用 %hookf）
// ======================
%hookf(BOOL, __Z20shouldHideSelfAvatarv) {
    BOOL orig = %orig;
    NSLog(@"WeChatEnhance: Force show self avatar (orig: %d)", orig);
    return NO; // 强制显示头像
}

%hookf(BOOL, __Z21shouldHideOtherAvatarv) {
    BOOL orig = %orig;
    NSLog(@"WeChatEnhance: Force show other avatar (orig: %d)", orig);
    return NO; // 强制显示头像
}

// ======================
// 4. 全局变量 Hook（使用 %hookf）
// ======================
%hookf(id, _kNavigationShowAvatarKey) {
    return @"WeChatEnhance_ShowAvatar"; // 修改默认值
}

%hookf(CGFloat, _kDefaultAvatarSize) {
    return 50.0; // 修改默认头像大小
}
