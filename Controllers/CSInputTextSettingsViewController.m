#import "CSInputTextSettingsViewController.h"
#import "CSSettingModels.h"
#import <UIKit/UIKit.h>

#pragma mark - 常量定义
// MARK: - UserDefaults Keys
static NSString * const kInputTextEnabledKey = @"com.wechat.enhance.inputText.enabled";
static NSString * const kInputTextContentKey = @"com.wechat.enhance.inputText.content";
static NSString * const kInputTextColorKey = @"com.wechat.enhance.inputText.color";
static NSString * const kInputTextAlphaKey = @"com.wechat.enhance.inputText.alpha";
static NSString * const kInputTextFontSizeKey = @"com.wechat.enhance.inputText.fontSize";
static NSString * const kInputTextBoldKey = @"com.wechat.enhance.inputText.bold";
static NSString * const kInputTextRoundedCornersKey = @"com.wechat.enhance.inputText.roundedCorners";
static NSString * const kInputTextCornerRadiusKey = @"com.wechat.enhance.inputText.cornerRadius";
static NSString * const kInputTextBorderEnabledKey = @"com.wechat.enhance.inputText.border.enabled";
static NSString * const kInputTextBorderWidthKey = @"com.wechat.enhance.inputText.border.width";
static NSString * const kInputTextBorderColorKey = @"com.wechat.enhance.inputText.border.color";

// MARK: - 默认值
static NSString * const kDefaultInputText = @"我爱你呀";
static CGFloat const kDefaultFontSize = 15.0f;
static CGFloat const kDefaultTextAlpha = 0.5f;
static CGFloat const kDefaultCornerRadius = 18.0f;
static CGFloat const kDefaultBorderWidth = 1.0f;

#pragma mark - CSSettingSection 实现
@implementation CSSettingSection

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray *)items {
    CSSettingSection *section = [[self alloc] init];
    section.header = header;
    section.items = items;
    return section;
}

@end

#pragma mark - CSInputTextSettingsViewController 完整实现
@interface CSInputTextSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL isBold;
// 其他属性声明...
@end

@implementation CSInputTextSettingsViewController {
    NSArray<CSSettingSection *> *_sections;
    NSArray<CSSettingSection *> *_settingsData;
}

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 完整配置表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 54;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    [self.tableView registerClass:[CSSettingTableViewCell class] forCellReuseIdentifier:@"SettingCell"];
    
    // 初始化数据
    [self loadAllSettings];
    [self buildSectionData];
}

#pragma mark - 数据同步核心逻辑
- (void)buildSectionData {
    NSMutableArray *sections = [NSMutableArray array];
    
    // 基础功能组
    CSSettingSection *baseSection = [CSSettingSection sectionWithHeader:@"核心功能" items:@[
        [[CSSwitchSettingItem alloc] initWithTitle:@"启用输入文本"
                                  userDefaultsKey:kInputTextEnabledKey
                                        changeAction:^(BOOL enabled) {
                                            [self toggleTextInputEnabled:enabled];
                                        }]
    ]];
    
    // 文本样式组
    CSSettingSection *styleSection = [CSSettingSection sectionWithHeader:@"文本样式" items:@[
        [[CSTextInputSettingItem alloc] initWithTitle:@"默认文本"
                                         defaultValue:kDefaultInputText
                                     userDefaultsKey:kInputTextContentKey],
        [[CSFontSizeSettingItem alloc] initWithTitle:@"字体大小"
                                        defaultValue:kDefaultFontSize
                                               range:NSMakeRange(12, 36)
                                   userDefaultsKey:kInputTextFontSizeKey],
        [[CSColorPickerSettingItem alloc] initWithTitle:@"文字颜色"
                                        userDefaultsKey:kInputTextColorKey
                                          colorUpdateHandler:^(UIColor *selectedColor) {
                                              [self updateTextColor:selectedColor];
                                          }]
    ]];
    
    // 边框设置组
    CSSettingSection *borderSection = [CSSettingSection sectionWithHeader:@"边框样式" items:@[
        [[CSSwitchSettingItem alloc] initWithTitle:@"启用边框"
                                  userDefaultsKey:kInputTextBorderEnabledKey
                                    changeAction:^(BOOL enabled) {
                                        [self toggleBorderEnabled:enabled];
                                    }],
        [[CSSliderSettingItem alloc] initWithTitle:@"边框粗细"
                                      defaultValue:kDefaultBorderWidth
                                             range:NSMakeRange(0.5, 5.0)
                                  userDefaultsKey:kInputTextBorderWidthKey],
        [[CSColorPickerSettingItem alloc] initWithTitle:@"边框颜色"
                                        userDefaultsKey:kInputTextBorderColorKey
                                  colorUpdateHandler:^(UIColor *selectedColor) {
                                      [self updateBorderColor:selectedColor];
                                  }]
    ]];
    
    [sections addObject:baseSection];
    [sections addObject:styleSection];
    [sections addObject:borderSection];
    
    // 保持双向数据同步
    self.sections = [sections copy];
    self.settingsData = [sections copy];
}

#pragma mark - 数据持久化
- (void)loadAllSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 加载文字颜色
    NSData *textColorData = [defaults objectForKey:kInputTextColorKey];
    if (textColorData) {
        NSError *error;
        self.textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                           fromData:textColorData
                                                              error:&error];
        if (error) NSLog(@"文字颜色加载失败: %@", error);
    }
    
    // 加载边框颜色
    NSData *borderColorData = [defaults objectForKey:kInputTextBorderColorKey];
    if (borderColorData) {
        NSError *error;
        self.borderColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                             fromData:borderColorData
                                                                error:&error];
        if (error) NSLog(@"边框颜色加载失败: %@", error);
    }
    
    // 加载其他设置项...
}

#pragma mark - 双向同步实现
- (NSArray<CSSettingSection *> *)sections {
    return _sections ?: @[];
}

- (void)setSections:(NSArray<CSSettingSection *> *)sections {
    _sections = [sections copy];
    _settingsData = [_sections copy];
    [self.tableView reloadData];
}

- (NSArray<CSSettingSection *> *)settingsData {
    return _settingsData ?: @[];
}

- (void)setSettingsData:(NSArray<CSSettingSection *> *)settingsData {
    _settingsData = [settingsData copy];
    _sections = [_settingsData copy];
    [self.tableView reloadData];
}

#pragma mark - 表格视图代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [item handleSelection];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 业务逻辑方法
- (void)toggleTextInputEnabled:(BOOL)enabled {
    // 实现开关状态变化的业务逻辑
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kInputTextEnabledKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextInputEnabledChanged" object:@(enabled)];
}

- (void)updateTextColor:(UIColor *)color {
    // 实现颜色更新的业务逻辑
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color
                                              requiringSecureCoding:YES
                                                              error:&error];
    if (!error) {
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kInputTextColorKey];
    }
