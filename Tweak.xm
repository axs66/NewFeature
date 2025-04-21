#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "WCPluginsHeader.h"
#import "WeChatEnhanceMainController.h"
#import "Headers/MMUINavigationController.h"
#import "Headers/MMMessageCellView.h"
#import "Headers/CMessageMgr.h"
#import "Headers/WCPersonalInfoItemViewLogic.h"

#pragma mark - 设置默认偏好值
__attribute__((constructor)) static void registerDefaults() {
    NSDictionary *defaults = @{
        @"EnableCustomUI": @YES,
        @"EnableCustomTimeColor": @YES,
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

#pragma mark - Hook 导航栏样式
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

#pragma mark - Hook 消息气泡时间颜色
%hook MMMessageCellView

- (void)layoutSubviews {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableCustomTimeColor"]) {
        self.timestampLabel.textColor = [UIColor orangeColor];
    }
}

%end

#pragma mark - Hook “点歌封面”入口点击行为
%hook WCPersonalInfoItemViewLogic

- (void)onItemClicked:(id)arg1 {
    %orig;

    if ([self respondsToSelector:@selector(itemName)]) {
        NSString *name = [self performSelector:@selector(itemName)];
        if ([name isEqualToString:@"点歌封面"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Class vcClass = NSClassFromString(@"SongCardEditViewController");
                if (vcClass) {
                    UIViewController *controller = [[vcClass alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
                    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                    UIViewController *topVC = keyWindow.rootViewController;
                    while (topVC.presentedViewController) {
                        topVC = topVC.presentedViewController;
                    }
                    [topVC presentViewController:nav animated:YES completion:nil];
                } else {
                    NSLog(@"[WeChatEnhance] ❌ SongCardEditViewController class not found");
                }
            });
        }
    }
}

%end

#pragma mark - C 函数符号替换部分（头像强制显示）
static BOOL (*orig_shouldHideSelfAvatar)(void) = NULL;
static BOOL (*orig_shouldHideOtherAvatar)(void) = NULL;
static id (*orig_kNavigationShowAvatarKey)(void) = NULL;
static CGFloat (*orig_kDefaultAvatarSize)(void) = NULL;

BOOL new_shouldHideSelfAvatar() {
    return NO;
}

BOOL new_shouldHideOtherAvatar() {
    return NO;
}

id new_kNavigationShowAvatarKey() {
    return @"WeChatEnhance_ShowAvatar";
}

CGFloat new_kDefaultAvatarSize() {
    return 50.0;
}

__attribute__((constructor)) static void hookAvatarFunctions() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[WeChatEnhance] 🔍 Starting to hook avatar-related functions...");

        orig_shouldHideSelfAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z20shouldHideSelfAvatarv");
        orig_shouldHideOtherAvatar = (BOOL(*)(void))MSFindSymbol(NULL, "__Z21shouldHideOtherAvatarv");
        orig_kNavigationShowAvatarKey = (id(*)(void))MSFindSymbol(NULL, "_kNavigationShowAvatarKey");
        orig_kDefaultAvatarSize = (CGFloat(*)(void))MSFindSymbol(NULL, "_kDefaultAvatarSize");

        if (orig_shouldHideSelfAvatar) {
            MSHookFunction((void *)orig_shouldHideSelfAvatar, (void *)new_shouldHideSelfAvatar, NULL);
        }

        if (orig_shouldHideOtherAvatar) {
            MSHookFunction((void *)orig_shouldHideOtherAvatar, (void *)new_shouldHideOtherAvatar, NULL);
        }

        if (orig_kNavigationShowAvatarKey) {
            MSHookFunction((void *)orig_kNavigationShowAvatarKey, (void *)new_kNavigationShowAvatarKey, NULL);
        }

        if (orig_kDefaultAvatarSize) {
            MSHookFunction((void *)orig_kDefaultAvatarSize, (void *)new_kDefaultAvatarSize, NULL);
        }

        NSLog(@"[WeChatEnhance] ✅ Avatar hooks finished");
    });
}
