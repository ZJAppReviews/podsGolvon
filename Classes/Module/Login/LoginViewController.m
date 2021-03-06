//
//  LoginViewController.m
//  podsGolvon
//
//  Created by 李盼盼 on 16/11/1.
//  Copyright © 2016年 suhuilong. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"
#import "UserDetailViewController.h"
#import "TabBarViewController.h"
#import "DetailHeaderModel.h"

@interface LoginViewController ()<UITextFieldDelegate>


@property (strong, nonatomic) UIImageView      *headerImageView;

@property (strong, nonatomic) UITextField      *codeText;

@property (strong, nonatomic) UIButton      *codeBtn;

@property (strong, nonatomic) MBProgressHUD      *HUD;

@property (nonatomic,assign) NSInteger  timeCount;

@property (strong, nonatomic)NSTimer *timer;

@property (strong, nonatomic) DownLoadDataSource      *loadData;

@property (copy, nonatomic) NSString *name_id;

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(DownLoadDataSource *)loadData{
    if (!_loadData) {
        _loadData = [[DownLoadDataSource alloc] init];
    }
    return _loadData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor: WhiteColor];
    [self createSubview];
    [userDefaults setObject:@"0" forKey:@"name_id"];
    self.timeCount = 60;

}

-(void)createSubview{
    
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.frame = CGRectMake((ScreenWidth - kWvertical(82))/2, kHvertical(48), kWvertical(82), kWvertical(82));
    NSString *str = [userDefaults objectForKey:@"pic"];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:str]];
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = kWvertical(82)/2;
    [self.view addSubview:_headerImageView];
    
    _phoneNum = [userDefaults objectForKey:@"phone"];
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"%@",_phoneNum];
    [mStr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    phoneLabel.frame = CGRectMake(0, _headerImageView.bottom + kHvertical(12), ScreenWidth, kHvertical(21));
    phoneLabel.textColor = GPColor(47, 47, 47);
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.font = [UIFont systemFontOfSize:kHorizontal(15)];
    phoneLabel.text = mStr;
    [self.view addSubview:phoneLabel];
    
    
    _codeText = [[UITextField alloc] init];
    _codeText.delegate = self;
    _codeText.font = [UIFont systemFontOfSize:kHorizontal(14)];
    _codeText.frame = CGRectMake(kWvertical(28), _headerImageView.bottom + kHvertical(63), kWvertical(240), kHvertical(41));
    _codeText.placeholder = @"验证码";
    _codeText.keyboardType = UIKeyboardTypeNumberPad;
    _codeText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_codeText];
    
    
    
    //    获取验证码
    UIView *line3 = [[UIView alloc] init];
    line3.frame = CGRectMake(ScreenWidth - kWvertical(104), _codeText.y + kHvertical(18), 0.5, kHvertical(16));
    line3.backgroundColor = TINTLINCOLOR;
    [self.view addSubview:line3];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(ScreenWidth - kWvertical(105), _codeText.y, kWvertical(105), kHvertical(45));
    [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_codeBtn setTitleColor:localColor forState:UIControlStateNormal];
    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:kHorizontal(13)];
    [_codeBtn addTarget:self action:@selector(ClickCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_codeBtn];
    
    UIView *line2 = [[UIView alloc] init];
    line2.frame = CGRectMake((ScreenWidth - kWvertical(335))/2, _codeText.bottom, kWvertical(335), 0.5);
    line2.backgroundColor = TINTLINCOLOR;
    [self.view addSubview:line2];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeBtn setTitle:@"登录" forState:UIControlStateNormal];
    completeBtn.frame = CGRectMake((ScreenWidth - kWvertical(335))/2, phoneLabel.bottom + kHvertical(88), kWvertical(335), kHvertical(42));
    completeBtn.layer.masksToBounds = YES;
    completeBtn.layer.cornerRadius = 3;
    [completeBtn addTarget:self action:@selector(clickNextStep) forControlEvents:UIControlEventTouchUpInside];
    [completeBtn setTitleColor:WhiteColor forState:UIControlStateNormal];
    [completeBtn setBackgroundColor:GPColor(53, 141, 227)];
    [self.view addSubview:completeBtn];
    
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.frame = CGRectMake((ScreenWidth - kWvertical(80))/2, kHvertical(316), kWvertical(80), kHvertical(25));
    [changeBtn setTitle:@"账号切换" forState:UIControlStateNormal];
    [changeBtn setTitleColor:localColor forState:UIControlStateNormal];
    changeBtn.titleLabel.font = [UIFont systemFontOfSize:kHorizontal(14)];
    [changeBtn addTarget:self action:@selector(clickChangeBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];
    
    
    //    服务条款
    UILabel *UserDetail = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - kWvertical(148))/2+kWvertical(22), ScreenHeight - kHvertical(32), kWvertical(148), HScale(2.5))];
    UserDetail.text = @"我已阅读并同意 服务条款";
    UserDetail.font = [UIFont systemFontOfSize:kHorizontal(13)];
    UserDetail.textColor = [UIColor lightGrayColor];
    
    NSMutableAttributedString *attributed1 = [[NSMutableAttributedString alloc]initWithString:UserDetail.text];
    [attributed1 addAttribute:NSForegroundColorAttributeName value:localColor range:NSMakeRange(attributed1.length-4, 4)];
    UserDetail.attributedText = attributed1;
    [self.view addSubview:UserDetail];
    [UserDetail sizeToFit];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"agree_regist"]];
    imageView.frame = CGRectMake(UserDetail.x-kWvertical(22), ScreenHeight - kHvertical(32), kWvertical(17), kWvertical(17));
    [self.view addSubview:imageView];
    
    
    
    UIButton *Detail = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - kWvertical(170))/2, UserDetail.y, kWvertical(170), kHvertical(18))];
    [Detail addTarget:self action:@selector(userDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Detail];

}
-(void)alertShowView:(NSString *)str{
    
    SucessView *sView = [[SucessView alloc] initWithFrame:CGRectMake(WScale(37.1), HScale(44.7), WScale(26.1), HScale(10.8)) imageImageName: @"失败" descStr: str];
    [self.view addSubview:sView];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [sView removeFromSuperview];
    });
    
}
#pragma mark ---- 点击事件
-(void)ClickCode{
    self.codeBtn.enabled = NO;
    __weak typeof(self) weakself = self;
    NSDictionary *dict = @{
                           @"phone":_phoneNum
                           };
    [self.loadData downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=getcode",apiHeader120] parameters:dict complicate:^(BOOL success, id data) {

        if (success) {
            NSString *code = data[@"code"];
            [weakself.codeText becomeFirstResponder];
            if ([code isEqualToString:@"1"]) {
                [weakself alertShowView:@"发送失败"];
                _codeBtn.enabled = YES;
            }
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMeyhod) userInfo:nil repeats:YES];
            
            
        }else{
            [self alertShowView:@"发送失败"];
            _codeBtn.enabled = YES;
        }

    }];
}
-(void)clickNextStep{
    
    NSDictionary *dict = @{
                           @"phone":self.phoneNum,
                           @"code":self.codeText.text
                           };
    
    __weak typeof(self) weakself = self;
    [self.loadData downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=reglogin",apiHeader120] parameters:dict complicate:^(BOOL success, id data) {
        
        if (success) {
            NSString *code = data[@"code"];
            NSString *regstage = data[@"regstage"];
            weakself.name_id = data[@"name_id"];
            NSString *uid = data[@"uid"];
            if ([code isEqualToString:@"2"]) {
                
                [weakself alertShowView:@"添加用户失败"];
                
            }else if ([code isEqualToString:@"1"]){
                
                [weakself alertShowView:@"验证码错误"];
                
            }else if ([code isEqualToString:@"0"]){
                
                if ([regstage isEqualToString:@"5"]) {
                    
                    [userDefaults setObject:_name_id forKey:@"name_id"];
                    [userDefaults setObject:uid forKey:@"uid"];
                    [userDefaults setValue:_phoneNum forKey:@"phone"];
                    [weakself initData];
                    TabBarViewController *tbc = [[TabBarViewController alloc] init];
                    weakself.view.window.rootViewController = tbc;
                }
            }
        }
    }];
}


-(void)initData{
    
    DownLoadDataSource *loadData = [[DownLoadDataSource alloc] init];
    
    NSDictionary *parameters = @{@"name_id":_name_id};
    
    [loadData downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=getui",apiHeader120] parameters:parameters complicate:^(BOOL success, id data) {
        if (success) {
            
            NSDictionary *uiDic = data[@"ui"];
            
            DetailHeaderModel *headerModel = [DetailHeaderModel initWithDictionary:uiDic];
            
            NSMutableArray *labelArr = uiDic[@"labels"];
            if (labelArr.count>0) {
                
                [userDefaults setValue:labelArr forKey:@"labels"];
                
            }
            
            if ([headerModel.vid isEqualToString:@"0"]) {
                
            }else{
                
            }
            [userDefaults setValue:headerModel.sign forKey:@"siignature"];
            [userDefaults setValue:headerModel.visits forKey:@"access_amount"];
            [userDefaults setValue:headerModel.completegames forKey:@"changCi"];
            [userDefaults setValue:headerModel.charity forKey:@"cishan_jiner"];
            [userDefaults setValue:headerModel.city forKey:@"city"];
            [userDefaults setValue:headerModel.state forKey:@"examine_state"];
            [userDefaults setValue:headerModel.befocus forKey:@"follow_number"];        //关注
            [userDefaults setValue:headerModel.focus forKey:@"attention_number"];       //粉丝
            [userDefaults setValue:headerModel.gender forKey:@"gender"];
            [userDefaults setValue:headerModel.vid forKey:@"interview_state"];
            [userDefaults setValue:headerModel.msgs forKey:@"message_number"];
            [userDefaults setValue:headerModel.nickname forKey:@"nickname"];
            [userDefaults setValue:headerModel.avatorpid forKey:@"pic_id"];
            [userDefaults setValue:headerModel.province forKey:@"province"];
            [userDefaults setValue:headerModel.year_label forKey:@"age"];
            [userDefaults setValue:headerModel.avator forKey:@"pic"];
            [userDefaults setValue:headerModel.cover forKey:@"coverPic"];
            [userDefaults setValue:headerModel.rodnum forKey:@"polenum"];
            [userDefaults setValue:headerModel.work_content forKey:@"job"];
            [userDefaults setValue:headerModel.bird forKey:@"zhuaNiao"];
            [userDefaults setValue:headerModel.uid forKey:@"uid"];
            
            
        }
    }];
}

//获取验证码
- (void)timeFireMeyhod{
    _timeCount--;
    [_codeBtn setTitle:[NSString stringWithFormat:@"%ldS 后重试",(long)_timeCount] forState:UIControlStateNormal];
    [_codeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    if (_timeCount == 0) {
        _codeBtn.enabled = YES;
        [_timer invalidate];
        [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_codeBtn setTitleColor:localColor forState:UIControlStateNormal];
        
        _codeBtn.enabled = YES;
        _timeCount = 60;
        
    }
    
}

-(void)clickChangeBtn{
    RegistViewController *VC = [[RegistViewController alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [userDefaults setValue:@"0" forKey:@"name_id"];
    [self.navigationController pushViewController:VC animated:YES];
}

// 用户协议跳转
-(void)userDetail:(id)sender{
    UserDetailViewController *uvc = [[UserDetailViewController alloc] init];
    uvc.urlStr = [NSString stringWithFormat:@"%@Golvon/jsp/FuWuXieYI.jsp",urlHeader120];
    uvc.loginStyle = @"1";
    uvc.isShare = @"1";
    uvc.titleStr = @"用户协议";
    [self presentViewController:uvc animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
