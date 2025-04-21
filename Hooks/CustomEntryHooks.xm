// CustomEntryHooks.xm
// 微信自定义入口 Hook

#import "../Headers/WCHeaders.h"
#import "../Headers/CSUserInfoHelper.h"
#import "../Headers/WCPluginsHeader.h"
#import "../Controllers/CSEntrySettingsViewController.h"

// 入口设置相关的键
static NSString * const kEntryDisplayModeKey = @"com.wechat.tweak.entry.display.mode";
static NSString * const kEntryCustomTitleKey = @"com.wechat.tweak.entry.custom.title";
static NSString * const kEntrySettingsChangedNotification = @"com.wechat.tweak.entry.settings.changed";

// 定义入口标题变量
static NSString *gCustomEntryTitle = nil;

// 获取入口图标
static inline UIImage * __nullable getCustomEntryIcon(void) {
    UIImage *icon = [UIImage systemImageNamed:@"signature.th"];
    return [icon imageWithTintColor:[UIColor systemBlueColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
}

static CSEntryDisplayMode getEntryDisplayMode() {
    return (CSEntryDisplayMode)[[NSUserDefaults standardUserDefaults] integerForKey:kEntryDisplayModeKey];
}

static NSString *getCustomEntryTitle() {
    if (!gCustomEntryTitle) {
        NSString *savedTitle = [[NSUserDefaults standardUserDefaults] objectForKey:kEntryCustomTitleKey];
        gCustomEntryTitle = savedTitle ?: @"Wechat";
    }
    return gCustomEntryTitle;
}

static void loadEntrySettings() {
    gCustomEntryTitle = getCustomEntryTitle();
    NSLog(@"[WeChatTweak] 入口设置已加载: 显示模式=%ld, 标题=%@", (long)getEntryDisplayMode(), gCustomEntryTitle);
}

static void entrySettingsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadEntrySettings();
}

%hook MoreViewController

- (void)addFunctionSection {
    %orig;

    if (getEntryDisplayMode() == CSEntryDisplayModePlugin) {
        NSLog(@"[WeChatTweak] 根据设置跳过在设置页面添加入口");
        return;
    }

    NSString *entryTitle = getCustomEntryTitle();
    WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");
    if (!tableViewMgr) return;

    WCTableViewSectionManager *section = [tableViewMgr getSectionAt:2];
    if (!section) return;

    WCTableViewCellManager *customEntryCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(onCustomEntryClick)
                                                                                      target:self
                                                                                   leftImage:getCustomEntryIcon()
                                                                                      title:entryTitle
                                                                                      badge:nil
                                                                                 rightValue:nil
                                                                                rightImage:nil
                                                                           withRightRedDot:NO
                                                                                  selected:NO];
    [section addCell:customEntryCell];
    NSLog(@"[WeChatTweak] 已在设置页面添加入口: %@", entryTitle);
}

%new
- (void)onCustomEntryClick {
    // 使用已有的 CSEntrySettingsViewController 替代未定义的 CSCustomViewController
    CSEntrySettingsViewController *customVC = [[CSEntrySettingsViewController alloc] init];
    customVC.title = getCustomEntryTitle();

    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:customVC];

    if (@available(iOS 13.0, *)) {
        navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        navVC.modalPresentationStyle = UIModalPresentationPageSheet;
    }

    [self presentViewController:navVC animated:YES completion:nil];
}

%end

%hook MinimizeViewController

static int isRegister = 0;

- (void)viewDidLoad {
    %orig;

    if (getEntryDisplayMode() == CSEntryDisplayModeMore) {
        NSLog(@"[WeChatTweak] 根据设置跳过在插件入口添加入口");
        return;
    }

    if (NSClassFromString(@"WCPluginsMgr") && isRegister == 0) {
        isRegister = 1;

        NSString *title = getCustomEntryTitle();
        NSString *version = kPluginVersionString;
        NSString *controller = @"CSEntrySettingsViewController"; // 替代 CSCustomViewController

        NSLog(@"[WeChatTweak] 尝试注册自定义入口: %@, 控制器: %@", title, controller);

        @try {
            Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
            if (wcPluginsMgr) {
                id instance = [wcPluginsMgr performSelector:@selector(sharedInstance)];
                if (instance) {
                    SEL registerSel = @selector(registerControllerWithTitle:version:controller:);
                    if ([instance respondsToSelector:registerSel]) {
                        [instance registerControllerWithTitle:title version:version controller:controller];
                        NSLog(@"[WeChatTweak] 成功注册自定义入口: %@", title);
                    } else {
                        NSLog(@"[WeChatTweak] 注册失败: registerControllerWithTitle 方法不存在");
                    }
                } else {
                    NSLog(@"[WeChatTweak] 注册失败: 无法获取 WCPluginsMgr 实例");
                }
            } else {
                NSLog(@"[WeChatTweak] 注册失败: WCPluginsMgr 类不存在");
            }
        } @catch (NSException *exception) {
            NSLog(@"[WeChatTweak] 注册入口失败: %@", exception);
        }
    }
}

%end

%ctor {
    loadEntrySettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    entrySettingsChangedCallback,
                                    CFSTR("com.wechat.tweak.entry.settings.changed"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}
