//
//  SegmentButton.m
//  FindModule
//
//  Created by apple on 2016/12/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SegmentButton.h"
#import "UIView+Size.h"

@implementation SegmentButton

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
        self.titleLabel.left = 0;
    self.titleLabel.top = self.imageView.bottom;
    self.titleLabel.height = self.height - self.titleLabel.top - self.imageView.top - 5;
    self.titleLabel.width = self.width;
}


@end
