//
//  RecomentTableViewCell.m
//  podsGolvon
//
//  Created by apple on 2016/12/8.
//  Copyright © 2016年 suhuilong. All rights reserved.
//

#import "RecomentTableViewCell.h"

@implementation RecomentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createCell];
    }
    return self;
}

-(void)createCell{
    
    _todayIcon = [[UIImageView alloc] init];
    [_todayIcon setImage:[UIImage imageNamed:@"todayIcon"]];
    _todayIcon.frame = CGRectMake(kWvertical(12),(kHvertical(59) - kHvertical(17))/2, kWvertical(82), kHvertical(17));
    [self.contentView addSubview:_todayIcon];
    
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(kWvertical(106), kHvertical(10), 0.5, kHvertical(40));
    line.backgroundColor = SeparatorColor;
    [self.contentView addSubview:line];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(kWvertical(118), kHvertical(11), kWvertical(213), kHvertical(18));
    _titleLabel.font = [UIFont systemFontOfSize:kHorizontal(13)];
    _titleLabel.textColor = deepColor;
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.frame = CGRectMake(_titleLabel.x, kHvertical(33), kWvertical(213), kHvertical(16));
    _contentLabel.font = [UIFont systemFontOfSize:kHorizontal(11)];
    _contentLabel.textColor = textTintColor;
    [self.contentView addSubview:_contentLabel];
    
    
    _clickIcon = [[UIImageView alloc] init];
    _clickIcon.frame = CGRectMake(ScreenWidth - kWvertical(20), (kHvertical(60)-kHvertical(12))/2, kWvertical(6), kHvertical(11));
    _clickIcon.image = [UIImage imageNamed:@"FindClickIcon"];
    [self.contentView addSubview:_clickIcon];
}
-(void)relayoutDataWithModel:(RecomInformModel *)model{
    _titleLabel.text = model.title;
    _contentLabel.text = model.content;
}
@end
