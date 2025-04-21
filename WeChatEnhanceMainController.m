#import "WeChatEnhanceMainController.h"

@interface WeChatEnhanceMainController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<NSDictionary *> *features;
@end

@implementation WeChatEnhanceMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"微信增强";

    self.features = @[
        @{@"title": @"头像显示增强", @"key": @"enableAvatarEnhance"},
        @{@"title": @"自定义导航栏", @"key": @"enableNavCustomization"},
        @{@"title": @"消息时间显示", @"key": @"enableTimeDisplay"},
        @{@"title": @"聊天附件管理", @"key": @"enableAttachmentMgr"},
        @{@"title": @"允许后台运行", @"key": @"enableBackground"},
        @{@"title": @"游戏作弊功能", @"key": @"enableGameHack"},
        @{@"title": @"视觉尺寸调整", @"key": @"enableVisualTweak"},
        @{@"title": @"用户信息显示控制", @"key": @"enableUserInfoDisplay"}
    ];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.features.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"featureCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.tag = 100;
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }

    NSDictionary *feature = self.features[indexPath.row];
    cell.textLabel.text = feature[@"title"];

    UISwitch *switchView = (UISwitch *)[cell viewWithTag:100];
    switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:feature[@"key"]];
    switchView.accessibilityIdentifier = feature[@"key"]; // 用于识别

    return cell;
}

#pragma mark - UISwitch Action

- (void)switchChanged:(UISwitch *)sender {
    NSString *key = sender.accessibilityIdentifier;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
