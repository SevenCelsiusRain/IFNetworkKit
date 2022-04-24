//
//  IFViewController.m
//  IFNetworkKit
//
//  Created by 张高磊 on 01/05/2022.
//  Copyright (c) 2022 张高磊. All rights reserved.
//

#import "IFViewController.h"
#import "IFBlockController.h"
#import "IFDelegateController.h"

@interface IFViewController ()
@property (nonatomic, strong) UIButton *blcokButton;
@property (nonatomic, strong) UIButton *delegateButton;

@end

@implementation IFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private

- (void)setupViews {
    self.title = @"网络请求 Demo";
    [self.view addSubview:self.blcokButton];
    [self.view addSubview:self.delegateButton];
    
    self.blcokButton.frame = CGRectMake(100, 100, 150, 40);
    self.delegateButton.frame = CGRectMake(100, 200, 150, 40);
}


#pragma mark - event handler

- (void)delegateBtnAction {
    IFDelegateController *delegateVC = [[IFDelegateController alloc] init];
    [self.navigationController pushViewController:delegateVC animated:YES];
}

- (void)blockBtnAction {
    IFBlockController *blockVC = [[IFBlockController alloc] init];
    [self.navigationController pushViewController:blockVC animated:YES];
}



#pragma mark - getter

- (UIButton *)blcokButton {
    if (!_blcokButton) {
        _blcokButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_blcokButton setTitle:@"Block 样式" forState:UIControlStateNormal];
        [_blcokButton addTarget:self action:@selector(blockBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _blcokButton.backgroundColor = UIColor.darkGrayColor;
        _blcokButton.layer.cornerRadius = 4;
        _blcokButton.clipsToBounds = YES;
    }
    return _blcokButton;
}

- (UIButton *)delegateButton {
    if (!_delegateButton) {
        _delegateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delegateButton setTitle:@"Delegate 样式" forState:UIControlStateNormal];
        [_delegateButton addTarget:self action:@selector(delegateBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _delegateButton.backgroundColor = UIColor.darkGrayColor;
        _delegateButton.layer.cornerRadius = 4;
        _delegateButton.clipsToBounds = YES;
    }
    return _delegateButton;
}

@end
