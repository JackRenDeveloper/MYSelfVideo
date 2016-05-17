
//
//  CSMediaCell.m
//  CSVideo
//
//  Created by qianfeng on 15/10/19.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "CSMediaCell.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>

@interface CSMediaCell () {
    UIImageView *_imageView;
    UILabel *_roomNameLabel;
    UIButton *_onlineButton;
}

@end

@implementation CSMediaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customsViews];
    }
    return self;
}

- (void)customsViews {
    _imageView = [UIImageView new];
    [self.contentView addSubview:_imageView];
    
    _roomNameLabel = [UILabel new];
    [self.contentView addSubview:_roomNameLabel];
    
    _onlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_onlineButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(5, 15, 130, 70);
    
    _roomNameLabel.frame = CGRectMake(maxX(_imageView)+5, 20, width(self.frame)-maxX(_imageView)-10, 30);
    
    _onlineButton.frame = CGRectMake(minX(_roomNameLabel), maxY(_roomNameLabel), width(_roomNameLabel.frame), 30);
    
}

- (void)setModel:(CSDateModel *)model {
    _model = model;
    [self reloadModelData];
}

- (void)reloadModelData {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_model.room_src] placeholderImage:[UIImage imageNamed:@"scroll_bgImage"]];
    
    _roomNameLabel.text = _model.room_name;
    _roomNameLabel.font = [UIFont systemFontOfSize:15];
    _roomNameLabel.textColor = [UIColor whiteColor];
    
    NSInteger online = [_model.online integerValue];
    
    [_onlineButton setImage:[UIImage imageNamed:@"users"] forState:UIControlStateNormal];
    
    if (online > 10000) {
        float number = online/10000.0;
        [_onlineButton setTitle:[NSString stringWithFormat:@"%.1f万",number] forState:UIControlStateNormal];
    } else {
        [_onlineButton setTitle:_model.online forState:UIControlStateNormal];
    }
    [_onlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
