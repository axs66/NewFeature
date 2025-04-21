#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WCPluginsHeader.h"
#import "WeChatEnhanceMainController.h"
#import "Headers/MMUINavigationController.h"
#import "Headers/MMMessageCellView.h"
#import "Headers/CMessageMgr.h"
#import "Headers/WCPersonalInfoItemViewLogic.h"

%hook MMUINavigationController

- (void)viewDidLoad {
    %orig;

    // 设置导航栏颜色
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableCustomUI"]) {
        self.navigationBar.tintColor = [UIColor redColor];
        self.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
}

%end


%hook MMMessageCellView

- (void)layoutSubviews {
    %orig;

    // 修改消息时间颜色
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableCustomTimeColor"]) {
        self.timestampLabel.textColor = [UIColor orangeColor];
    }
}

%end


%hook WCPersonalInfoItemViewLogic

- (void)onItemClicked:(id)arg1 {
    %orig;

    if ([self respondsToSelector:@selector(itemName)] && [[self performSelector:@selector(itemName)] isEqualToString:@"点歌封面"]) {
        // 模拟打开你的点歌封面控制器
        UIViewController *controller = [[NSClassFromString(@"SongCardEditViewController") alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        
        // 使用新的方法获取 key window
        UIWindow *window = nil;
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (w.isKeyWindow) {
                window = w;
                break;
            }
        }
        if (window) {
            [window.rootViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"[WeChatEnhance] 插件已启动");

        // 默认注册设置值
        NSDictionary *defaults = @{
            @"EnableCustomUI": @YES,
            @"EnableCustomTimeColor": @YES
        };
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}
