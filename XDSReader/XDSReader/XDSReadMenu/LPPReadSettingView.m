//
//  LPPReadSettingView.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/19.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "LPPReadSettingView.h"
#import "LPPHaloButton.h"
@interface LPPReadSettingView()

@property (copy, nonatomic) NSArray *themsArray;
@property (copy, nonatomic) NSArray *effectArray;
@property (copy, nonatomic) NSArray *fontArray;
@property (copy, nonatomic) NSArray *fontSizeArray;
@end

@implementation LPPReadSettingView
CGFloat const kSettingThemesViewHeight = 74.f;
NSInteger const kSetingThemeButtonTag = 40;
NSInteger const kSetingEffectButtonTag = 10;
NSInteger const kSetingFontButtonTag = 20;
NSInteger const kSetingFontSizeButtonTag = 30;


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self dataInit];
        [self createUI];
    }
    return self;
}
//MARK: -  override super method

//MARK: - ABOUT UI UI相关
- (void)createUI{
    //主题
    [self createThemesView];
    //翻书动画
    [self createEffectView];
    //字体
    [self createFontView];
    //字号
    [self createFontSizeView];
}
- (void)createThemesView{
    // 创建颜色按钮
    NSInteger count = _themsArray.count;
    
    // 设置的index大于颜色数组
//    if selectIndex >= count {selectIndex = 0}
    
    
    CGFloat PublicButtonWH = CGSizeMake(39 + kSpace_lpp_20, 39 + kSpace_lpp_20).width;
    
    CGFloat spaceW = (DEVICE_MAIN_SCREEN_WIDTH_LPPR - 2 * kSpace_lpp_15 - count*PublicButtonWH)/(count-1);
    
    for (int i = 0; i < count; i ++) {
        UIColor *color = _themsArray[i];
        CGRect frame = CGRectMake(kSpace_lpp_15 + (PublicButtonWH + spaceW) * i,
                                  kSpace_lpp_15,
                                  PublicButtonWH,
                                  PublicButtonWH);
        LPPHaloButton *button = [[LPPHaloButton alloc] initWithFrame:frame haloColor:color];
        button.tag = kSetingThemeButtonTag + i;
        button.imageView.backgroundColor = color;
        [button addTarget:self action:@selector(themeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        if (CGColorEqualToColor([XDSReadConfig shareInstance].theme.CGColor, color.CGColor)) {
            button.selected = YES;
        }
    }

}
- (void)createEffectView{
    CGFloat height = (CGRectGetHeight(self.frame) - kSettingThemesViewHeight)/3;
    CGFloat originY = kSettingThemesViewHeight;
    // 标题
    CGRect titleFrame = CGRectMake(kSpace_lpp_25, originY, 55, height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = FONT_SYSTEM_LPP_12;
    titleLabel.text = @"翻书动画";
    [self addSubview:titleLabel];
    
    CGFloat tempX = CGRectGetMaxX(titleLabel.frame) + SIZE_WIDHT_LPP(50);
    CGFloat contentW = DEVICE_MAIN_SCREEN_WIDTH_LPPR - tempX;
    NSInteger count = _effectArray.count;
    CGFloat buttonW = contentW/count;
    for (int i = 0; i < count; i ++) {
        NSString *effect = _effectArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(tempX + buttonW*i, originY, buttonW, height);
        button.tag = kSetingEffectButtonTag + i;
        button.titleLabel.font = FONT_SYSTEM_LPP_12;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitle:effect forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:TEXT_COLOR_LPP_2 forState:UIControlStateSelected];
        [button addTarget:self action:@selector(effectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        if (i == 1) {
            button.selected = YES;
        }
    }
}
- (void)createFontView{
    CGFloat height = (CGRectGetHeight(self.frame) - kSettingThemesViewHeight)/3;
    CGFloat orginY = kSettingThemesViewHeight + height;
    // 标题
    CGRect titleFrame = CGRectMake(kSpace_lpp_25, orginY, 55, height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = FONT_SYSTEM_LPP_12;
    titleLabel.text = @"字体";
    [self addSubview:titleLabel];
    
    CGFloat tempX = CGRectGetMaxX(titleLabel.frame) + SIZE_WIDHT_LPP(50);
    CGFloat contentW = DEVICE_MAIN_SCREEN_WIDTH_LPPR - tempX;
    NSInteger count = _fontArray.count;
    CGFloat buttonW = contentW/count;
    for (int i = 0; i < count; i ++) {
        NSString *font = _fontArray[i][@"name"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(tempX + buttonW*i, orginY, buttonW, height);
        button.tag = kSetingFontButtonTag + i;
        button.titleLabel.font = FONT_SYSTEM_LPP_12;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitle:font forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:TEXT_COLOR_LPP_2 forState:UIControlStateSelected];
        [button addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        if ([[XDSReadConfig shareInstance].fontName isEqualToString:_fontArray[i][@"font"]]) {
            button.selected = YES;
        }
    }
}
- (void)createFontSizeView{
    CGFloat height = (CGRectGetHeight(self.frame) - kSettingThemesViewHeight)/3;
    CGFloat orginY = kSettingThemesViewHeight + height * 2;
    // 标题
    CGRect titleFrame = CGRectMake(kSpace_lpp_25, orginY, 55, height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = FONT_SYSTEM_LPP_12;
    titleLabel.text = @"字号";
    [self addSubview:titleLabel];
    
    CGFloat tempX = CGRectGetMaxX(titleLabel.frame) + SIZE_WIDHT_LPP(50);
    CGFloat contentW = DEVICE_MAIN_SCREEN_WIDTH_LPPR - tempX;

    CGFloat buttonW = (contentW - kSpace_lpp_15 - kSpace_lpp_1)/2;
    CGFloat buttonSpaceW = kSpace_lpp_1;
    
    // left
    UIButton *reduceFontSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reduceFontSizeButton.frame = CGRectMake(tempX, orginY, buttonW, height);
    
    reduceFontSizeButton.tag = kSetingFontSizeButtonTag + 0;
    reduceFontSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [reduceFontSizeButton setImage:[UIImage imageNamed:@"RM_15"] forState:UIControlStateNormal];
    [reduceFontSizeButton addTarget:self action:@selector(fontSizeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reduceFontSizeButton];
    
    // right
    UIButton *pulsFontSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pulsFontSizeButton.frame = CGRectMake(CGRectGetMaxX(reduceFontSizeButton.frame) - buttonSpaceW,
                                          orginY,
                                          buttonW,
                                          height);
    
    pulsFontSizeButton.tag = 1;
    pulsFontSizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [pulsFontSizeButton setImage:[UIImage imageNamed:@"RM_16"] forState:UIControlStateNormal];
    [pulsFontSizeButton addTarget:self action:@selector(fontSizeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pulsFontSizeButton];
}
//MARK: - DELEGATE METHODS 代理方法

//MARK: - ABOUT REQUEST 网络请求

//MARK: - ABOUT EVENTS 事件响应
- (void)themeButtonClick:(LPPHaloButton *)button{
    for (int i = 0; i < _themsArray.count; i ++) {
        LPPHaloButton *haloBtn = [self viewWithTag:kSetingThemeButtonTag + i];
        haloBtn.selected = NO;
    }
    button.selected = YES;
    NSInteger tag = button.tag - kSetingThemeButtonTag;
    if ([self.svDelegate respondsToSelector:@selector(readSettingView:didSelectedTheme:)]) {
        [self.svDelegate readSettingView:self didSelectedTheme:_themsArray[tag]];
    }
}
- (void)effectButtonClick:(UIButton *)button{
    for (int i = 0; i < _effectArray.count; i ++) {
        UIButton *btn = [self viewWithTag:kSetingEffectButtonTag + i];
        btn.selected = NO;
    }
    button.selected = YES;
    NSInteger tag = button.tag - kSetingEffectButtonTag;
    if ([self.svDelegate respondsToSelector:@selector(readSettingView:didSelectedEffect:)]) {
        [self.svDelegate readSettingView:self didSelectedEffect:_effectArray[tag]];
    }
}
- (void)fontButtonClick:(UIButton *)button{
    for (int i = 0; i < _fontArray.count; i ++) {
        UIButton *btn = [self viewWithTag:kSetingFontButtonTag + i];
        btn.selected = NO;
    }
    button.selected = YES;
    NSInteger tag = button.tag - kSetingFontButtonTag;
    if ([self.svDelegate respondsToSelector:@selector(readSettingView:didSelectedFont:)]) {
        [self.svDelegate readSettingView:self didSelectedFont:_fontArray[tag][@"font"]];
    }
}
- (void)fontSizeButtonClick:(UIButton *)button{
    NSInteger tag = button.tag - kSetingFontSizeButtonTag;
    if ([self.svDelegate respondsToSelector:@selector(readSettingView:didSelectedEffect:)]) {
        [self.svDelegate readSettingView:self didSelectedFontSize:tag];
    }
}

- (void)startHaloAnimate{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[LPPHaloButton class]]) {
            LPPHaloButton *haloBtn = (LPPHaloButton *)view;
            [haloBtn openHalo];
        }
    }
}
//MARK: - OTHER PRIVATE METHODS 私有方法

//MARK: - ABOUT MEMERY 内存管理
- (void)dataInit{
    self.themsArray = @[[UIColor whiteColor],
                        READ_BACKGROUND_COLOC_1,
                        READ_BACKGROUND_COLOC_2,
                        READ_BACKGROUND_COLOC_3,
                        READ_BACKGROUND_COLOC_4,
                        READ_BACKGROUND_COLOC_5];
    self.effectArray = @[@"无效果",@"平移",@"仿真",@"上下"];
    
    self.fontArray = @[@{@"name":@"系统",@"font":@""},
                       @{@"name":@"宋体",@"font":@"STSong"},
                       @{@"name":@"细黑",@"font":@"STXihei"},
                       @{@"name":@"行楷",@"font":@"STXingkai"}];

    self.fontSizeArray = @[];
}


@end
