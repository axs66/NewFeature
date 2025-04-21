// 删除重复定义 UILabel 类的部分

// 如果需要使用 UILabel，可以直接使用 UIKit 中的 UILabel
#import <UIKit/UIKit.h>

// 你的自定义属性可以根据需要重命名或调整
@interface MMMessageCellView : UIView
@property (nonatomic, copy) NSString *text; // 避免与 UILabel 的 text 属性冲突
@property (nonatomic, strong) UIColor *textColor; // 同样避免与 UILabel 的 textColor 属性冲突
@end
