#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WCPluginsHeader.h" 
#import "WeChatEnhanceMainController.h"

// ✅ 你原始 Hook 内容：保留
%hook WCPersonalInfoItemViewLogic

- (BOOL)shouldHideSelfAvatar {
    // 加入开关判断
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableAvatarEnhance"]) {
        return NO;
    }
    return %orig;
}

%end

%hook MMUINavigationController

- (void)viewDidLoad {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableNavCustomization"]) {
        self.navigationBar.tintColor = [UIColor redColor];
    }
}

%end

// ✅ 示例：时间显示功能
%hook MMMessageCellView

- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableTimeDisplay"]) {
        // 比如增加时间标签、改变显示样式等
        self.timestampLabel.textColor = [UIColor orangeColor];
    }
}

%end

// ✅ 示例：后台运行
%hook CMessageMgr

- (void)AppWillResignActive {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enableBackground"]) {
        %orig;
    }
}

%end

// ✅ 注册插件到收纳管理器
__attribute__((constructor)) static void registerPlugin() {
    [[WCPluginsMgr sharedInstance] registerControllerWithTitle:@"微信增强"
                                                       version:@"2.0"
                                                    controller:@"WeChatEnhanceMainController"];
}
