//
//  IFViewController.m
//  IFNetworkKit
//
//  Created by 张高磊 on 01/05/2022.
//  Copyright (c) 2022 张高磊. All rights reserved.
//

#import "IFViewController.h"
#import "IFDataRequest.h"
#import "IFMyModelRequest.h"
#import "YYModel.h"
#import "IFDemoModel.h"

@interface IFViewController ()
@property (nonatomic, strong) UIButton *dataReqButton;
@property (nonatomic, strong) UIButton *modelReqButton;

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
    [self.view addSubview:self.dataReqButton];
    [self.view addSubview:self.modelReqButton];
    
    self.dataReqButton.frame = CGRectMake(100, 100, 150, 40);
    self.modelReqButton.frame = CGRectMake(100, 200, 150, 40);
}


#pragma mark - event handler

- (void)dataBtnAction {
    IFDataRequest *request = [[IFDataRequest alloc] init];
    [request startWithSuccessBlock:^(IFBaseRequest * _Nonnull request, id  _Nullable responseObject) {
        
        NSArray *modelArr = [NSArray yy_modelArrayWithClass:IFDemoModel.class json:responseObject[@"data"]];
        
        NSLog(@"");
    } failureBlock:^(IFBaseRequest * _Nonnull request, IFErrorResponseModel * _Nonnull errorModel) {
        NSLog(@"");
    }];
}

- (void)modelBtnAction {
    IFMyModelRequest *request = [[IFMyModelRequest alloc] init];
    [request startWithSuccessBlock:^(IFBaseRequest * _Nonnull request, id  _Nullable responseObject) {
        NSLog(@"");
    } failureBlock:^(IFBaseRequest * _Nonnull request, IFErrorResponseModel * _Nonnull errorModel) {
        NSLog(@"");
    }];
}



#pragma mark - getter

- (UIButton *)dataReqButton {
    if (!_dataReqButton) {
        _dataReqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dataReqButton setTitle:@"普通请求" forState:UIControlStateNormal];
        [_dataReqButton addTarget:self action:@selector(dataBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _dataReqButton.backgroundColor = UIColor.darkGrayColor;
        _dataReqButton.layer.cornerRadius = 4;
        _dataReqButton.clipsToBounds = YES;
    }
    return _dataReqButton;
}

- (UIButton *)modelReqButton {
    if (!_modelReqButton) {
        _modelReqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modelReqButton setTitle:@"Model 请求" forState:UIControlStateNormal];
        [_modelReqButton addTarget:self action:@selector(modelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _modelReqButton.backgroundColor = UIColor.darkGrayColor;
        _modelReqButton.layer.cornerRadius = 4;
        _modelReqButton.clipsToBounds = YES;
    }
    return _modelReqButton;
}



@end
