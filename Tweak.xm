#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WCPluginsHeader.h"
#import "WeChatEnhanceMainController.h"
#import "Headers/MMUINavigationController.h"
#import "Headers/MMMessageCellView.h"
#import "Headers/CMessageMgr.h"
#import "Headers/WCPersonalInfoItemViewLogic.h"

// ============== 原始函数指针声明 ==============
static BOOL (*orig_shouldHideSelfAvatar)(void);
static BOOL (*orig_shouldHideOtherAvatar)(void);
static id (*orig_kNavigationShowAvatarKey)(void);
static CGFloat (*orig_kDefaultAvatarSize)(void);

// ============== Objective-C 类 Hook ==============

// 1. 导航栏 UI 自定义
%hook MMUINavigationController

- (void)viewDidLoad {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableCustomUI"]) {
        self.navigationBar.tintColor = [UIColor redColor];
        self.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
}

%end

// 2. 消息时间颜色修改
%hook MMMessageCellView

- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableCustomTimeColor"]) {
        UILabel *label = [self valueForKey:@"m_timestampLabel"];
        if ([label isKindOfClass:[UILabel class]]) {
            label.textColor = [UIColor orangeColor];
        }
    }
}

%end

// 3. 插件入口点击处理
%hook WCPersonalInfoItemViewLogic

- (void)onItemClicked:(id)arg1 {
    %orig;

    if ([self respondsToSelector:@selector(itemName)] && [[self performSelector:@selector(itemName)] isEqualToString:@"点歌封面"]) {
        UIViewController *controller = [[NSClassFromString(@"SongCardEditViewController") alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];

        // 多 scene 安全获取 topVC
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        UIViewController *topVC = window.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }

        [topVC presentViewController:nav animated:YES completion:nil];
    }
}

%end

// 4. 调试辅助（可选）
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

// ============== C 函数 Hook ==============

// 自定义实现
BOOL new_shouldHideSelfAvatar() {
    NSLog(@"WeChatEnhance: Force show self avatar");
    return NO;
}

BOOL new_shouldHideOtherAvatar() {
    NSLog(@"WeChatEnhance: Force show other avatar");
    return NO;
}

id new_kNavigationShowAvatarKey() {
    return @"WeChatEnhance_ShowAvatar";
}

CGFloat new_kDefaultAvatarSize() {
    return 50.0;
}

// 初始化原始符号地址
__attribute__((constructor)) static void init() {
    orig_shouldHideSelfAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z20shouldHideSelfAvatarv");
    orig_shouldHideOtherAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z21shouldHideOtherAvatarv");
    orig_kNavigationShowAvatarKey = (id(*)(void))MSFindSymbol(NULL, "_kNavigationShowAvatarKey");
    orig_kDefaultAvatarSize = (CGFloat(*)(void))MSFindSymbol(NULL, "_kDefaultAvatarSize");

    if (!orig_shouldHideSelfAvatar || !orig_shouldHideOtherAvatar ||
        !orig_kNavigationShowAvatarKey || !orig_kDefaultAvatarSize) {
        NSLog(@"[WeChatEnhance] Failed to find some symbols!");
        return;
    }
}

// 注入函数替换
__attribute__((constructor)) static void setupHooks() {
    MSHookFunction((void *)orig_shouldHideSelfAvatar, (void *)new_shouldHideSelfAvatar, NULL);
    MSHookFunction((void *)orig_shouldHideOtherAvatar, (void *)new_shouldHideOtherAvatar, NULL);
    MSHookFunction((void *)orig_kNavigationShowAvatarKey, (void *)new_kNavigationShowAvatarKey, NULL);
    MSHookFunction((void *)orig_kDefaultAvatarSize, (void *)new_kDefaultAvatarSize, NULL);
}

// 默认设置注入
%ctor {
    @autoreleasepool {
        NSLog(@"[WeChatEnhance] 插件已启动");
        NSDictionary *defaults = @{
            @"EnableCustomUI": @YES,
            @"EnableCustomTimeColor": @YES
        };
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}
