//
//  JJKeyboardBarTextField.m
//  employer
//
//  Created by 贾克利 on 15/11/12.
//  Copyright © 2015年 com.jiajiao2o. All rights reserved.
//

#import "CJKeyboardBarTextField.h"

@interface CJKeyboardBarTextField ()

@property (nonatomic,weak) UITextField *textField;
@property (nonatomic,strong) UIButton *returnBtn;
@property (nonatomic,strong) UIView *controllerView;
@property (nonatomic,strong) UIView *toolBar;
@property (nonatomic,strong) UITextField *toolBarTextField;

@end

@implementation CJKeyboardBarTextField

#define fieldPadding	10
#define toolbarHeight	38
#define returnBtnWidth  50
#define toolBarTextFieldTopPadding  4

- (UITextField *)toolBarTextField{
    if (!_toolBarTextField) {
        _toolBarTextField = [[UITextField alloc]initWithFrame:CGRectMake(fieldPadding, toolBarTextFieldTopPadding,self.controllerView.frame.size.width-self.returnBtn.frame.size.width - fieldPadding*3, toolbarHeight-8)];
        _toolBarTextField.backgroundColor = [UIColor whiteColor];
        _toolBarTextField.borderStyle = UITextBorderStyleRoundedRect;
        _toolBarTextField.keyboardType = self.keyboardType;
        _toolBarTextField.secureTextEntry = self.secureTextEntry;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:_toolBarTextField];
    }
    return _toolBarTextField;
}

- (UIView *)toolBar{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.controllerView.frame.size.height, self.controllerView.frame.size.width, toolbarHeight)];
        _toolBar.backgroundColor = [UIColor whiteColor];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _toolBar.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_toolBar addSubview:line];
    }
    return _toolBar;
}

- (UIView *)controllerView{
    if (!_controllerView) {
        UIViewController *vc = [self viewController];
        _controllerView = vc.view;
    }
    return _controllerView;
}

- (UIButton *)returnBtn{
    if (!_returnBtn) {
        _returnBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.controllerView.frame.size.width - returnBtnWidth - fieldPadding, 0, 50, toolbarHeight)];
        [_returnBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_returnBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_returnBtn addTarget:self action:@selector(returnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnBtn;
}

- (id)initWithCoder:(NSCoder *)aDecoder	{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)done {
    [self resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (![self isFirstResponder]) return;
    
    NSDictionary *info = [notification userInfo];
    CGRect kbFrame = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newKbFrame = [self.window convertRect:kbFrame toView:self.controllerView];
    self.toolBarTextField.text = self.text;
    [self.toolBar addSubview:self.returnBtn];
    [self.toolBar addSubview:self.toolBarTextField];
    [self.controllerView addSubview:self.toolBar];
    
    CGRect textFiledInControllerFrame = [self.superview convertRect:self.frame toView:self.controllerView];
    if (textFiledInControllerFrame.origin.y <= newKbFrame.origin.y - toolbarHeight) {
        return;
    }
    CGFloat toolBarY = newKbFrame.origin.y - toolbarHeight;
    [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        self.toolBar.frame = CGRectMake(0, toolBarY, kbFrame.size.width, toolbarHeight);
            } completion:^(BOOL finished){
                [self.toolBarTextField becomeFirstResponder];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        self.toolBar.frame = CGRectMake(0, self.controllerView.frame.size.height, self.controllerView.frame.size.width, toolbarHeight);
    } completion:^(BOOL finished){
    }];
}

- (void)returnBtnClick:(UIButton *)button{
    [self.toolBarTextField resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        //如果你的controller继承了另一个controller  那么请修改这里的class类型
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;  
}

- (void)textFieldChanged{
    self.text = self.toolBarTextField.text;
}

@end
