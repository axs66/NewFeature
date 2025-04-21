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

@implementation CSSettingSection

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray *)items {
    CSSettingSection *section = [[self alloc] init];
    section.header = header;
    section.items = items;
    return section;
}

@end

@implementation CSInputTextSettingsViewController {
    NSArray<CSSettingSection *> *_sections;
    NSArray<CSSettingSection *> *_settingsData;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"文本占位";
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    [CSSettingTableViewCell registerToTableView:self.tableView];
    [self loadSavedColors];
    [self setupData];
}

#pragma mark - Data Management
- (void)setupData {
    // ... 原有代码 ...
    
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
    
    // 加载边框颜色
    NSData *borderColorData = [defaults objectForKey:kInputTextBorderColorKey];
    // ... 类似处理边框颜色 ...
}

#pragma mark - Property Accessors
- (NSArray<CSSettingSection *> *)sections {
    return _sections;
}

- (void)setSections:(NSArray<CSSettingSection *> *)sections {
    _sections = sections;
    _settingsData = sections;
}

- (NSArray<CSSettingSection *> *)settingsData {
    return _settingsData;
}

- (void)setSettingsData:(NSArray<CSSettingSection *> *)settingsData {
    _settingsData = settingsData;
    _sections = settingsData;
}

@end
