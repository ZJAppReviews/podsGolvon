//
//  ActivityDetailViewController.h
//  podsGolvon
//
//  Created by apple on 2016/12/26.
//  Copyright © 2016年 suhuilong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^applyVisionBlock) (BOOL isVision);


@interface ActivityDetailViewController : UIViewController

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *titleStr;
@property (copy, nonatomic) NSString *addTimeStr;
@property (copy, nonatomic) NSString *readStr;
@property (copy, nonatomic) NSString *endTimeStr;
@property (copy, nonatomic) NSString *maskPic;
@property (copy, nonatomic) NSString *htmlStr;

@property (nonatomic, strong) applyVisionBlock   block;

-(void)setBlock:(applyVisionBlock)block;
@end
