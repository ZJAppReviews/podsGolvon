//
//  NewSelf_ViewController.m
//  Golvon
//
//  Created by shiyingdong on 16/6/1.
//  Copyright © 2016年 苏辉龙. All rights reserved.
//

#import "NewSelf_ViewController.h"

#import "NewSelfCollectionViewCell.h"
#import "CollectionHeader.h"
#import "Follow_ViewController.h"
#import "AboutViewController.h"
#import "Self_P_ViewController.h"
#import "Self_Fans_ViewController.h"
#import "Self_GuanZhuViewController.h"
#import "Self_LY_ViewController.h"
#import "WXApi.h"
#import "UserDetailViewController.h"
#import "ScorRecordViewController.h"
#import "Edit_ViewController.h"
#import "UIView+Size.h"
#import "MarkItem.h"
#import "ImageTool.h"
#import "ChangeHeaderImageViewController.h"
#import "ScoringModel.h"
#import "JPUSHService.h"
#import "SimpleInterest.h"
#import "DynamicViewController.h"
#import "ZhuanFangModel.h"
#import "InterviewDetileViewController.h"
#import "DetailHeaderModel.h"
#import "JPUSHService.h"


@interface NewSelf_ViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,LikeDelegate>
{
    
    NSString *kLinkURL;
    NSString *kLinkTitle;
    NSString *kLinkDescription;
    NSString *kImage;
    
}
@property (strong, nonatomic) UICollectionView *collection;
@property (nonatomic ,strong)UIButton *messageBtn;
@property (nonatomic ,strong)UIButton *setBtn;

@property (nonatomic ,strong)UIImageView *backGroundImage;
@property (nonatomic ,strong)UIImageView *headerImage;
@property (nonatomic ,strong)UILabel *subLayer;
/**
 *
 */
@property (strong, nonatomic) UIView      *backGround;
@property (strong, nonatomic) UIView      *shareView;
@property (strong, nonatomic) UIButton    *cancer;

/**
 *  存放标签的数组
 */
@property (strong, nonatomic) NSArray      *markArr;
@property (strong, nonatomic) NSArray      *lablesArr;
@property (strong, nonatomic) NSMutableArray      *interViewArr;
@property (strong, nonatomic) NSMutableArray      *scoringArr;
@property (strong, nonatomic) NSMutableArray      *headerArr;

@property(nonatomic,strong)NSMutableArray *allPhotoArr;
@property (strong, nonatomic) DownLoadDataSource *loadData;
@property (strong, nonatomic) CollectionHeader      *collectionHeader;
@property (strong, nonatomic) MBProgressHUD   *HUD;             //菊花


@property (copy, nonatomic) NSString    *isLoding;      //是否有正在进行的

@property (copy, nonatomic) NSString    *isToday;       //是否是今天的球赛

@property (copy, nonatomic) NSString    *coverPid;

@property (copy, nonatomic) NSString    *coverPic;

@property (copy, nonatomic) NSString    *interviewID;

@property (copy, nonatomic) NSString    *interViewPic;

@property (strong, nonatomic) UILabel      *redView;

@property (strong, nonatomic) NSString      *interviewState;        //专访状态

@property (assign, nonatomic) NSUInteger playgolfState;
@end

@implementation NewSelf_ViewController


-(DownLoadDataSource *)loadData{
    if (!_loadData) {
        _loadData = [[DownLoadDataSource alloc] init];
    }
    return _loadData;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self testNetState];
    self.navigationController.navigationBarHidden = YES;
    [self setViewData];
    [self requestWithBadgeValue];
    [self loadUnviewData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [userDefaults removeObjectForKey:@"labels"];
}
-(void)testNetState{
    __weak typeof(self) weakself = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        AppDelegate *appdele = [UIApplication sharedApplication].delegate;
        appdele.reachAbilety = status > 0;
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            [weakself alertShowView:@"网络连接失败"];
        }else{
            
            [weakself loadPictureData];
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
}
//提示界面
-(void)alertShowView:(NSString *)str{
    
    SucessView *sView = [[SucessView alloc] initWithFrame:CGRectMake(WScale(37.1), HScale(44.7), WScale(26.1), HScale(10.8)) imageImageName: @"失败" descStr: str];
    [self.view addSubview:sView];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [sView removeFromSuperview];
    });

}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.focus = @"0";
    self.msgs = @"0";
    [self createCollectionView];
    [self createNotification];

}

//显示黑色电池栏
-(void)ViewBlackBar{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}
#pragma mark ---- UI
- (void)createCollectionView{
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(WScale(33.1), HScale(14.7));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing =1.5;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-49) collectionViewLayout:layout];
    _collection.backgroundColor = GPColor(240, 240, 240);
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.bounces = YES;
    _collection.delaysContentTouches = NO;
    layout.headerReferenceSize = CGSizeMake(ScreenWidth, HScale(86.6)-HScale(24.7));
    
    [self.collection registerClass:[CollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selfReusableView"];
    
    [self.collection registerClass:[NewSelfCollectionViewCell class] forCellWithReuseIdentifier:@"NewSelfCollectionViewCell"];
    
    [self.view addSubview:_collection];
    
    UIImageView *maskTop = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, HScale(9.1))];
    maskTop.image = [UIImage imageNamed:@"蒙板固定_上"];
    [self.view addSubview:maskTop];
    
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _messageBtn.frame = CGRectMake(0, 20, 50, 40);
    [_messageBtn setImage:[UIImage imageNamed:@"消息白色"] forState:UIControlStateNormal];
    [_messageBtn addTarget:self action:@selector(cilckToMessage) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _redView = [[UILabel alloc]initWithFrame:CGRectMake(_messageBtn.width - 17, 4, 15, 15)];
    _redView.layer.masksToBounds = YES;
    _redView.layer.cornerRadius = 7.5;
    _redView.backgroundColor = [UIColor redColor];
    _redView.font = [UIFont systemFontOfSize:kHorizontal(13)];
    _redView.textAlignment = NSTextAlignmentCenter;
    [_messageBtn addSubview:_redView];
    
    _redView.hidden = YES;
    [self.view addSubview:_messageBtn];
    
    
    _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _setBtn.frame = CGRectMake(ScreenWidth - 50, 20, 50, 40);
    [_setBtn setImage:[UIImage imageNamed:@"我的_编辑资料"] forState:UIControlStateNormal];
    [_setBtn addTarget:self action:@selector(cilckToSet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, HScale(61.9)   , ScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1];
    [_collection addSubview:line];
    
}
#pragma mark ---- loadData

-(void)createNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataUnreadData) name:@"reloadUnreadData" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataUnreadData) name:@"ReloadSelfData" object:nil];
}
-(void)updataUnreadData{
    
    [self loadUnviewData];
    [self requestWithBadgeValue];

}

-(void)loadUnviewData{
    __weak typeof(self) weakself = self;
    DownLoadDataSource *loadData = [[DownLoadDataSource alloc] init];
    [loadData downloadWithUrl:[NSString stringWithFormat:@"%@msgapi.php?func=unreadinfo",apiHeader120] parameters:@{@"name_id":userDefaultId} complicate:^(BOOL success, id data) {
        if (success) {
            
            UITabBarController *tabVC = (UITabBarController *)self.view.window.rootViewController;
            UINavigationController *pushClassStance = (UINavigationController *)tabVC.viewControllers[4];
            NSString *num = [NSString stringWithFormat:@"%@",data[@"all"]];
            
            weakself.focus = [NSString stringWithFormat:@"%@",data[@"focus"]];
            weakself.msgs = [NSString stringWithFormat:@"%@",data[@"msgs"]];
            NSInteger badgeValue = [weakself.focus intValue] + [weakself.msgs intValue];
            int allnum = [num intValue] - (int)badgeValue;

            NSString *bage = [NSString stringWithFormat:@"%ld",badgeValue];
            
            if (![bage isEqualToString:@"0"]) {
                
                pushClassStance.tabBarItem.badgeValue = [NSString stringWithFormat:@"%@",bage];
            }else{
                pushClassStance.tabBarItem.badgeValue = nil;
            }
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[num integerValue]];
            [JPUSHService setBadge:[num integerValue]];

            [weakself.collection reloadData];
        }
    }];
}

-(void)requestWithBadgeValue{
    __weak typeof(self) weakself = self;
    DownLoadDataSource *loadData = [[DownLoadDataSource alloc] init];
    NSDictionary *parameter = @{@"name_id":userDefaultId};
    
    [loadData downloadWithUrl:[NSString stringWithFormat:@"%@msgapi.php?func=unreadinfo",apiHeader120] parameters:parameter complicate:^(BOOL success, id data) {
        if (success) {
            int num = [data[@"all"]intValue];
            weakself.focus = [NSString stringWithFormat:@"%@",data[@"focus"]];
            weakself.msgs = [NSString stringWithFormat:@"%@",data[@"msgs"]];
            int allnum = num - [weakself.focus intValue] - [weakself.msgs intValue];
            
            if (allnum == 0) {
                
                weakself.redView.hidden = YES;
                
            }else{
                weakself.redView.hidden = NO;
                weakself.redView.text = [NSString stringWithFormat:@"%d",allnum];
                weakself.redView.textColor = WhiteColor;
                weakself.redView.adjustsFontSizeToFitWidth = YES;
            }
            [weakself.collection reloadData];
            [userDefaults setValue:[NSString stringWithFormat:@"%d",allnum] forKey:@"unreadAll"];
        }
        [weakself.collection reloadData];
    }];
}

//更换封面
-(void)changeCoverImage{
    
    NSDictionary *parameter = @{@"name_id" : userDefaultId,
                                @"coverpid" : _coverPid};
    
    DownLoadDataSource *loadData = [[DownLoadDataSource alloc] init];
    [loadData downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=changephoto",apiHeader120] parameters:parameter complicate:^(BOOL success, id data) {
        
        if (success) {
            NSString *code = data[@"code"];
            if ([code isEqualToString:@"0"]) {
                
            }else{
            }
        }
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    CGFloat offY = scrollView.contentOffset.y+50;
    CGFloat maxOffsetY = -100; ///< 计算比率的最大偏移量
    CGFloat offSetY = scrollView.contentOffset.y;
    
    if (offSetY >= HScale(24.7)) {
        _collectionHeader.backGroundImage.height = 0;
        
    }else{
        _collectionHeader.backGroundImage.height = HScale(24.7)-offSetY;
    }
    _collectionHeader.backGroundImage.top = offSetY;
    
    
    if (offY <= 0) {
        if (offY == 0) {
            for (MarkItem *markItem in _markArr) {
                [markItem updateViewPositionWithRatio:0];
            }
        } else if (offY >= maxOffsetY) {
            for (MarkItem *markItem in _markArr) {
                [markItem updateViewPositionWithRatio:fabs(offY)/fabs(maxOffsetY)];
            }
        } else {
            for (MarkItem *markItem in _markArr) {
                [markItem updateViewPositionWithRatio:1];
            }
        }
    }

}

// 获取个人信息
-(void)setViewData{
    __weak typeof(self) weakself = self;
    DownLoadDataSource *loadData = [[DownLoadDataSource alloc] init];

    NSDictionary *parameters = @{@"name_id":userDefaultUid,
                                 @"uid":userDefaultUid};
    
    [loadData downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=getui",apiHeader120] parameters:parameters complicate:^(BOOL success, id data) {
        if (success) {
            weakself.interViewArr = [NSMutableArray array];
            weakself.scoringArr = [NSMutableArray array];
            
            NSDictionary *uiDic = data[@"ui"];
            
            DetailHeaderModel *headerModel = [DetailHeaderModel initWithDictionary:uiDic];
            [weakself.headerArr addObject:headerModel];

            
            if ([headerModel.vid isEqualToString:@"0"]) {

                weakself.interViewPic = @"http://120.26.122.102/GolvonImage/image/APPdefult/DefultInterviewX3.png";
                weakself.interviewID = @"0";
            }else{
                
                ZhuanFangModel *interviewModel = [ZhuanFangModel paresFromDictionary:uiDic[@"v"][0]];
                [weakself.interViewArr addObject:interviewModel];
                weakself.interViewPic = interviewModel.image;
                weakself.interviewID = headerModel.vid;
            }
            self.lablesArr = uiDic[@"labels"];
            if ([self.lablesArr count] != 0) {
                
                [userDefaults setValue:self.lablesArr forKey:@"labels"];
                
            }
            
            NSArray *tempArr = uiDic[@"lastgame"];
            weakself.playgolfState = [tempArr count];
            
            if ([tempArr count] != 0) {
                
                ScoringModel *scorModel = [ScoringModel pareFromWith:uiDic[@"lastgame"]];
                NSMutableString *time = [NSMutableString stringWithFormat:@"%@",scorModel.timeLabel];
                [time replaceCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
                [time replaceCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
                [time replaceCharactersInRange:NSMakeRange(10, 1) withString:@"日"];
                [time deleteCharactersInRange:NSMakeRange(0, 5)];
                [time deleteCharactersInRange:NSMakeRange(6, time.length-6)];
                scorModel.timeLabel = time;
                weakself.isLoding = scorModel.isfinished;
                weakself.isToday = scorModel.istoday;
                [weakself.scoringArr addObject:scorModel];
                
            }else{
                
                weakself.isLoding = @"1";
                weakself.isToday = @"1";
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
            [weakself.collectionHeader.headerImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"headerDefault_L"]];
            
            
            if ([[userDefaults objectForKey:@"province"] isEqualToString:[userDefaults objectForKey:@"city"]]) {
                weakself.collectionHeader.ownMessage.text = [NSString stringWithFormat:@"%@ %@ %@ %@" ,[userDefaults objectForKey:@"age"],[userDefaults objectForKey:@"polenum"],[userDefaults objectForKey:@"city"],[userDefaults objectForKey:@"job"]];
            }else{
                weakself.collectionHeader.ownMessage.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@" ,[userDefaults objectForKey:@"age"],[userDefaults objectForKey:@"polenum"],[userDefaults objectForKey:@"province"],[userDefaults objectForKey:@"city"],[userDefaults objectForKey:@"job"]];
                
                
            [weakself.collectionHeader reloadData];
            [weakself loadPictureData];
            [weakself.collection reloadData];
        }
    }];

}

//获取图片数据
-(void)loadPictureData{
    __weak typeof(self) weakself = self;
    DownLoadDataSource *loadDataManager = [[DownLoadDataSource alloc] init];
    NSDictionary *userDic = @{
                              @"name_id":userDefaultId,
                              @"iscover":@"1"
                              };
    [loadDataManager downloadWithUrl:[NSString stringWithFormat:@"%@commonapi.php?func=getpics",apiHeader120]parameters:userDic complicate:^(BOOL success, id data) {
        if (success) {
            weakself.allPhotoArr = [NSMutableArray array];
            NSArray *tempArr = data[@"data"];
            for (int i = 0; i<tempArr.count; i++) {
                [weakself.allPhotoArr addObject:tempArr[i][@"url"]];
            }
            [weakself.collection reloadData];
            
        }
        
    }];
    
}

-(void)requestFansData{
    NSDictionary *dic = @{
                          @"name_id":userDefaultId
                          };
    __weak typeof(self) weakself = self;
    [self.loadData downloadWithUrl:[NSString stringWithFormat:@"%@msgapi.php?func=setreadfocus",apiHeader120] parameters:dic complicate:^(BOOL success, id data) {
        if (success) {
            NSString *code = data[@"data"][0][@"code"];
            if ([code isEqualToString:@"0"]) {
                weakself.focus = @"0";
                [weakself requestWithBadgeValue];
                [weakself loadUnviewData];
            }else{
                NSLog(@"错误");
            }
            
            [weakself.collection reloadData];

        }
    }];
}

-(void)requestMessageData{
    
    __weak typeof(self) weakself = self;
    NSDictionary *dic = @{
                          @"name_id":userDefaultId
                          };
    [self.loadData downloadWithUrl:[NSString stringWithFormat:@"%@msgapi.php?func=setreadmsgs",apiHeader120] parameters:dic complicate:^(BOOL success, id data) {
        if (success) {
            NSString *code = data[@"data"][0][@"code"];
            if ([code isEqualToString:@"0"]) {
                
                weakself.msgs = @"0";
                [weakself requestWithBadgeValue];
                [weakself loadUnviewData];

                
            }else{

            }
            
            [weakself.collection reloadData];

        }
    }];
}
#pragma mark ---- ImagePicker代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self loadImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
            }else {
                //                    NSLog(@"不支持 拍照 功能");
            }
            break;
        case 1:
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self loadImagePickerControllerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
            }else {
                //                    NSLog(@"不支持 相册 功能");
            }
            break;
            
        default:
            break;
    }
}
- (void)loadImagePickerControllerWithType:(UIImagePickerControllerSourceType)type {
    //
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = type;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage * image = info[UIImagePickerControllerEditedImage];
    
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    __weak typeof(self) weakself = self;
    UIImage *resizedImage = [UIImage scaleToSize:image size:CGSizeMake(600, 600)];
    
    NSString *path = [NSString stringWithFormat:@"%@upload.php",apiHeader120];
    NSDictionary *parameters = @{
                                 @"name_id":userDefaultId,
                                 @"type":@"0"
                                 };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/plain",
                                                         @"multipart/form-data",
                                                         @"text/json",
                                                         nil];
    
    [manager POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData =UIImageJPEGRepresentation(resizedImage, 1.0f);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", dateString];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"]; //
        
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        
        [weakself.collectionHeader.backGroundImage setImage:resizedImage];
        NSError *error = nil;
        id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        NSString *code = data[@"code"];
        if ([code isEqualToString:@"1"]) {
            
            weakself.coverPid = data[@"pid"][0];
            weakself.coverPic = data[@"url"][0];
            
            [userDefaults setObject:self.coverPic forKey:@"coverPic"];
            
            [weakself changeCoverImage];
            
        }else{
//            NSLog(@"上传失败");
        }
        
        [weakself dismissViewControllerAnimated:YES completion:NULL];
        
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError * _Nonnull error) {
        //上传失败
//        NSLog(@"上传失败%@",error);
    }];
    
}

#pragma mark ---- collectionView 代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NewSelfCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewSelfCollectionViewCell" forIndexPath:indexPath];
    
    
    cell.botlabel.text = @[@"相册",@"记分",@"专访",@"分享",@"关于"][indexPath.row];
    cell.jifen.hidden = YES;
    cell.topImage.hidden = NO;
    cell.imageView.hidden = YES;
    cell.playImage.hidden = YES;
    cell.circle.hidden = YES;
    
    
    if (indexPath.row == 0) {
        cell.topImage.image = [UIImage imageNamed:@"动态等待图"];
        if (_allPhotoArr.count>0) {
            NSString *picURL = [_allPhotoArr firstObject];
            [cell.topImage sd_setImageWithURL:[NSURL URLWithString:picURL] placeholderImage:[UIImage imageNamed:@"动态等待图"]];
            cell.topImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.topImage.clipsToBounds = YES;
        }else{
            [cell.topImage sd_setImageWithURL:[NSURL URLWithString:@"http://120.26.122.102/GolvonImage/image/userDynamic.png"] placeholderImage:[UIImage imageNamed:@"动态等待图"]];
            cell.topImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.topImage.clipsToBounds = YES;
        }
    }else if (indexPath.row == 1){
        [cell.topImage sd_setImageWithURL:[NSURL URLWithString:@"http://120.26.122.102/GolvonImage/image/APPdefult/JiFenKaDefult.png"] placeholderImage:[UIImage imageNamed:@"动态等待图"]];
        if ([_isLoding isEqualToString:@"0"]) {
            cell.playImage.hidden = NO;
            cell.circle.hidden = NO;
            if ([_isToday isEqualToString:@"0"]) {
                
                cell.playImage.frame = CGRectMake((cell.width - WScale(7.5))/2, HScale(3.4), WScale(7.5), WScale(7.5));
                cell.playImage.image = [UIImage imageNamed:@"未完成（我的）"];
                cell.botlabel.text = @"未完成";
                
            }else{
                
                cell.botlabel.text = @"正在进行";
                cell.playImage.frame = CGRectMake((cell.width - kWvertical(7))/2, kHvertical(33), kWvertical(8), kHvertical(10));
                cell.playImage.image = [UIImage imageNamed:@"scroingCenter_own"];
                
                cell.circle.image = [UIImage imageNamed:@"scroringPlay_own"];
                cell.circle.frame = CGRectMake((cell.width -  kWvertical(30))/2, kHvertical(23), kWvertical(30),  kWvertical(30));
                cell.circle.userInteractionEnabled = YES;
                cell.circle.layer.masksToBounds = YES;
                cell.circle.layer.cornerRadius =  kWvertical(30)/2;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    CABasicAnimation *rotationAnim = [CABasicAnimation animation];
                    rotationAnim.keyPath = @"transform.rotation.z";
                    rotationAnim.toValue = @(2 * M_PI);
                    rotationAnim.duration = 5;
                    rotationAnim.cumulative = YES;
                    rotationAnim.repeatCount = HUGE_VALF;
                    [cell.circle.layer addAnimation:rotationAnim forKey:@"rotationAnim"];
                    
                });
                
            }
        }else{
            
            cell.jifen.hidden = NO;
            cell.jifen.textColor = [UIColor whiteColor];
            cell.jifen.frame = CGRectMake( (cell.width - WScale(18))/2, 0, WScale(18),cell.height-15);
            cell.jifen.text = @"三轮车";
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",[userDefaults objectForKey:@"polenum"]];
            NSString *lastStr = [str substringWithRange:NSMakeRange(str.length-1,1)];
            if ([lastStr isEqualToString:@"杆"]) {
                [str replaceCharactersInRange:NSMakeRange(str.length-1, 1) withString:@""];
            }
            if (str) {
                cell.jifen.text  = str;
            }
            cell.jifen.textAlignment = NSTextAlignmentCenter;
            cell.jifen .adjustsFontSizeToFitWidth = YES;
        }
        
    }else if (indexPath.row == 2){
        
            [cell.topImage sd_setImageWithURL:[NSURL URLWithString:self.interViewPic]];
            cell.topImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.topImage.clipsToBounds = YES;
        
        return cell;
    }else if (indexPath.row == 3){
        [cell.topImage sd_setImageWithURL:[NSURL URLWithString:@"http://120.26.122.102/GolvonImage/image/APPdefult/ShareX3.png"]];
        cell.topImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.topImage.clipsToBounds = YES;
        cell.imageView.hidden = NO;
        cell.imageView.frame = CGRectMake(WScale(10.9), HScale(3.4), WScale(11.2), HScale(5.2));
        cell.imageView.image = [UIImage imageNamed:@"我的_微信icon"];
        return cell;
    }else{
        
        [cell.topImage sd_setImageWithURL:[NSURL URLWithString:@"http://120.26.122.102/GolvonImage/image/APPdefult/AboutX3.png"]];
        
        cell.topImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.topImage.clipsToBounds = YES;
        cell.imageView.hidden = NO;
        cell.imageView.frame = CGRectMake(WScale(9.6), HScale(2.4), WScale(11.5), HScale(6.6));
        cell.imageView.image = [UIImage imageNamed:@"我的_关于"];
        return cell;
    }
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        DynamicViewController *photo = [[DynamicViewController alloc]init];
        photo.nameid = userDefaultUid;
        photo.hidesBottomBarWhenPushed = YES;
        [self ViewBlackBar];
        
        [self.navigationController pushViewController:photo animated:YES];
    }
    else if (indexPath.row == 1){
        
        ScorRecordViewController *save = [[ScorRecordViewController alloc]init];
        save.logInNameId = userDefaultId;
        save.nameUid = userDefaultUid;
        save.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:save animated:YES];

        [self ViewBlackBar];
    }
    else if (indexPath.row == 2){
        
        if ([_interviewID isEqualToString:@"0"]) {
            UserDetailViewController *uvc = [[UserDetailViewController alloc] init];
            uvc.urlStr = @"https://mp.weixin.qq.com/s?__biz=MzIwMDA5MTQ2NA==&mid=404508847&idx=1&sn=b2314801cb73b4b55604096123536eeb&scene=1&srcid=0421EOqXwMNfdGdrpYhmvUVQ&key=b28b03434249256b19f3efca24c833481ab9e66d8e1e9a935fd9731a4eab1a54cf506b48e8c63dddf8f314d9f0dfaccd&ascene=0&uin=MTU2OTMwMzQ2MA%3D%3D&devicetype=iMac16%2C1+OSX+OSX+10.11.3+build(15D21)&version=11020201&pass_ticket=j8xY5wuBLTtUXqWdUm1INU0Ffa28jEYx2JdF1y5k6HIo45q4J3ewpH3mCg9NopHc";
            
            uvc.titleStr = @"快来成为高尔夫达人吧!";
            uvc.picUrl = @"http://120.26.122.102/GolvonImage/image/golvonzhushou.png";
            uvc.hidesBottomBarWhenPushed = YES;
            [self ViewBlackBar];
            
            [self.navigationController pushViewController:uvc animated:YES];
        }else{
            ZhuanFangModel *model = self.interViewArr[0];
            InterviewDetileViewController *zhuanfang = [[InterviewDetileViewController alloc] init];
            zhuanfang.ID = _interviewID;
            zhuanfang.htmlStr = model.url;
            zhuanfang.titleStr = model.title;
            zhuanfang.addTimeStr = model.time;
            zhuanfang.readStr = model.readnum;
            zhuanfang.likeStr = model.clicks;
            zhuanfang.type = @"2";
            zhuanfang.likeDelegate = self;
            zhuanfang.isLike = model.liked;
            zhuanfang.name_id = userDefaultUid;
            zhuanfang.hidesBottomBarWhenPushed = YES;
            [zhuanfang setBlock:^(BOOL isView) {
                
            }];
            [self ViewBlackBar];
            
            [self.navigationController pushViewController:zhuanfang animated:YES];
        }
    }
    else if (indexPath.row == 3){
        [self cilckToShare];
    }
    else if (indexPath.row == 4){
        AboutViewController *about = [[AboutViewController alloc]init];
        about.hidesBottomBarWhenPushed = YES;
        [self ViewBlackBar];
        
        [self.navigationController pushViewController:about animated:YES];
    }
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (self.view.frame.size.height <= 568)
    {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else if (self.view.frame.size.height > 568 && self.view.frame.size.height <= 667)
    {
        return UIEdgeInsetsMake(HScale(1.5), 0, 0, 0);
    }
    return UIEdgeInsetsMake(HScale(2.0), 0, 0, 0);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    _collectionHeader = [_collection dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selfReusableView" forIndexPath:indexPath];
    
    _collectionHeader.unReadMessage.hidden = YES;
    _collectionHeader.unReadFans.hidden = YES;
    
    [_collectionHeader.fansBtn addTarget:self action:@selector(clickToFans) forControlEvents:UIControlEventTouchUpInside];
    [_collectionHeader.followBtn addTarget:self action:@selector(clickToFollow) forControlEvents:UIControlEventTouchUpInside];
    [_collectionHeader.liuyanBtn addTarget:self action:@selector(clickToLiuyan) forControlEvents:UIControlEventTouchUpInside];
    if (_interviewState == nil) {
        _collectionHeader.Vimage.hidden = YES;
    }else{
        _collectionHeader.Vimage.image = [UIImage imageNamed:@"个人中心加v"];
    }
    
    _subLayer = _collectionHeader.subLayer;
    
    if ([_lablesArr count] != 0) {
        
        _markArr = _collectionHeader.markItemsArray;

    }

    
    if ([_msgs isEqualToString:@"0"]) {
        _collectionHeader.unReadMessage.hidden = YES;
    }else{
        _collectionHeader.unReadMessage.hidden = NO;
    }
    
    if ([_focus isEqualToString:@"0"]) {
        _collectionHeader.unReadFans.hidden = YES;
    }else{
        _collectionHeader.unReadFans.hidden = NO;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHeaderView)];
    [_collectionHeader.headerImage addGestureRecognizer:tap];
    
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToBackGroundImage)];
    [_collectionHeader.backGroundImage addGestureRecognizer:tap1];
    
    [_collectionHeader reloadData];
    return _collectionHeader;
    
}

#pragma mark ---- 点击事件
// 跳转到关注的界面
-(void)clickToFollow{
    
    Self_GuanZhuViewController *svc = [[Self_GuanZhuViewController alloc] init];
    svc.name_id = userDefaultUid;
    svc.login_state = 1;
    svc.hidesBottomBarWhenPushed = YES;
    [self ViewBlackBar];
    
    [self.navigationController pushViewController:svc animated:YES];
}
//跳转到粉丝的界面
-(void)clickToFans{
    
    Self_Fans_ViewController *fans = [[Self_Fans_ViewController alloc]init];
    fans.hidesBottomBarWhenPushed = YES;
    fans.login_Id = @"1";
    fans.name_id = userDefaultUid;
    [self requestFansData];
    [self ViewBlackBar];
    
    [self.navigationController pushViewController:fans animated:YES];
}
//跳转到留言的界面
-(void)clickToLiuyan{
    Self_LY_ViewController *liuyan = [[Self_LY_ViewController alloc]init];
    NSString *nickname = [userDefaults objectForKey:@"nickname"];
    if (nickname) {
        liuyan.nickName = nickname;
    }
    liuyan.nameID = userDefaultUid;
    liuyan.hidesBottomBarWhenPushed = YES;
    _collectionHeader.unReadMessage.hidden = YES;
    [self ViewBlackBar];
    [self requestMessageData];
    [self.navigationController pushViewController:liuyan animated:YES];
}

//跳转消息界面
-(void)cilckToMessage{
    
    Follow_ViewController *follow = [[Follow_ViewController alloc]init];
    follow.hidesBottomBarWhenPushed = YES;
    [self ViewBlackBar];
    [self.navigationController pushViewController:follow animated:YES];
}
-(void)cilckToSet{
    
    Edit_ViewController *about = [[Edit_ViewController alloc]init];
    about.logIntype = @"1";
    about.nameid = userDefaultId;
    about.phoneNumber = [userDefaults objectForKey:@"phone"];
    about.hidesBottomBarWhenPushed = YES;
    [self ViewBlackBar];
    [self.navigationController pushViewController:about animated:YES];
    
}
//点击更换头像
-(void)clickToHeaderView{
    
    ChangeHeaderImageViewController *change = [[ChangeHeaderImageViewController alloc]init];
    change.avatarView = _collectionHeader.headerImage;
    change.hidesBottomBarWhenPushed = YES;
    [self ViewBlackBar];
    
    [self.navigationController pushViewController:change animated:NO];
}
//点击更换封面
-(void)clickToBackGroundImage{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    actionSheet.tag = 1000;
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showFromRect:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight) inView:self.view animated:YES];
}

-(void)cilckToShare{
    
    _backGround = [[UIView alloc]init];
    _backGround.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _backGround.backgroundColor = [UIColor blackColor];
    _backGround.alpha = 0.5;
    _backGround.hidden = NO;
    _backGround.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToCancer)];
    [_backGround addGestureRecognizer:tap];
    [self.view addSubview:_backGround];
    
    
    _shareView = [[UIView alloc]init];
    _shareView.frame = CGRectMake(WScale(50), HScale(50), 0, 0);
    _shareView.layer.cornerRadius = 8;
    _shareView.tag = 101;
    _shareView.hidden = NO;
    _shareView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_shareView];
    
    UIButton *haoYou = [UIButton buttonWithType:UIButtonTypeCustom];
    haoYou.adjustsImageWhenHighlighted = false;
    [haoYou setBackgroundImage:[UIImage imageNamed:@"推荐给微信好友"] forState: UIControlStateNormal];
    [haoYou addTarget:self action:@selector(clickToHaoYou) forControlEvents:UIControlEventTouchUpInside];
    haoYou.frame = CGRectMake(WScale(10.8), HScale(6.3), ScreenWidth * 0.181, ScreenHeight * 0.102);
    [_shareView addSubview:haoYou];
    UILabel *haoyouLabel = [[UILabel alloc]initWithFrame:CGRectMake(WScale(13.6), HScale(17.4), WScale(16), HScale(2.5))];
    haoyouLabel.text = @"微信好友";
    haoyouLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
    haoyouLabel.textColor = deepColor;
    [_shareView addSubview:haoyouLabel];
    
    UIButton *pengYouQuan = [UIButton buttonWithType:UIButtonTypeCustom];
    pengYouQuan.adjustsImageWhenHighlighted = false;
    [pengYouQuan setBackgroundImage:[UIImage imageNamed:@"推荐到微信朋友圈"] forState: UIControlStateNormal];
    [pengYouQuan addTarget:self action:@selector(clickToPengYouQuan) forControlEvents:UIControlEventTouchUpInside];
    pengYouQuan.frame = CGRectMake(WScale(40.3), HScale(6.3), ScreenWidth * 0.181, ScreenHeight * 0.102);
    [_shareView addSubview:pengYouQuan];
    UILabel *pengyouLabel = [[UILabel alloc]initWithFrame:CGRectMake(WScale(41.3), HScale(17.4), WScale(18), HScale(2.5))];
    pengyouLabel.font = [UIFont systemFontOfSize:kHorizontal(12)];
    pengyouLabel.text = @"微信朋友圈";
    pengyouLabel.textColor = deepColor;
    [_shareView addSubview:pengyouLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, HScale(23.4), ScreenWidth * 0.691, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_shareView addSubview:line];
    
    _cancer = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancer.tag = 102;
    _cancer.hidden = NO;
    [_cancer setTitle:@"取消" forState:UIControlStateNormal];
    _cancer.frame = CGRectMake(WScale(15.5), HScale(55.4)+1, WScale(69.1), ScreenHeight *0.064);
    [_cancer setTitleColor:localColor forState:UIControlStateNormal];
    [_cancer addTarget:self action:@selector(clickToCancer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancer];
    _shareView.frame = CGRectMake(WScale(15.5), HScale(32), ScreenWidth * 0.691, ScreenHeight *0.298);
    [self loadShareData];
    
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
    
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
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
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = kLinkURL;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}
-(void)clickToCancer{
    _backGround.hidden = YES;
    _shareView.hidden = YES;
    _cancer.hidden = YES;
    
}
-(void)loadShareData{
    
    DownLoadDataSource *manager = [[DownLoadDataSource alloc] init];
    
    NSDictionary *dict = @{
                           @"interview_id":@"1"
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
            }
            
        }
        
    }];
}

-(void)likeBtnSelected:(BOOL)isSelected withLikeNum:(NSString *)likenum{
    ZhuanFangModel *model = _interViewArr[0];
    model.liked = isSelected;
    model.clicks = likenum;
}

@end