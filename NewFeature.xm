// 聊天输入框占位文本Hook
// 在输入框显示自定义的灰色文本

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "WCPluginsHeader.h"

static NSString *wbzybt = @"NewFeature";
static NSString *wbzybb = @"5.2.0";

// UserDefaults Key常量
static NSString * const kInputTextEnabledKey = @"com.wechat.enhance.inputText.enabled";
static NSString * const kInputTextContentKey = @"com.wechat.enhance.inputText.content";
static NSString * const kInputTextColorKey = @"com.wechat.enhance.inputText.color";
static NSString * const kInputTextAlphaKey = @"com.wechat.enhance.inputText.alpha";
static NSString * const kInputTextFontSizeKey = @"com.wechat.enhance.inputText.fontSize";
static NSString * const kInputTextBoldKey = @"com.wechat.enhance.inputText.bold";
// 添加输入框圆角设置键
static NSString * const kInputTextRoundedCornersKey = @"com.wechat.enhance.inputText.roundedCorners";
// 添加圆角大小设置键
static NSString * const kInputTextCornerRadiusKey = @"com.wechat.enhance.inputText.cornerRadius";
// 添加边框相关设置键
static NSString * const kInputTextBorderEnabledKey = @"com.wechat.enhance.inputText.border.enabled";
static NSString * const kInputTextBorderWidthKey = @"com.wechat.enhance.inputText.border.width";
static NSString * const kInputTextBorderColorKey = @"com.wechat.enhance.inputText.border.color";

// 默认值
static NSString * const kDefaultInputText = @"我爱你呀";
static CGFloat const kDefaultFontSize = 15.0f;
static CGFloat const kDefaultTextAlpha = 0.5f;
// 输入框圆角大小
static CGFloat const kDefaultCornerRadius = 18.0f;
// 输入框边框默认值
static CGFloat const kDefaultBorderWidth = 1.0f;

// 存储当前是否在聊天界面
static BOOL isInChatView = NO;

// 聊天界面声明
@interface BaseMsgContentViewController : UIViewController
- (id)GetContact;
@end

// 类声明
@interface MMGrowTextView : UIView
@property(nonatomic) __weak NSString *placeHolder;
@property(nonatomic) __weak NSAttributedString *attributePlaceholder;
- (void)setPlaceHolderColor:(UIColor *)color;
- (void)setPlaceHolderMultiLine:(BOOL)multiLine;
@end

@interface MMInputToolView : UIView
@property(retain, nonatomic) MMGrowTextView *textView;
@end

// 检查功能是否启用
static BOOL isInputTextEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextEnabledKey];
}

// 检查输入框圆角是否启用
static BOOL isInputTextRoundedCornersEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextRoundedCornersKey];
}

// 检查输入框边框是否启用
static BOOL isInputTextBorderEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextBorderEnabledKey];
}

// 检查是否应该应用输入框样式(必须在聊天界面且功能启用)
static BOOL shouldApplyInputTextStyle() {
    return isInChatView && isInputTextEnabled();
}

// 检查是否应该应用圆角样式(必须在聊天界面且功能启用)
static BOOL shouldApplyRoundedCorners() {
    return isInChatView && isInputTextRoundedCornersEnabled();
}

// 检查是否应该应用边框样式(必须在聊天界面且功能启用)
static BOOL shouldApplyBorder() {
    return isInChatView && isInputTextBorderEnabled();
}

// 获取圆角大小设置
static CGFloat getCornerRadius() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat cornerRadius = [defaults floatForKey:kInputTextCornerRadiusKey];
    // 如果没有设置过或者值为0，返回默认值
    if (cornerRadius <= 0) {
        cornerRadius = kDefaultCornerRadius;
    }
    return cornerRadius;
}

// 获取边框宽度设置
static CGFloat getBorderWidth() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat borderWidth = [defaults floatForKey:kInputTextBorderWidthKey];
    // 如果没有设置过或者值为0，返回默认值
    if (borderWidth <= 0) {
        borderWidth = kDefaultBorderWidth;
    }
    return borderWidth;
}

// 获取边框颜色设置
static UIColor *getBorderColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kInputTextBorderColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error) {
            return savedColor;
        }
        if (error) {
            NSLog(@"解档边框颜色时出错: %@", error);
        }
    }
    // 返回默认颜色
    return [UIColor systemGrayColor];
}

// 获取保存的设置内容
static NSString *getInputTextContent() {
    NSString *savedText = [[NSUserDefaults standardUserDefaults] objectForKey:kInputTextContentKey];
    return savedText.length > 0 ? savedText : kDefaultInputText;
}

// 获取文字颜色设置
static UIColor *getTextColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kInputTextColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error) {
            // 应用保存的文字透明度
            CGFloat alpha = [defaults floatForKey:kInputTextAlphaKey];
            if (alpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
                alpha = kDefaultTextAlpha;
            }
            return [savedColor colorWithAlphaComponent:alpha];
        }
        if (error) {
            NSLog(@"解档文字颜色时出错: %@", error);
        }
    }
    // 返回默认颜色
    CGFloat alpha = [defaults floatForKey:kInputTextAlphaKey];
    if (alpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
        alpha = kDefaultTextAlpha;
    }
    return [UIColor colorWithWhite:0.5 alpha:alpha];
}

// 应用圆角和边框设置
static void applyRoundedCornersIfNeeded(MMGrowTextView *textView) {
    BOOL shouldApplyCorners = shouldApplyRoundedCorners();
    BOOL shouldApplyBorderStyle = shouldApplyBorder();
    
    if (!shouldApplyCorners && !shouldApplyBorderStyle) {
        // 如果圆角和边框功能都未启用或不在聊天界面，将圆角和边框重置为0
        textView.layer.cornerRadius = 0;
        textView.layer.borderWidth = 0;
        textView.clipsToBounds = NO;
        return;
    }
    
    // 获取用户设置
    CGFloat cornerRadius = shouldApplyCorners ? getCornerRadius() : 0;
    CGFloat borderWidth = shouldApplyBorderStyle ? getBorderWidth() : 0;
    UIColor *borderColor = shouldApplyBorderStyle ? getBorderColorFromDefaults() : [UIColor clearColor];
    
    // 只在最外层容器应用圆角和边框
    textView.layer.cornerRadius = cornerRadius;
    textView.layer.borderWidth = borderWidth;
    textView.layer.borderColor = borderColor.CGColor;
    textView.clipsToBounds = (cornerRadius > 0);
}

// 应用占位文本设置的辅助函数
static void applyPlaceHolderSettings(MMGrowTextView *textView) {
    if (!shouldApplyInputTextStyle()) {
        // 即使不应用占位文本，也尝试应用圆角和边框设置
        if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            applyRoundedCornersIfNeeded(textView);
        }
        return;
    }
    
    // 获取自定义设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *customText = getInputTextContent();
    CGFloat fontSize = [defaults floatForKey:kInputTextFontSizeKey];
    if (fontSize <= 0) fontSize = kDefaultFontSize;
    BOOL isBold = [defaults boolForKey:kInputTextBoldKey];
    
    // 设置颜色
    UIColor *textColor = getTextColorFromDefaults();
    [textView setPlaceHolderColor:textColor];
    
    // 支持多行
    [textView setPlaceHolderMultiLine:YES];
    
    // 创建字体
    UIFont *font = isBold ? 
        [UIFont boldSystemFontOfSize:fontSize] : 
        [UIFont systemFontOfSize:fontSize];
    
    // 设置富文本样式的占位文本
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: textColor,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] 
                                               initWithString:customText 
                                               attributes:attributes];
    
    textView.attributePlaceholder = attributedPlaceholder;
    
    // 同时设置普通占位文本，以防富文本设置无效
    textView.placeHolder = customText;
    
    // 应用圆角和边框设置
    applyRoundedCornersIfNeeded(textView);
}

// Hook BaseMsgContentViewController来识别聊天界面
%hook BaseMsgContentViewController

- (void)viewDidLoad {
    %orig;
    isInChatView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    isInChatView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    isInChatView = NO;
}

%end

// Hook MMGrowTextView类，这是微信的输入框类
%hook MMGrowTextView

- (id)init {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithExtConfig:(id)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 extConfig:(id)arg2 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithDonotNeedTextViewContentTopBottomInset:(_Bool)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithDonotNeedTextViewContentTopBottomInset:(_Bool)arg1 matchInnerViewHeightWithFrame:(_Bool)arg2 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 WithDonotNeedTextViewContentTopBottomInset:(_Bool)arg2 extConfig:(id)arg3 matchInnerViewHeightWithFrame:(_Bool)arg4 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

// 添加布局后的处理，确保圆角设置正确应用
- (void)layoutSubviews {
    %orig;
    // 应用圆角设置，即使placeholder功能未启用
    if (shouldApplyRoundedCorners()) {
        applyRoundedCornersIfNeeded(self);
    }
}

%end

// Hook MMInputToolView，确保在视图更新时总是设置占位文本和圆角
%hook MMInputToolView

- (void)layoutSubviews {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)updateToolViewHeight:(_Bool)arg1 {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)onWillAppear {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)onViewDidInit {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

%end

%hook MinimizeViewController

- (void)viewDidLoad {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            @try {
                Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
                id instance = [wcPluginsMgr performSelector:@selector(sharedInstance)];
                if (instance && [instance respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) {
                    [instance registerControllerWithTitle:wbzybt
                                               version:wbzybb
                                            controller:@"CS1InputTextSettingsViewController"];
                }
            } @catch (NSException *exception) {}
    });
}

%end


// WCIsOverSeaUser微信通行密钥

%hook SettingUtil
+ (BOOL)isOverSeaUser {
	return YES;
}
%end


// WCNewMiniAppFloatingWindow微信启用AB测试的miniApp悬浮窗功能，仅限8.0.54+版本

%hook AffStarManager
- (BOOL)isOpenStarSwitch {
	return YES;
}
%end


// WCSVGColorHookExamples微信SVG图片颜色修改
/* 默认示范随机颜色*/ 
UIColor *randomColor(void) {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    CGFloat alpha = (arc4random_uniform(31) + 70) / 100.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

%hook MMThemeManager
- (UIImage *)svgImageNamed:(NSString *)name size:(struct CGSize)size color:(id)color alpha:(double)alpha angle:(int)angle ignoreNotFound:(BOOL)ignore {
    /* 当然 在这里你可以判断指定修改的SVG图片名称 */
	return %orig(name, size, randomColor(), alpha, angle, ignore);
}
%end


// WCKeyboardHideLogo微信键盘隐藏Logo

%hook WBMainInputView
- (BOOL)shouldHideLogoForAccessoryView {
    return YES;
}
%end


// WCABTestSingleChatBox微信启用AB测试单聊框功能，仅限8.0.55+版本

%hook ChatBoxConfigurationMgr
- (BOOL)isSingleChatBoxEnable {
	return YES;
}
%end


// WCABTestVoiceRecordView语音弧形按钮，仅限8.0.60+版本

%hook VoiceRecordView
+ (BOOL)isNewButtonStyle {
	return YES;
}
%end


// WCABTestLocalBackup聊天记录自动备份，仅限8.0.50+版本

unsigned long long hook_isOpenNewBackup(id self, SEL _cmd) {
    return 1;
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class cls = objc_getClass("WXGRoamBackupPackageService");
        Method md = class_getInstanceMethod(cls, @selector(isOpenNewBackup));
        if (md) {
            class_replaceMethod(cls, @selector(isOpenNewBackup), (IMP)hook_isOpenNewBackup, method_getTypeEncoding(md));
        }
    });
}


// WCABTestTimeLineEmoticonOrImage微信朋友圈图片评论，仅限8.0.60+版本

%hook WCMomentsPageContext
- (BOOL)supportCommentImagePost {
    return YES;
}
- (BOOL)supportCommentImageBrowse {
    return YES;
}
- (BOOL)supportCommentEmoticonPost {
    return YES;
}
- (BOOL)supportCommentEmoticonBrowse {
    return YES;
}
- (BOOL)supportCommentEmoticonOrImagePost {
    return YES;
}
- (BOOL)supportCommentEmoticonOrImageBrowse {
    return YES;
}
%end


// WCABTestC2CLivePhoto微信启用聊天发送实时照片，仅限8.0.57+版本

%hook ImageMessageUtils
+ (BOOL)isOpenLiveMsgUpload {
    return YES;
}
%end


// WCABTestDeleteUserKeepHistory微信启用删除联系人保留聊天记录，仅限8.0.62+版本

%hook ContactUtils
+ (BOOL)getDeleteContactKeepChatHistoryOpenSwitch {
	return YES;
}
%end


// WBNoAds微信去广告
@interface WBAdSdkFlashAdView : UIView
- (void)closeAd:(unsigned long long)arg1;
@end

%hook WBAdSdkFlashAdView

- (void)didMoveToSuperview {
    %log;
    %orig;

    if (self.superview) {
        [self setHidden:YES];
        [self closeAd:2];
    }
}

%end

%hook WBReadRedPacketView
- (id)initWithFrame:(struct CGRect)arg1 completeCount:(long long)arg2 {
    return 0;
}
%end

%hook WBNavLotteryButton
- (id)initWithFrame:(struct CGRect)arg1 {
    return 0;
}
%end


// WCEnableDictation微信输入框语音转述功能，仅限8.0.61+版本

%hook MMGrowTextViewExtConfig

- (BOOL)enableDictation {
    return YES;
}

- (void)setEnableDictation:(BOOL)arg1 {
    %orig(YES);
}

%end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        %init;
    });
}


// WCFullSwipe微信添加全局屏幕中间返回功能

@interface MMUIViewController : UIViewController
@property (nonatomic, readonly) UINavigationController *navigationController;
@end

%hook MMUIViewController

- (void)viewDidLoad {
    %orig;

    UIGestureRecognizer *edgeGesture = self.navigationController.interactivePopGestureRecognizer;
    edgeGesture.enabled = YES;

    NSArray *targets = [edgeGesture valueForKey:@"_targets"];
    id targetObj = [targets.firstObject valueForKey:@"target"];
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");

    UIPanGestureRecognizer *fullScreenPan = [[UIPanGestureRecognizer alloc] initWithTarget:targetObj action:action];
    fullScreenPan.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    fullScreenPan.maximumNumberOfTouches = 1;
    
    fullScreenPan.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:fullScreenPan];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && 
        gestureRecognizer != self.navigationController.interactivePopGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint location = [panGesture locationInView:self.view];
        CGFloat screenWidth = self.view.bounds.size.width;
        
        BOOL isInMiddleArea = location.x > screenWidth/3 && location.x < screenWidth*2/3;
        
        CGPoint translation = [panGesture translationInView:self.view];
        BOOL isHorizontalSwipe = fabs(translation.x) > fabs(translation.y);
        BOOL isRightSwipe = translation.x > 0;
        
        return isInMiddleArea && isHorizontalSwipe && isRightSwipe;
    }
    
    return %orig;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    if (gestureRecognizer != self.navigationController.interactivePopGestureRecognizer && 
        [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (otherGestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
            return NO;
        }
        
        return NO;
    }
    
    return NO;
}

%end


// WCEnhance重命名【我】页面、添加图片点击关闭手势、移除加好友页面我的二维码大图
@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@end

@interface WCC2CImageScrollView : UIView
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
@end

@interface CExtendInfoOfImg : NSObject
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(_Bool)arg3;
- (void)setImage:(id)arg1 withData:(id)arg2 isOriginImage:(BOOL)arg3;
@end

%hook WCTableViewCellLeftConfig

- (NSString *)title {
	NSString *r = %orig;
	
	if (r == nil) {
		return nil;
	}
	if ([r isEqualToString:@"订单与卡包"]) {
		return @"卡包";
	}
	if ([r isEqualToString:@"支付与服务"]) {
		return @"服务";
	}
	
	return r;
}

%end

%hook UIButton

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
	%orig;

	if ([accessibilityLabel isEqualToString:@"我的⼆维码"]) {

		self.hidden = YES;
	}
}

%end

%hook WCC2CImageScrollView

- (void)layoutSubviews {
	%orig;
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
	if ([version compare:@"8.0.55" options:NSNumericSearch] != NSOrderedAscending) {
		BOOL hasGesture = NO;
		for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
			if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
				hasGesture = YES;
				break;
			}
		}
		
		if (!hasGesture) {
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
			[self addGestureRecognizer:tap];
		}
	}
	
	NSArray *subviews = [self.subviews copy];
	for (UIView *subview in subviews) {
		if ([subview class] == [UIView class]) {
			[subview removeFromSuperview];
		}
	}
}

%new
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	CGPoint location = [gesture locationInView:self];
	CGFloat width = self.bounds.size.width;
	CGFloat edgeWidth = width * 0.2;
	
	if (location.x <= edgeWidth || location.x >= (width - edgeWidth)) {
		SEL closeSelector = NSSelectorFromString(@"onCloseBtnClick:");
		if ([self respondsToSelector:closeSelector]) {
			[self performSelector:closeSelector withObject:nil];
		}
	}
}

%end

%hook CExtendInfoOfImg
%new
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(BOOL)arg3 {
	[self setImage:arg1 withData:arg2 isOriginImage:arg3];
}
%end


// WCEnableCleanOrigMsg原图、原视频14天后自动清理，仅限8.0.54+版本
%hook HDImageExpireUtils
+ (_Bool)isExptCleanOriginMsgOpened{
    return YES;
}
%end
