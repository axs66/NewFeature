#import "CSEntrySettingsViewController.h"
#import <stdlib.h>

// 用户默认设置键
static NSString * const kEntryDisplayModeKey = @"com.wechat.tweak.entry.display.mode";
static NSString * const kEntrySettingsChangedNotification = @"com.wechat.tweak.entry.settings.changed";

// 开关设置键
static NSString * const kEntryShowInMoreKey = @"com.wechat.tweak.entry.show.in.more";
static NSString * const kEntryShowInPluginKey = @"com.wechat.tweak.entry.show.in.plugin";

@interface CSEntrySettingsViewController ()

// 删除涉及到问题类的相关属性

@end

@implementation CSEntrySettingsViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"入口设置";
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);

    [self loadCurrentSettings];
}

#pragma mark - 设置加载和保存

- (void)loadCurrentSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CSEntryDisplayMode displayMode = [defaults integerForKey:kEntryDisplayModeKey];

    BOOL showInMore = NO;
    BOOL showInPlugin = NO;

    switch (displayMode) {
        case CSEntryDisplayModeMore:
            showInMore = YES;
            break;
        case CSEntryDisplayModePlugin:
            showInPlugin = YES;
            break;
        case CSEntryDisplayModeBoth:
            showInMore = YES;
            showInPlugin = YES;
            break;
        default:
            showInMore = YES;
            break;
    }

    if (![defaults objectForKey:kEntryShowInMoreKey]) {
        [defaults setBool:showInMore forKey:kEntryShowInMoreKey];
    }

    if (![defaults objectForKey:kEntryShowInPluginKey]) {
        [defaults setBool:showInPlugin forKey:kEntryShowInPluginKey];
    }
}

- (void)saveSettingsAndNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    BOOL showInMore = [defaults boolForKey:kEntryShowInMoreKey];
    BOOL showInPlugin = [defaults boolForKey:kEntryShowInPluginKey];

    CSEntryDisplayMode displayMode;
    if (showInMore && showInPlugin) {
        displayMode = CSEntryDisplayModeBoth;
    } else if (showInMore) {
        displayMode = CSEntryDisplayModeMore;
    } else if (showInPlugin) {
        displayMode = CSEntryDisplayModePlugin;
    } else {
        displayMode = CSEntryDisplayModeMore;
        [defaults setBool:YES forKey:kEntryShowInMoreKey];
    }

    [defaults setInteger:displayMode forKey:kEntryDisplayModeKey];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:kEntrySettingsChangedNotification object:nil];
}

- (void)showRestartConfirmAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"修改设置需要重启微信才能生效，是否立即重启？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"稍后重启" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"立即重启" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 数据设置

- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showInMore = [defaults boolForKey:kEntryShowInMoreKey];
    BOOL showInPlugin = [defaults boolForKey:kEntryShowInPluginKey];

    // 直接修改显示开关设置
    [defaults setBool:showInMore forKey:kEntryShowInMoreKey];
    [defaults setBool:showInPlugin forKey:kEntryShowInPluginKey];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // 单个部分
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2; // 显示两个设置项
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"显示在我页面";
    } else {
        cell.textLabel.text = @"显示在插件入口";
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"显示设置";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"选择插件入口在微信中的显示位置，修改后需要重启微信才能生效";
}

@end

