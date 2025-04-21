// 这是一个简单的 Preferences 开关注册方式
%hook PreferencesController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"WeChatEnhancePrefs" target:self];
    }
    return _specifiers;
}

%end
