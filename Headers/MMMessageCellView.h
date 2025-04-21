@interface UILabel : UIView
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@end

@interface MMMessageCellView : UIView
@property (nonatomic, strong) UILabel *timestampLabel;
@end
