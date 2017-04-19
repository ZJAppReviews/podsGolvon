//
//  NewZhuanFangViewController.m
//  Golvon
//
//  Created by shiyingdong on 16/4/20.
//  Copyright © 2016年 李盼盼. All rights reserved.
//

#import "NewZhuanFangViewController.h"
#import "Header.h"
#import "DownLoadDataSource.h"
#import "DetailComment.h"
#import "ImageModel.h"
#import "CommentModel.h"
//#import "LPPeriscommentView.h"
#import "WXApi.h"
#import "ViewTableViewCell.h"
#import "WebTableViewCell.h"
#import "ImageTableViewCell.h"
#import "NewDetailViewController.h"
#import "AidViewController.h"

static NSString *view = @"ViewTableViewCell";
static NSString *image = @"ImageTableViewCell";
static NSString *web = @"WebTableViewCell";
static NSString *comment = @"DetailComment";

static CGFloat webViewHeight = 80; ///< webView高度变量, 默认高度设为80(根据UI设定原始高度)

@interface NewZhuanFangViewController ()<UITableViewDataSource,UITableViewDelegate,WebViewCellDelegate,UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate>{
    
    UITextView *_mainTextView;
    CGFloat _lastOffY; ///< tableView滑动时最后的偏移量, 用于判断tableView的滑动方向
    
    UIImageView *_commemtView;//评论图标
    UILabel *_commentLabel;///评论文字
    
    BOOL _readBtnType;//是否点击阅读按钮
    UIButton *_readBtn;
    UIButton *_ZanBtn;
    UIImageView *_ZanView;
    
    NSString *kLinkURL;
    NSString *kLinkTitle;
    NSString *kLinkDescription;
    NSString *kImage;
    
    
    NSString *_followState;
    UIButton *_gzBtn;
    
    NSInteger _maStyle;
    
    NSString *_readNum;
    NSInteger _keybordHeight;
    
    UIView *_backGround2;
    UIView *_view;
    UIButton *_cancer;
}



@property (nonatomic, copy)UITableView *mainTableView;

@property (strong, nonatomic)DownLoadDataSource *downLoad;
@property (strong, nonatomic)NSMutableArray *viewData;
@property (strong, nonatomic)NSMutableArray *imageData;
@property (strong, nonatomic)NSMutableArray *webData;
@property (strong, nonatomic)NSMutableArray *commentData;
@property (strong, nonatomic)UIScrollView *backGround;
@property (strong, nonatomic)UIView *zhuanZanView;
@property (strong, nonatomic)UIButton *zhuanZanBtn;
@property (strong, nonatomic)UILabel *zhuanZanLabel;
@property (assign, nonatomic)int curragePage;
@property (strong, nonatomic)UIView *commanBackView;
@property (strong, nonatomic)UILabel *commentPlaceLabel;
@end

@implementation NewZhuanFangViewController

-(DownLoadDataSource *)downLoad{
    if (!_downLoad) {
        _downLoad = [[DownLoadDataSource alloc]init];
    }
    return _downLoad;
}
-(NSMutableArray *)viewData{
    if (!_viewData) {
        _viewData = [[NSMutableArray alloc]init];
    }
    return _viewData;
}
-(NSMutableArray *)imageData{
    if (!_imageData) {
        _imageData = [[NSMutableArray alloc]init];
    }
    return _imageData;
}
-(NSMutableArray *)webData{
    if (!_webData) {
        _webData = [[NSMutableArray alloc]init];
    }
    return _webData;
}
-(NSMutableArray *)commentData{
    if (!_commentData) {
        _commentData = [[NSMutableArray alloc]init];
    }
    return _commentData;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    _block(YES);
}

- (void)viewDidLoad {
    _maStyle = 0;
    _curragePage = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
    [self.view addSubview:_backGround];
    [self createNav];
    [self createUI];
    [self loadImageData];
    [self loadViewData];
    [self BoolRead];
    [self loadCommentData];
    [self selectFollow];
    [super viewDidLoad];
    [self loadShareData];
    [self ReseavNotification];
}
-(void)scrollToreaplayIndex{
    
    if (_followSelectNameId) {
        NSInteger index = 0;
        if (_commentData.count>0) {
        for (NSInteger i = 0; i<_commentData.count; i++) {
            CommentModel *model = _commentData[i];
            if ([model.name_id isEqualToString:_followSelectNameId]) {
                index = i;
            }
        }
    }
    }
}

-(void)createUI{
    
    
    _commanBackView = [[UIView alloc] init];
    _commanBackView.frame = CGRectMake(0, HScale(93.4), ScreenWidth, HScale(6.6));
    [self.view addSubview:_commanBackView];
    
    _mainTextView = [[UITextView alloc]init];
    _mainTextView.frame = CGRectMake(0, HScale(1.1), WScale(96.3), HScale(4.5));
    _mainTextView.font = [UIFont boldSystemFontOfSize:kHorizontal(14)];
    
    _mainTextView.backgroundColor = [UIColor whiteColor];
    _mainTextView.delegate = self;
    
    [_commanBackView addSubview:_mainTextView];
    
    
    _commentPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(WScale(1.2), HScale(0.9), WScale(30), HScale(2.7))];
    _commentPlaceLabel.text = @"发表评论";

    _commentPlaceLabel.font = [UIFont systemFontOfSize:13.f];
    _commentPlaceLabel.textColor = [UIColor lightGrayColor];
    
    [_mainTextView addSubview:_commentPlaceLabel];
    
    _commentPlaceLabel.hidden = YES;
    
    
    _commemtView = [[UIImageView alloc] initWithFrame:CGRectMake(WScale(43.7), HScale(1.9), WScale(4), HScale(2.4))];
    _commemtView.image = [UIImage imageNamed:@"CommentImage"];
    
    _commentLabel= [[UILabel alloc] initWithFrame:CGRectMake(WScale(49.1), HScale(1.9), WScale(12), HScale(3))];
    _commentLabel.text = @"评论";
    _commentLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
    _commentLabel.textColor = [UIColor colorWithRed:52/255 green:186/255 blue:182/255 alpha:1.0f];
    [_commanBackView addSubview:_commemtView];
    [_commanBackView addSubview:_commentLabel];
//    _mainTextView.userInteractionEnabled = NO; // webView未加载完成不可点击评论
    _mainTextView.returnKeyType = UIReturnKeySend;

}

#pragma mark - 滑动tableView隐藏键盘

-(void)scrollViewDidScroll:(UITableView *)tableview{
    
    if (tableview == _mainTableView) {
    [_mainTextView resignFirstResponder];
    }
}

-(void)hideKeyboards{
    
    [_mainTextView resignFirstResponder];
}


#pragma mark - 判断是否已经阅读
-(void)BoolRead{
    NSDictionary *dict = @{
                           @"interview_id":_interviewId,
                           @"name_id":userDefaultId
                           };
    DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
    [manager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_interview_clike",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
        if (success) {
            NSArray *dataArr = [data objectForKey:@"data"];
            NSDictionary *dataDic = dataArr[0];
            NSLog(@"%@",dataDic);
            
            NSString *str = [dataDic objectForKey:@"clike_state"];
            _readNum = [dataDic objectForKey:@"like_number"];
            if ([str isEqualToString:@"0"]) {
                _readBtnType = NO;
                [_readBtn setImage:[UIImage imageNamed:@"阅读"] forState:UIControlStateNormal];
            }else{
                _readBtnType = YES;
                [_readBtn setImage:[UIImage imageNamed:@"阅读－点击"] forState:UIControlStateNormal];
            }
        }
        [_mainTableView reloadData];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 创建顶部Navi
-(void)createNav{
    
    self.navigationItem.title = @"达人专访";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:kHorizontal(18)],NSForegroundColorAttributeName:deepColor}];

    UIBarButtonItem *leftBarbutton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(pressesBack)];
    leftBarbutton.tintColor = [UIColor blackColor];
    [leftBarbutton setImage:[UIImage imageNamed:@"返回"]];
    self.navigationItem.leftBarButtonItem = leftBarbutton;


    UIBarButtonItem *RightBarbutton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(clickToShare)];
    RightBarbutton .tintColor = [UIColor blackColor];
    [RightBarbutton setImage:[UIImage imageNamed:@"Share"]];
    if ([WXApi isWXAppInstalled]) {
        
        self.navigationItem.rightBarButtonItem = RightBarbutton;

    }
    
    
    
//    _navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
//    _navView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:_navView];
//    
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, ScreenWidth, 15)];
//    titleLabel.text = @"达人专访";
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    
//    if (self.view.frame.size.height <= 568)
//    {
//        titleLabel.font = [UIFont boldSystemFontOfSize:kHorizontal(20)];
//        
//    }
//    else if (self.view.frame.size.height > 568 && self.view.frame.size.height <= 667)
//    {
//        
//        titleLabel.font = [UIFont boldSystemFontOfSize:kHorizontal(18)];
//        
//    }else{
//        
//        titleLabel.font = [UIFont boldSystemFontOfSize:kHorizontal(17)];
//        
//    }
//    [_navView addSubview:titleLabel];
//    
//    
//    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _backBtn.frame = CGRectMake(0, 20, 44, 44);
//    
//    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(9, 13, 19, 19)];
//    backImage.image = [UIImage imageNamed:@"返回"];
//    [_backBtn addSubview:backImage];
//    
//
//    [_backBtn addTarget:self action:@selector(pressesBack) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_backBtn];
//    
//
//    
//    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, ScreenWidth, 0.5)];
//    line.backgroundColor = NAVLINECOLOR;
//    [_navView addSubview:line];
}


-(void)loadShareData{
    
    DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
    
    NSDictionary *dict = @{
                           @"interview_id":_interviewId
                           };
    [manager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_share_user",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
        if (success) {
            NSArray *dataArry = data[@"data"];
            if (dataArry.count>0) {
                NSDictionary *dataDic = dataArry[0];
                kLinkURL = [dataDic objectForKey:@"share_url"];
                kLinkTitle = [dataDic objectForKey:@"interview_title"];
                kLinkDescription = [dataDic objectForKey:@"share_describe"];
                kImage = [dataDic objectForKey:@"share_picture_url"];
            }else{
                _share.hidden = YES;
            }
            
        }
        
    }];
    
}

#pragma mark ---- 推荐给朋友
-(void)clickToShare{
    _backGround2 = [[UIView alloc]init];
    _backGround2.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _backGround2.backgroundColor = [UIColor blackColor];
    _backGround2.alpha = 0.5;
    _backGround2.hidden = NO;
    _backGround2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToCancer)];
    [_backGround2 addGestureRecognizer:tap];
    [self.view addSubview:_backGround2];
    
    
    _view = [[UIView alloc]init];
    _view.frame = CGRectMake(WScale(15.5), HScale(32), ScreenWidth * 0.691, ScreenHeight *0.298);
    _view.layer.cornerRadius = 8;
    _view.tag = 101;
    _view.hidden = NO;
    _view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_view];
    
    UIButton *haoYou = [UIButton buttonWithType:UIButtonTypeCustom];
    [haoYou setBackgroundImage:[UIImage imageNamed:@"推荐给微信好友"] forState: UIControlStateNormal];
    [haoYou addTarget:self action:@selector(clickToHaoYou) forControlEvents:UIControlEventTouchUpInside];
    haoYou.frame = CGRectMake(WScale(10.8), HScale(6.3), ScreenWidth * 0.181, ScreenHeight * 0.102);
    [_view addSubview:haoYou];
    UILabel *haoyouLabel = [[UILabel alloc]initWithFrame:CGRectMake(WScale(13.6), HScale(17.4), WScale(16), HScale(2.5))];
    haoyouLabel.text = @"微信好友";
    haoyouLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
    haoyouLabel.textColor = deepColor;
    [_view addSubview:haoyouLabel];
    
    UIButton *pengYouQuan = [UIButton buttonWithType:UIButtonTypeCustom];
    [pengYouQuan setBackgroundImage:[UIImage imageNamed:@"推荐到微信朋友圈"] forState: UIControlStateNormal];
    [pengYouQuan addTarget:self action:@selector(clickToPengYouQuan) forControlEvents:UIControlEventTouchUpInside];
    pengYouQuan.frame = CGRectMake(WScale(40.3), HScale(6.3), ScreenWidth * 0.181, ScreenHeight * 0.102);
    [_view addSubview:pengYouQuan];
    UILabel *pengyouLabel = [[UILabel alloc]initWithFrame:CGRectMake(WScale(41.3), HScale(17.4), WScale(18), HScale(2.5))];
    pengyouLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
    pengyouLabel.text = @"微信朋友圈";
    pengyouLabel.textColor = deepColor;
    [_view addSubview:pengyouLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, HScale(23.4), ScreenWidth * 0.691, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view addSubview:line];
    
    _cancer = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancer.tag = 102;
    _cancer.hidden = NO;
    [_cancer setTitle:@"取消" forState:UIControlStateNormal];
    _cancer.frame = CGRectMake(WScale(15.5), HScale(55.4)+1, WScale(69.1), ScreenHeight *0.064);
    [_cancer setTitleColor:localColor forState:UIControlStateNormal];
    [_cancer addTarget:self action:@selector(clickToCancer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancer];
    
    
}
-(void)clickToCancer{
    _backGround2.hidden = YES;
    _view.hidden = YES;
    _cancer.hidden = YES;
}

-(void)clickToHaoYou{
    [self clickToCancer];
    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = 0;//0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = kLinkTitle;//分享标题
    urlMessage.description = kLinkDescription;//分享描述
    urlMessage.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]];
    //    urlMessage.
    
    
    //    [urlMessage setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]]]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    //    [urlMessage setThumbData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]]];
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}
-(void)clickToPengYouQuan{
    [self clickToCancer];

    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = 1;//0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = kLinkTitle;//分享标题
    urlMessage.description = kLinkDescription;//分享描述
    urlMessage.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]];
    //    urlMessage.
    
    
    //    [urlMessage setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]]]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    //    [urlMessage setThumbData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kImage]]];
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

#pragma mark - pop返回
-(void)pressesBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---- 请求数据
-(void)loadViewData{
    __weak typeof(self) weakself = self;
    NSDictionary *dict = @{
                           @"name_id":_interviewerId,
                           @"inter_name_id":userDefaultId,
                           @"interview_id":_interviewId
                           };
    [self.downLoad downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_user_inter_id",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
        if (success) {
            
            NSArray *arr = data[@"data"];
            ViewModel *model = [[ViewModel alloc]init];
            model.state = arr[0][@"code"];
            model.timeLabel = arr[1][@"interview_title"];
            model.nickName = arr[2][@"nickname"];
            model.headerImage = arr[2][@"picture_url"];
            [weakself.viewData addObject:model];
            [weakself.mainTableView reloadData];
        }
    }];
}
#pragma mark - 专访图片
-(void)loadImageData{
    __weak typeof(self) weakself = self;
    NSDictionary *dict = @{
                           @"interview_id":_interviewId
                           };
    [self.downLoad downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_interview",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
        if (success) {
            NSArray *arr = data[@"data"];
            ImageModel *model = [[ImageModel alloc]init];
            model.imageurl = arr[0][@"picture_url"];
            model.viewCount = arr[0][@"red_number"];
            model.interViewUrl = arr[0][@"interview_url"];
            [weakself.imageData addObject:model];
            [weakself.mainTableView reloadData];

        }
    }];
}




#pragma mark - 获取评论,
-(void)loadCommentData{
    __weak typeof(self) weakself = self;
    NSDictionary *dic = @{@"interview_id":self.interviewId,
                          @"statr_number":@(_curragePage),
                          @"user_id":userDefaultId
                          };
    [self.downLoad downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_comment_interid",urlHeader120] parameters:dic complicate:^(BOOL success, id data) {
        if (success) {
            self.commentData = [NSMutableArray array];
            NSDictionary *dic = data;
            NSArray *codeArr = dic[@"data"];
            if (codeArr.count > 0) {
                NSDictionary *codeDic = codeArr[0];
            if ([[codeDic objectForKey:@"code"] isEqualToString:@"0"]) {
                return;
            }
            }
            for (NSDictionary *temp in dic[@"data"]) {
                CommentModel *model = [CommentModel pareWithDictionary:temp];
                [weakself.commentData addObject:model];
            }
            
            
            [weakself.mainTableView reloadData];
            
            [weakself scrollToreaplayIndex];

        }
    }];
}

#pragma mark - 提交评论,添加回复
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    __weak typeof(self) weakself = self;
    if ([text isEqualToString:@"\n"]) {
        NSString *commentDesc = [NSMutableString stringWithFormat:@"%@",textView.text];
        NSMutableString *commentTest = [NSMutableString stringWithString:commentDesc];
        NSString *str2 = [commentTest stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (str2.length<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提交内容不能为空" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"重新提交" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
        }else{
            if ([_commentPlaceLabel.text isEqualToString:@"发表评论"]) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                [[self mainTableView] scrollToRowAtIndexPath:scrollIndexPath
                                            atScrollPosition:UITableViewScrollPositionTop animated:YES];
                NSLog(@"%@%@",[userDefaults objectForKey:@"nickname"],[userDefaults objectForKey:@"name_id"]);
                
                NSDictionary *dict = @{
                                       @"comment_content":commentDesc,
                                       @"comment_name":[userDefaults objectForKey:@"nickname"],
                                       @"interview_id":_interviewId,
                                       @"covercomment_name":_interviewerName,
                                       @"covercomment_id":_interviewerId,
                                       @"comment_nameid":[userDefaults objectForKey:@"name_id"],
                                       };
                [_mainTextView resignFirstResponder];
                DownLoadDataSource *dataManager = [[DownLoadDataSource alloc] init];
                [dataManager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/insert_comment",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
                    if (success) {
                        
                        _mainTextView.text = @"";
                        NSString *code = data[@"data"][0][@"code"];
                        if ([code isEqualToString:@"1"]) {
                            
                            [weakself loadCommentData];

                        }else{
                            
                            SucessView *sView = [[SucessView alloc] initWithFrame:CGRectMake(WScale(37.1), HScale(44.7), WScale(26.1), HScale(10.8)) imageImageName: @"失败" descStr: @"操作失败"];
                            [weakself.view addSubview:sView];
                            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                            
                            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                sView.hidden = YES;
                            });
                        }
                    }
                }];
            }else{
                
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                [[self mainTableView] scrollToRowAtIndexPath:scrollIndexPath
                                            atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                NSDictionary *dict = @{
                                       @"comment_content":commentDesc,
                                       @"comment_name":[userDefaults objectForKey:@"nickname"],
                                       @"interview_id":_interviewId,
                                       @"covercomment_name":_reaplyName,
                                       @"covercomment_id":_reaplyNameId,
                                       @"comment_nameid":userDefaultId,
                                       };
                [_mainTextView resignFirstResponder];
                DownLoadDataSource *dataManager = [[DownLoadDataSource alloc] init];
                [dataManager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/insert_reply_comment",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
                    if (success) {
                        _mainTextView.text = @"";
                        NSString *code = data[@"data"][0][@"code"];
                        if ([code isEqualToString:@"1"]) {
                            
                            [weakself loadCommentData];
                            
                        }else{
                            
                            SucessView *sView = [[SucessView alloc] initWithFrame:CGRectMake(WScale(37.1), HScale(44.7), WScale(26.1), HScale(10.8)) imageImageName: @"失败" descStr: @"操作失败"];
                            [weakself.view addSubview:sView];
                            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                            
                            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                sView.hidden = YES;
                            });
                        }
                    }
                }];
                
            }
            
        }
        return NO;
    }
    return YES;
}


- (void)creatAlert:(NSTimer *)timer{
    [UIView animateWithDuration:3 animations:^{
        UIAlertController *alert = [timer userInfo];
        [alert dismissViewControllerAnimated:YES completion:nil];
        alert = nil;
    
    }];

}
-(void)textViewDidChange:(UITextView *)textView{

    NSString *textStr = textView.text;
    NSLog(@"%@",textStr);
    if (textView.text.length == 0) {
        _commentPlaceLabel.hidden = NO;
    }else{
        _commentPlaceLabel.hidden = YES;
    }
    
    if (textView.contentSize.height>HScale(3.9)) {
        if (textView.contentSize.height>HScale(8.7)) {
            _commanBackView.frame = CGRectMake(0, HScale(89.2) - _keybordHeight , ScreenWidth, HScale(10.8));

            _mainTextView.frame = CGRectMake(WScale(1.9), HScale(1.1) , WScale(96.3),HScale(8.7));
        }else{
            _commanBackView.frame = CGRectMake(0, HScale(97.9) - _keybordHeight - textView.contentSize.height, ScreenWidth,  textView.contentSize.height+HScale(2.1));
            _mainTextView.frame = CGRectMake(WScale(1.9), HScale(1.1), WScale(96.3), textView.contentSize.height);


        }
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    textView.text = @"";

}


#pragma mark - 接收键盘通知

-(void)ReseavNotification{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

/**
 *  接收弹出键盘通知
 *
 *  @param notice
 */
- (void)showKeyboard:(NSNotification *)notice
{
    // 消息的信息
    NSDictionary *dic = notice.userInfo;
    CGSize kbSize = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    
    if (_mainTextView.text.length == 0) {
        _commentPlaceLabel.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        
        _commemtView.hidden = YES;
        _commentLabel.hidden = YES;
        _keybordHeight = kbSize.height;
        _commanBackView.frame = CGRectMake(0, HScale(93.4)  - kbSize.height, ScreenWidth, HScale(6.6));
        _commanBackView.backgroundColor = GPColor(249, 250, 251);
        _mainTextView.layer.borderColor = GPColor(227, 228, 229).CGColor;
        
        
        _commanBackView.layer.borderWidth = 1;
        _commanBackView.layer.cornerRadius = 0;
        
        _commanBackView.layer.masksToBounds = YES;
        
        
        _commanBackView.backgroundColor = [UIColor whiteColor];
        _commanBackView.layer.borderColor = GPColor(227, 228, 229).CGColor;
        
        
        
        _mainTextView.layer.borderWidth = 1;
        _mainTextView.layer.cornerRadius = 3;

        _mainTextView.layer.masksToBounds = YES;

        _mainTextView.frame = CGRectMake(WScale(1.9), HScale(1.1), WScale(96.3), HScale(4.5));
    }];
    
}
/**
 *  接收隐藏键盘的通知
 *
 *  @param notice <#notice description#>
 */

- (void)hideKeyboard:(NSNotification *)notice
{
    [UIView animateWithDuration:0.5 animations:^{
        [_mainTextView resignFirstResponder];
        _commemtView.hidden = NO;
        _commentLabel.hidden = NO;
        _commentPlaceLabel.hidden = YES;
        
        _commanBackView.frame = CGRectMake(0, HScale(94), ScreenWidth, HScale(6));
        _mainTextView.layer.borderWidth = 0;
        _mainTextView.text = @"";
        _commentPlaceLabel.text = @"发表评论";
    }];
    
}


#pragma mark - 阅读按钮点击
-(void)ReadBtnClike{
    _readBtn.userInteractionEnabled = NO;
    NSDictionary *dict = @{
                           @"interview_id":_interviewId,
                           @"name_id":userDefaultId,
                           @"Jpush_nameid":_interviewerId
                           };
    __weak typeof(self) weakself = self;
    
    if (_readBtnType == NO) {
        DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
        
        [manager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/insert_interview_clike",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
            _readBtn.userInteractionEnabled = YES;
            if (success) {
                _readBtnType = YES;
                [_readBtn setImage:[UIImage imageNamed:@"阅读－点击"] forState:UIControlStateNormal];
                [weakself BoolRead];
            }
            [weakself.mainTableView reloadData];

        }];
        
        
    }else{

        DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
        
        [manager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/delete_interview_like",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
            _readBtn.userInteractionEnabled = YES;

            if (success) {
                _readBtnType = NO;
                [_readBtn setImage:[UIImage imageNamed:@"阅读"] forState:UIControlStateNormal];
                [weakself BoolRead];

            }
        }];
        
    }
    
}



#pragma mark - 创建tableView
-(void)createTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-HScale(6))];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboards)];
    [tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    _mainTableView = tableView;
    


    [_mainTableView registerClass:[ViewTableViewCell class] forCellReuseIdentifier:view];
    [_mainTableView registerClass:[ImageTableViewCell class] forCellReuseIdentifier:image];
    [_mainTableView registerClass:[WebTableViewCell class] forCellReuseIdentifier:web];
    [_mainTableView registerClass:[DetailComment class] forCellReuseIdentifier:comment];
    
    [self.view addSubview:tableView];
    _mainTableView.alpha = 0;
    _mainTableView.hidden = YES;
    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.1f];
}


-(void)delayMethod{
    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self performSelector:@selector(delayMethod1) withObject:nil afterDelay:0.3f];


}

-(void)delayMethod1{
    _mainTableView.alpha = 1;
    _mainTableView.hidden = NO;
}

#pragma mark - tableView代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if(section == 1){
    return 3;
    }else if(section == 2){
        return _commentData.count;
    }else{
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return ScreenHeight * 0.765;
        }else if (indexPath.row == 1){
            return webViewHeight-2;
        }else{
            
            CGSize TitleSize= [_commentLabel.text boundingRectWithSize:CGSizeMake(WScale(78.4), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kHorizontal(13)]} context:nil].size;
            if (TitleSize.height + HScale(2.4)<HScale(17.1)) {
                return HScale(17.1);
            }
            return TitleSize.height + HScale(2.4);
        }
    }else if(indexPath.section == 2){
        CommentModel *model = _commentData[indexPath.row];
        if ([model.reply_comment_sta isEqualToString:@"0"]) {
            
            CGSize TitleSize= [model.comment boundingRectWithSize:CGSizeMake(WScale(75), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kHorizontal(13)]} context:nil].size;
            return HScale(11) + TitleSize.height;
        }else{
            
            _commentLabel.font = [UIFont systemFontOfSize:kHorizontal(13)];
            NSString *contenText = [NSString stringWithFormat:@"回复  %@ : %@",model.reply_name,model.comment];
            CGSize TitleSize= [contenText boundingRectWithSize:CGSizeMake(WScale(96.7)-WScale(16.6), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kHorizontal(13)]} context:nil].size;

            
            return HScale(11) + TitleSize.height;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return ScreenHeight * 0.085;
    }else{
        return 0;
    }

}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HScale(8.5))];
        
        UIImageView *headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(WScale(2.9), HScale(1.3), ScreenWidth * 0.107, ScreenHeight * 0.06)];
        [backView addSubview:headerImage];
        
        UILabel *nickName = [[UILabel alloc]initWithFrame:CGRectMake(WScale(17.9), HScale(1.5), ScreenWidth * 0.323, ScreenHeight * 0.03)];
        [backView addSubview:nickName];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(WScale(17.9), HScale(4.8), ScreenWidth * 0.500, ScreenHeight * 0.025)];
        [backView addSubview:timeLabel];
        
        
        UIButton *skipDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        skipDetail.frame = CGRectMake(0, 0, WScale(70), HScale(8.5));
        [skipDetail addTarget:self action:@selector(clickToSkipDetail) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:skipDetail];
        
        _gzBtn = [[UIButton alloc]initWithFrame:CGRectMake(WScale(72.8), HScale(1.9), ScreenWidth * 0.24, ScreenHeight * 0.048)];
        [_gzBtn addTarget:self action:@selector(addFollow:) forControlEvents:UIControlEventTouchUpInside];
        [_gzBtn setImage:[UIImage imageNamed:@"addFollow(intview)"] forState:UIControlStateNormal];
        [_gzBtn setImage:[UIImage imageNamed:@"alreadyFollow(intview)"] forState:UIControlStateSelected];

        if ([_interviewerId isEqualToString:userDefaultId]) {
            _gzBtn.hidden = YES;
        }else{
            _gzBtn.hidden = NO;
        }

        [backView addSubview:_gzBtn];
        
        ViewModel *model = _viewData[0];
        
        [headerImage sd_setImageWithURL:[NSURL URLWithString:model.headerImage] placeholderImage:[UIImage imageNamed:@"动态等待图"]];
        if (model.nickName) {
            nickName.text = [NSString stringWithFormat:@"%@",model.nickName];
        }

        nickName.font = [UIFont systemFontOfSize:kHorizontal(14)];
        if (model.timeLabel) {
        timeLabel.text = [NSString stringWithFormat:@"%@",model.timeLabel];
        }

        timeLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
        [self downGuanzhuData];
        return backView;
    }else{
        return nil;
    }

}
#pragma mark ---- 跳转个人详情
-(void)clickToSkipDetail{
    NewDetailViewController *vc = [[NewDetailViewController alloc]init];
    vc.nameID = _interviewerId;
    [vc setBlock:^(BOOL isback) {
        
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark —— 获取关注状态
-(void)downGuanzhuData{
    NSDictionary *dic = @{@"follow_name_id":userDefaultId,
                          @"cov_follow_nameid":self.interviewerId};
    
    [self.downLoad downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_follow_nameid",urlHeader120] parameters:dic complicate:^(BOOL success, id data) {
        if (success) {
            _followState = data[@"data"][0][@"code"];
            _gzBtn.selected = [_followState intValue] == 0 ? NO : YES;
        }
    }];
}

#pragma mark —— 添加关注

-(void)addFollow:(UIButton*)button{
    
    /**
     *  follow_name 关注人
     cofollow_name 被关注的人
     */
    NSDictionary *insterParamters = @{@"follow_name_id":userDefaultId,
                                      @"cof_name_id":self.interviewerId};
    NSDictionary *deleteParamters = @{@"follow_user_id":userDefaultId,
                                      @"name_id":self.interviewerId};
    NSString *insertUrlStr = [NSString stringWithFormat:@"%@Golvon/insert_follow",urlHeader120];
    NSString *deleteUrlStr = [NSString stringWithFormat:@"%@Golvon/delete_follow",urlHeader120];
    
    if ([_followState isEqualToString:@"0"]) {
        
        [self.downLoad downloadWithUrl:insertUrlStr parameters:insterParamters complicate:^(BOOL success, id data) {
            if (success) {
                button.selected = YES;
                _followState = @"1";
            }
        }];
    }else{
        [self.downLoad downloadWithUrl:deleteUrlStr parameters:deleteParamters complicate:^(BOOL success, id data) {
            if (success) {
                button.selected = NO;
                _followState = @"0";
            }
        }];
    }
}


-(void)selectFollow{
    
    NSDictionary *paramters = @{@"follow_name_id":userDefaultId,
                                @"cov_follow_nameid":self.interviewerId};
    [self.downLoad downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/select_follow_nameid",urlHeader120] parameters:paramters complicate:^(BOOL success, id data) {
        if (success) {
            _followState = data[@"data"][0][@"code"];
            
            if ([_followState isEqualToString:@"0"]) {
                _gzBtn.selected = NO;
            }else{
                _gzBtn.selected = YES;
            }
        }
    }];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ImageTableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:image];
            [imageCell relayOutWithDictionary:_imageData[indexPath.row]];
            
//            if (_commentData) {
//                if (_maStyle == 0) {
////                    [imageCell relaycommentDataDict:_commentData];
////                    _maStyle++;
//                }
//            }
            imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return imageCell;
            
        }else if(indexPath.row == 1){
            WebTableViewCell *webCell = [tableView dequeueReusableCellWithIdentifier:web];
            webCell.delegate = self;
//                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            webCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return webCell;
        }else{
            ViewTableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:view];
            viewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            viewCell.ReadNum.text = _readNum;
            if (_readBtn) {
                return viewCell;
            }
            _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _readBtn.frame = CGRectMake(WScale(44), HScale(2.5), ScreenWidth * 0.12, ScreenHeight * 0.067);
            [_readBtn setBackgroundColor:[UIColor clearColor]];
            if (!_readBtnType) {
                [_readBtn setImage:[UIImage imageNamed:@"阅读"] forState:UIControlStateNormal];
            }else{
                [_readBtn setImage:[UIImage imageNamed:@"阅读－点击"] forState:UIControlStateNormal];
                
            }

            [_readBtn addTarget:self action:@selector(ReadBtnClike) forControlEvents:UIControlEventTouchUpInside];
            [viewCell addSubview:_readBtn];

            
            return viewCell;
        }
    }else if(indexPath.section == 2){

        DetailComment *cell = [tableView dequeueReusableCellWithIdentifier:comment];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell realoadDataWith:_commentData[indexPath.row]];
        _ZanBtn = cell.zanBtn;
        
        _ZanBtn.tag = 100*indexPath.row;
        [_ZanBtn addTarget:self action:@selector(DianZan:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.headerImage addTarget:self action:@selector(clickToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [cell.nickName addTarget:self action:@selector(clickToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [cell.button addTarget:self action:@selector(clickToDetail1:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.headerImage.tag = 101*indexPath.row;
        cell.nickName.tag = 101*indexPath.row;
        cell.button.tag = 102*indexPath.row;
        
        _ZanView = cell.zanview;
        _ZanView.tag =1 + 100*indexPath.row;
        return cell;
        
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_mainTextView resignFirstResponder];
}

#pragma mark ---- 跳转
-(void)clickToDetail:(UIButton *)sender{

    NSInteger tag1 = sender.tag/101;
    CommentModel *model = _commentData[tag1];
    
    NewDetailViewController *vc = [[NewDetailViewController alloc] init];
    AidViewController *aid = [[AidViewController alloc]init];
    if ([model.name_id isEqualToString:@"usergolvon"]) {
        [aid setBlock:^(BOOL isView) {
            
        }];
        [self.navigationController pushViewController:aid animated:YES];
    }else if ([model.name_id isEqualToString:userDefaultId]){
        
        vc.nameID = model.name_id;
        [vc setBlock:^(BOOL isback) {
            
        }];
        [self.navigationController pushViewController:vc animated:YES];
    } else{
        
        vc.nameID = model.name_id;
        [vc setBlock:^(BOOL isback) {
            
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)clickToDetail1:(UIButton *)sender{
    NSInteger tag2 = sender.tag/102;
    CommentModel *model2 = _commentData[tag2];
    NewDetailViewController *detail2= [[NewDetailViewController alloc]init];
    AidViewController *aid = [[AidViewController alloc]init];
    if ([model2.reply_nameId isEqualToString:@"usergolvon"]) {
        [aid setBlock:^(BOOL isView) {
            
        }];
        [self.navigationController pushViewController:aid animated:YES];
    }else if ([model2.name_id isEqualToString:userDefaultId]){
        detail2.nameID = model2.name_id;
        [detail2 setBlock:^(BOOL isback) {
            
        }];
        [self.navigationController pushViewController:detail2 animated:YES];
    }else{
        
        detail2.nameID = model2.reply_nameId;
        [detail2 setBlock:^(BOOL isback) {
            
        }];
        [self.navigationController pushViewController:detail2 animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        CommentModel *model = _commentData[indexPath.row];
        _reaplyNameId = model.name_id;
        _reaplyName = model.nickName;
        _commentPlaceLabel.text = [NSString stringWithFormat:@"回复:%@",model.nickName];
        
        if ([model.name_id isEqualToString:userDefaultId]) {
            _commentPlaceLabel.text = @"发表评论";
            return;
        }
        [_commentPlaceLabel sizeToFit];
        [_mainTextView becomeFirstResponder];
    }

}

#pragma mark - 评论点赞按钮

-(void)DianZan:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    NSInteger viewTag = sender.tag/100;
    CommentModel *model = _commentData[viewTag];
    
    DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
    NSDictionary *dict = @{
                           @"comment_id":model.comment_id,
                           @"like_user_id":userDefaultId
                           };
    [manager downloadWithUrl:[NSString stringWithFormat:@"%@Golvon/insert_click_like",urlHeader120] parameters:dict complicate:^(BOOL success, id data) {
        sender.userInteractionEnabled = YES;
        
        if (success) {
            NSDictionary *dataDic = data[@"data"][0];
            if ([[dataDic objectForKey:@"code"] isEqualToString:@"1"]) {
                [self loadCommentData];
                [_mainTableView reloadData];
            }
            
        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误" preferredStyle:UIAlertControllerStyleAlert];
//                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }]];
//                
//                [self presentViewController:alertController animated:YES completion:nil];
//            });

            SucessView *sView = [[SucessView alloc] initWithFrame:CGRectMake(WScale(37.1), HScale(44.7), WScale(26.1), HScale(10.8)) imageImageName: @"失败" descStr: @"网络错误"];
            [self.view addSubview:sView];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                sView.hidden = YES;
            });
        
        }
    }];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            WebTableViewCell *web = (WebTableViewCell *)cell;
            web.htmlString = _htmlStr;
            return;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// webView delegate
/*! @brief webView加载完成内容 */

- (void)webViewCell:(WebTableViewCell *)webViewCell loadedHTMLWithHeight:(CGFloat)contentHeight {
    NSLog(@"webView内容高度: %g", contentHeight);
    webViewHeight = contentHeight;
    [_mainTableView reloadData];
    _commanBackView.hidden = NO;

    float tHeight = ScreenHeight * 0.085 + ScreenHeight * 0.765 + webViewHeight + ScreenHeight * 0.171;
    _zhuanZanBtn.frame = CGRectMake(0, tHeight, ScreenWidth, 44);
    float cHeight = _commentData.count * ScreenHeight * 0.171;
    _backGround.contentSize = CGSizeMake(ScreenWidth, tHeight + cHeight + 44);
    [self scrollToreaplayIndex];

}




@end