#import <substrate.h>
#import <WeChatHeaders.h>

//让我们修改微信上传时候所用的appInfo
%hook WCUploadTask
- (WCAppInfo *)appInfo {
    /*这里使用的是秒剪ID: wxa5e0de08d96cc09d
    如果直接使用这个ID会出现: 发出后微信从数据库中使用原始的AppName来替换我们的显示
    但是也不能完全随机这个ID, 不然会导致变成未审核应用
    但是当我们修改末尾字符时不会出现, 可见此ID并未完全校验(仅在iOS平台测试)*/
    NSString *tailText = [NSUserDefaults.standardUserDefaults stringForKey:@"WCTimeLineMessageTail"];
    if (!tailText || tailText.length < 1) {
    return %orig;
    }
    WCAppInfo *appInfo = [[%c(WCAppInfo) alloc] init];
    NSString *result = [[[NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5, @6, @7, @8]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return arc4random_uniform(2) ? NSOrderedAscending : NSOrderedDescending;
    }] componentsJoinedByString:@""];
    //所需18位, 我们随机末尾8位字符
    [appInfo setAppID:[NSString stringWithFormat:@"wxa5e0de08%@", result]];
    [appInfo setAppName:tailText];
    return appInfo;
}
%end

//给发布朋友圈页面添加我们的Cell
%hook WCNewCommitViewController
- (void)reloadData {
    %orig;
    WCTableViewManager *tableViewManager = MSHookIvar<WCTableViewManager *>(self, "m_tableViewManager");
    WCTableViewSectionManager *tableViewSectionManager = [tableViewManager getSectionAt:0];
    MMThemeManager *themeManager = [[%c(MMContext) currentContext] getService:[%c(MMThemeManager) class]];
    [tableViewSectionManager addCell:[%c(WCTableViewCellManager) normalCellForSel:@selector(setupTail) target:self leftImage:[themeManager imageNamed:@"icons_outlined_text"] title:@"设置尾巴" badge:nil rightValue:[NSUserDefaults.standardUserDefaults stringForKey:@"WCTimeLineMessageTail"] rightImage:nil withRightRedDot:NO selected:NO]];
    [tableViewManager reloadTableView];
}

%new
- (void)setupTail {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置尾巴" message:@"🤩学习交流\nhttps://github.com/Netskao/WCTimeLineMessageTail" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"设置任何你所想的文本";
    textField.text = [NSUserDefaults.standardUserDefaults stringForKey:@"WCTimeLineMessageTail"];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
    UITextField *textField = [[alertController textFields] firstObject];
    NSString *text = [textField text];
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"WCTimeLineMessageTail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelector:@selector(reloadData)];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
%end
