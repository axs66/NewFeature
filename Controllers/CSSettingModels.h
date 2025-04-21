// CSSettingModels.h
#import <UIKit/UIKit.h>

@interface CSSettingSection : NSObject
@property (nonatomic, copy) NSString *header;
@property (nonatomic, strong) NSArray *items;

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray *)items;
@end

@interface CSSettingItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) BOOL switchValue;
@property (nonatomic, copy) void (^valueChangedBlock)(BOOL);

+ (instancetype)itemWithTitle:(NSString *)title 
                     iconName:(NSString *)iconName 
                    iconColor:(UIColor *)iconColor 
                      detail:(NSString *)detail;

+ (instancetype)switchItemWithTitle:(NSString *)title 
                           iconName:(NSString *)iconName 
                          iconColor:(UIColor *)iconColor 
                       switchValue:(BOOL)switchValue 
                  valueChangedBlock:(void (^)(BOOL))block;
@end
