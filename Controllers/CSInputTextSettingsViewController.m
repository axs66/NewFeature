#import "CSInputTextSettingsViewController.h"
#import "CSSettingModels.h"
#import <UIKit/UIKit.h>

// UserDefaults Key常量
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

// 默认值
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

#pragma mark - CSInputTextSettingsViewController 实现
@implementation CSInputTextSettingsViewController {
    NSArray<CSSettingSection *> *_sections;
    NSArray<CSSettingSection *> *_settingsData;
}

#pragma mark - 生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置视图
    self.title = @"文本占位";
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 初始化数据
    [self loadSavedColors];
    [self setupData];
}

#pragma mark - 数据管理
- (void)setupData {
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    // 示例配置项（根据实际需求补充完整）
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基本设置" items:@[
        [[CSSwitchSettingItem alloc] initWithTitle:@"启用文本占位" userDefaultsKey:kInputTextEnabledKey]
    ]];
    
    CSSettingSection *appearanceSection = [CSSettingSection sectionWithHeader:@"显示设置" items:@[
        [[CSTextInputSettingItem alloc] initWithTitle:@"占位文字" defaultValue:kDefaultInputText userDefaultsKey:kInputTextContentKey],
        [[CSColorPickerSettingItem alloc] initWithTitle:@"文字颜色" userDefaultsKey:kInputTextColorKey],
        [[CSSliderSettingItem alloc] initWithTitle:@"透明度" defaultValue:kDefaultTextAlpha userDefaultsKey:kInputTextAlphaKey]
    ]];
    
    [sectionsArray addObject:basicSection];
    [sectionsArray addObject:appearanceSection];
    
    // 设置最终的sections数组
    self.sections = sectionsArray;
    self.settingsData = sectionsArray; // 保持双向同步
}

- (void)loadSavedColors {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSError *error = nil;
    
    // 加载文字颜色
    NSData *textColorData = [defaults objectForKey:kInputTextColorKey];
    if (textColorData) {
        self.textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
        if (error || !self.textColor) {
            NSLog(@"解档文字颜色时出错: %@", error);
            self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
            error = nil;
        }
    } else {
        self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
    }
    
    // 加载边框颜色（示例代码）
    NSData *borderColorData = [defaults objectForKey:kInputTextBorderColorKey];
    if (borderColorData) {
        self.borderColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:borderColorData error:&error];
        if (error || !self.borderColor) {
            NSLog(@"解档边框颜色时出错: %@", error);
            self.borderColor = [UIColor clearColor];
            error = nil;
        }
    } else {
        self.borderColor = [UIColor clearColor];
    }
}

#pragma mark - 属性存取器
- (NSArray<CSSettingSection *> *)sections {
    return _sections;
}

- (void)setSections:(NSArray<CSSettingSection *> *)sections {
    _sections = [sections copy];
    _settingsData = [_sections copy];
}

- (NSArray<CSSettingSection *> *)settingsData {
    return _settingsData;
}

- (void)setSettingsData:(NSArray<CSSetingSection *> *)settingsData {
    _settingsData = [settingsData copy];
    _sections = [_settingsData copy];
}

@end
