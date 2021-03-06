//
//  AddByInputTableViewCell.m
//  podsGolvon
//
//  Created by SHL on 2016/12/28.
//  Copyright © 2016年 suhuilong. All rights reserved.
//

#import "AddByInputTableViewCell.h"

@implementation AddByInputTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

-(void)createUI{
    UILabel *nickName = [Factory createLabelWithFrame:CGRectMake(kWvertical(12), 0, 0, kHvertical(45)) textColor:rgba(185,185,189,1) fontSize:kHorizontal(14) Title:@"* 昵昵称称："];
    [nickName sizeToFitSelf];
    nickName.text = @"   昵      称：";
    UIView *line = [Factory createViewWithBackgroundColor:rgba(225,226,228,1) frame:CGRectMake(kWvertical(25), kHvertical(44), ScreenWidth - kWvertical(25), 0.5)];
    
    
    UILabel *phoneNUmber = [Factory createLabelWithFrame:CGRectMake(nickName.x, line.y_height, nickName.width, nickName.height) textColor:rgba(185,185,189,1) fontSize:kHorizontal(14)  Title:@"* 手机号码："];
    
    
    _nickName = [[UITextField alloc] initWithFrame:CGRectMake(nickName.x_width, 0, ScreenWidth-_nickName.x, phoneNUmber.height)];
    _nickName.font = [UIFont systemFontOfSize:kHorizontal(14)];
    _nickName.returnKeyType = UIReturnKeyDone;
    
    _phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(nickName.x_width, _nickName.y_height, ScreenWidth-_phoneNumber.x, _nickName.height)];
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumber.font = [UIFont systemFontOfSize:kHorizontal(14)];
    UIView *bottomView = [Factory createViewWithBackgroundColor:GPColor(238, 239, 241) frame:CGRectMake(0, _phoneNumber.y_height, ScreenWidth, kHvertical(8))];
    
    [self.contentView addSubview:nickName];
    [self.contentView addSubview:phoneNUmber];
    [self.contentView addSubview:_nickName];
    [self.contentView addSubview:_phoneNumber];
    [self.contentView addSubview:line];
    [self.contentView addSubview:bottomView];
}

-(void)configModel:(GolfersModel *)model{

    _nickName.text = model.nickname;
    _phoneNumber.text = model.phoneStr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
