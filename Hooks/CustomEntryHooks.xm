// CustomEntryHooks.xm 
// 微信自定义入口 Hook
// 该文件负责在微信注册自定义插件入口

#import "../Headers/CSUserInfoHelper.h"      // 微信相关的所有类和框架
#import "../Headers/WCHeaders.h"
#import "../Headers/WCPluginsHeader.h"
#import "../Controllers/CSEntrySettingsViewController.h" // 自定义设置页面

// 获取入口图标
static inline UIImage * __nullable getCustomEntryIcon(void) {
    // 使用系统图标并设置蓝色
    UIImage *icon = [UIImage systemImageNamed:@"signature.th"];
    return [icon imageWithTintColor:[UIColor systemBlueColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 获取显示模式设置
static CSEntryDisplayMode getEntryDisplayMode() {
    return CSEntryDisplayModeMore; // 固定显示模式
}

%hook MoreViewController

// 在"设置"页面添加功能入口
- (void)addFunctionSection {
    // 调用原始方法
    %orig;
    
    // 获取显示模式
    CSEntryDisplayMode displayMode = getEntryDisplayMode();
    
    // 如果设置为只在插件入口显示，则不添加到设置页面
    if (displayMode == CSEntryDisplayModePlugin) {
        return;
    }
    
    // 获取自定义标题
    NSString *entryTitle = @"自定义插件入口"; // 固定标题
    
    // 获取tableViewMgr
    WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");
    if (!tableViewMgr) { 
        return; 
    }
    
    // 获取第三个section（通常是功能区域）
    WCTableViewSectionManager *section = [tableViewMgr getSectionAt:2];
    if (!section) { 
        return; 
    }
    
    // 创建自定义入口cell
    WCTableViewCellManager *customEntryCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(onCustomEntryClick)
                                                                              target:self
                                                                           leftImage:getCustomEntryIcon()
                                                                              title:entryTitle
                                                                              badge:nil
                                                                         rightValue:nil
                                                                        rightImage:nil
                                                                   withRightRedDot:NO
                                                                          selected:NO];
    
    // 添加cell到section
    [section addCell:customEntryCell];
}

// 处理入口点击事件
%new
- (void)onCustomEntryClick {
    // 此处去掉了 CSCustomViewController 的实现
    // 你可以直接跳转到一个系统视图或执行其他操作
    NSLog(@"自定义插件入口点击");
}

%end

%hook MinimizeViewController

static int isRegister = 0;

-(void)viewDidLoad{
    %orig;
    
    // 获取显示模式
    CSEntryDisplayMode displayMode = getEntryDisplayMode();
    
    // 如果设置为只在设置页面显示，则不添加到插件入口
    if (displayMode == CSEntryDisplayModeMore) {
        return;
    }
    
    if (NSClassFromString(@"WCPluginsMgr") && isRegister == 0) {
        isRegister = 1;
        
        // 获取自定义标题
        NSString *title = @"自定义插件入口"; // 固定标题
        NSString *controller = @"CSCustomViewController";  // 你可以改为其他控制器或去掉
        
        @try {
            Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
            if (wcPluginsMgr) {
                id instance = [wcPluginsMgr performSelector:@selector(sharedInstance)];
                if (instance) {
                    SEL registerSel = @selector(registerControllerWithTitle:version:controller:);
                    if ([instance respondsToSelector:registerSel]) {
                        [instance registerControllerWithTitle:title version:@"1.0" controller:controller];
                    }
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"[WeChatTweak] 注册入口失败: %@", exception);
        }
    }
}
%end

%ctor {
    // 加载设置
    NSLog(@"[WeChatTweak] 入口设置已加载");
}
