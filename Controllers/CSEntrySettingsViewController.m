#import "CSInputTextSettingsViewController.h"

@interface CSInputTextSettingsViewController ()

// 删除对 CSSettingSection, CSSettingItem, CSSettingTableViewCell 的所有引用

@end

@implementation CSInputTextSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"输入框设置";
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);

    [self setupData];
}

- (void)setupData {
    // 直接用数组代替自定义项
    NSArray *settingsItems = @[
        @{@"title": @"显示占位文本", @"type": @"switch", @"value": @(YES)},
        @{@"title": @"输入框圆角", @"type": @"switch", @"value": @(NO)},
        @{@"title": @"输入框边框", @"type": @"switch", @"value": @(YES)}
    ];
    
    // 设置 sectionsArray，直接使用 NSArray 替代
    NSMutableArray *sectionsArray = [NSMutableArray array];
    [sectionsArray addObject:settingsItems];
    
    // 直接把数组赋给表格的数据源
    self.settingsData = sectionsArray;
}

#pragma mark - TableView 数据源方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingsData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *item = self.settingsData[indexPath.section][indexPath.row];
    cell.textLabel.text = item[@"title"];

    if ([item[@"type"] isEqualToString:@"switch"]) {
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.on = [item[@"value"] boolValue];
        [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
    }

    return cell;
}

#pragma mark - Switch 控制

- (void)toggleChanged:(UISwitch *)sender {
    // 处理开关的状态变化
}

@end
