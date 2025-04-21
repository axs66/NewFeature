#import "CSEntrySettingsViewController.h"
#import <stdlib.h>

// 用户默认设置键
static NSString * const kEntryDisplayModeKey = @"com.wechat.tweak.entry.display.mode";
static NSString * const kEntrySettingsChangedNotification = @"com.wechat.tweak.entry.settings.changed";

// 开关设置键
static NSString * const kEntryShowInMoreKey = @"com.wechat.tweak.entry.show.in.more";
static NSString * const kEntryShowInPluginKey = @"com.wechat.tweak.entry.show.in.plugin";

@interface CSEntrySettingsViewController ()

// 设置项和分区
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;

// 开关设置项
@property (nonatomic, strong) CSSettingItem *showInMoreItem;
@property (nonatomic, strong) CSSettingItem *showInPluginItem;

@end

@implementation CSEntrySettingsViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"入口设置";
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);

    [CSSettingTableViewCell registerToTableView:self.tableView];

    [self loadCurrentSettings];
    [self setupData];
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

    self.showInMoreItem = [CSSettingItem switchItemWithTitle:@"显示在我页面"
                                                    iconName:@"person.fill"
                                                   iconColor:[UIColor systemBlueColor]
                                                 switchValue:showInMore
                                           valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kEntryShowInMoreKey];
        [self saveSettingsAndNotify];
        [self showRestartConfirmAlert];
    }];

    self.showInPluginItem = [CSSettingItem switchItemWithTitle:@"显示在插件入口"
                                                      iconName:@"apps.iphone"
                                                     iconColor:[UIColor systemGreenColor]
                                                   switchValue:showInPlugin
                                             valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kEntryShowInPluginKey];
        [self saveSettingsAndNotify];
        [self showRestartConfirmAlert];
    }];

    CSSettingItem *aboutItem = [CSSettingItem itemWithTitle:@"说明"
                                                  iconName:@"info.circle"
                                                 iconColor:[UIColor systemGrayColor]
                                                   detail:@"调整后需要重启微信"];

    CSSettingSection *displaySection = [CSSettingSection sectionWithHeader:@"显示设置"
                                                                      items:@[self.showInMoreItem,
                                                                              self.showInPluginItem]];

    CSSettingSection *aboutSection = [CSSettingSection sectionWithHeader:@"注意事项"
                                                                   items:@[aboutItem]];

    self.sections = @[displaySection, aboutSection];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"选择插件入口在微信中的显示位置，两个选项都可以开启，修改后需要重启微信才能生效";
    }
    return nil;
}

@end
