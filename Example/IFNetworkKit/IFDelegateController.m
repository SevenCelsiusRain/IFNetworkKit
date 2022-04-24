//
//  IFDelegateController.m
//  IFNetworkKit_Example
//
//  Created by MrGLZh on 2022/4/24.
//  Copyright © 2022 张高磊. All rights reserved.
//

#import "IFDelegateController.h"
#import "IFDataRequest.h"
#import "IFMyModelRequest.h"
#import "YYModel.h"
#import "IFDemoModel.h"
#import "IFToast.h"

@interface IFDelegateController ()<IFRequestAccessory, IFRequestDelegate>{
    IFToastView *_toast;
}
@property (nonatomic, strong) UIButton *dataReqButton;
@property (nonatomic, strong) UIButton *modelReqButton;

@end

@implementation IFDelegateController

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
    self.title = @"Delegate 样式";
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.dataReqButton];
    [self.view addSubview:self.modelReqButton];
    
    self.dataReqButton.frame = CGRectMake(100, 100, 150, 40);
    self.modelReqButton.frame = CGRectMake(100, 200, 150, 40);
}


#pragma mark - IFRequestAccessory

- (void)if_requestWillStart:(__kindof IFBaseRequest *)request {
    _toast = [[IFToastView alloc] initWithImage:[YYImage imageNamed:@"loggingIn"]];
    [_toast showInCenter];
}

- (void)if_requestDidStop:(__kindof IFBaseRequest *)request {
    if (_toast) {
        [_toast hideAnimation];
    }
}


#pragma mark - IFRequestDelegate

- (void)if_requestFinished:(__kindof IFBaseRequest *)request {
    if ([request isKindOfClass:IFDataRequest.class]) {
        NSDictionary *dict = (NSDictionary *)request.responseObject;
        NSArray *modelArr = [NSArray yy_modelArrayWithClass:IFDemoModel.class json:dict[@"data"]];
        NSLog(@"");
    }
    
    if ([request isKindOfClass:IFModelRequest.class]) {
        
        IFResponseModel *responseModel = (IFResponseModel *)request.responseObject;
        NSArray *tempArr = responseModel.data;
        NSLog(@"");
    }
    NSLog(@"");
}

- (void)if_requestFailed:(__kindof IFBaseRequest *)request {
    NSLog(@"");
}


#pragma mark - event handler

- (void)dataBtnAction {
    IFDataRequest *request = [[IFDataRequest alloc] init];
    request.requestAccessories = @[self].mutableCopy;
    request.delegate = self;
    [request start];
}

- (void)modelBtnAction {
    IFMyModelRequest *request = [[IFMyModelRequest alloc] init];
    request.requestAccessories = @[self].mutableCopy;
    request.delegate = self;
    [request start];
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
