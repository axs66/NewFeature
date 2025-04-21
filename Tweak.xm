#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ======================
// 1. 账户与用户信息相关
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

%hook CSUserInfoHelper
- (id)getUserInfo:(id)user {
    id result = %orig;
    NSLog(@"WeChatEnhance: Hooked getUserInfo");
    return result;
}
%end

// ======================
// 2. 聊天界面 & 消息增强
// ======================
%hook CSChatAttachmentSettingsViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"WeChatEnhance: Hooked ChatAttachmentSettings");
}
%end

%hook CSMessageTimeSettingsViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"WeChatEnhance: Hooked MessageTimeSettings");
}
%end

// ======================
// 3. 实用功能（防撤回、游戏作弊等）
// ======================
%hook CSGameCheatsViewController
- (void)viewDidLoad {
    %orig;
    NSLog(@"WeChatEnhance: Hooked GameCheats");
}
%end

// ======================
// 4. 头像 & 导航栏控制
// ======================
%hook __Z20shouldHideSelfAvatarv
BOOL __Z20shouldHideSelfAvatarv() {
    BOOL orig = %orig;
    NSLog(@"WeChatEnhance: Hooked shouldHideSelfAvatar (orig: %d)", orig);
    return NO; // 强制显示头像
}
%end

%hook __Z21shouldHideOtherAvatarv
BOOL __Z21shouldHideOtherAvatarv() {
    BOOL orig = %orig;
    NSLog(@"WeChatEnhance: Hooked shouldHideOtherAvatar (orig: %d)", orig);
    return NO; // 强制显示头像
}
%end

// ======================
// 5. 配置键（用于存储设置）
// ======================
%hook _kNavigationShowAvatarKey
id _kNavigationShowAvatarKey() {
    return @"WeChatEnhance_ShowAvatar"; // 修改默认值
}
%end

%hook _kDefaultAvatarSize
CGFloat _kDefaultAvatarSize() {
    return 50.0; // 修改默认头像大小
}
%end
