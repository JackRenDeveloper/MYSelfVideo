//
//  LiveTableViewCell.m
//  CSVideo
//
//  Created by qianfeng on 15/10/17.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "LiveTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "UIView+Common.h"
#import "NewbieModel.h"


@interface LiveTableViewCell ()

@end

@implementation LiveTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadViewData];
}

- (void)reloadViewData {
    
    for (id obj in [self.contentView subviews]) {
        [obj removeFromSuperview];
    }
    
    CGFloat buttonWidth = (width(self.contentView.frame)-10*3)/2;
    CGFloat buttonHeight = height(self.contentView.frame);
    
    NSInteger number = _dataArray.count;
    
    for (int i = 0; i < number; i++) {
        
        CSDateModel *_model = _dataArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(buttonWidth+10)*i, 0, buttonWidth, buttonHeight-36)];
        
        imageView.tag = 1000+i;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:_model.room_src] placeholderImage:[UIImage imageNamed:@"scroll_bgImage"]];
        
        [self.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView), width(imageView.frame), 30)];
        nameLabel.text = _model.room_name;
        nameLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:nameLabel];
        
        UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-14, width(imageView.frame), 14)];
        linView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self.contentView addSubview:linView];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 10, 10)];
        image.image = [UIImage imageNamed:@"user"];
        [linView addSubview:image];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(maxX(image), minY(image)-2, (width(imageView.frame)-28)/4*3, 14)];
        name.text = _model.nickname;
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont systemFontOfSize:10];
        [linView addSubview:name];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(width(linView.frame)-50, minY(name)+2, 50, 10);
        [button setImage:[UIImage imageNamed:@"users"] forState:UIControlStateNormal];
        
        NSInteger online = [_model.online integerValue];
        
        if (online > 10000) {
            float number = online/10000.0;
            [button setTitle:[NSString stringWithFormat:@"%.1f万",number] forState:UIControlStateNormal];
        } else {
            [button setTitle:_model.online forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10];
        
        [linView addSubview:button];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 1000;
    
    CSDateModel *model = _dataArray[tag];
    
    if (_delegate && [_delegate respondsToSelector:@selector(ViewAction:)]) {
        [_delegate ViewAction:model.room_id];
    }
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
