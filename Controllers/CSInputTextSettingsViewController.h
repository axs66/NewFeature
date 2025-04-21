// CSInputTextSettingsViewController.h
#import <UIKit/UIKit.h>
#import "CSSettingModels.h" // 添加这行

@interface CSInputTextSettingsViewController : UITableViewController <UIColorPickerViewControllerDelegate>

@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) NSArray<CSSettingSection *> *settingsData; // 添加这行保持兼容
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL colorTagTextColor;

@end
