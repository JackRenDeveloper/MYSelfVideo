//
//  CSChannelTableViewCell.m
//  CSVideo
//
//  Created by qianfeng on 15/10/15.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "CSChannelTableViewCell.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>

@interface CSChannelTableViewCell () <UIScrollViewDelegate> {
    UILabel *_colorLabel;
    UILabel *_gameNameLabel;
    UIButton *_moreButton;
    UIButton *_moreButtonImage;
    UIScrollView *_fourImageView;
    UILabel *_lineLabel;
}

@end

@implementation CSChannelTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customsView];
    }
    return self;
}

- (void)customsView {
    _colorLabel = [UILabel new];
    [self.contentView addSubview:_colorLabel];
    
    _gameNameLabel = [UILabel new];
    [self.contentView addSubview:_gameNameLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_moreButton];
    
    _moreButtonImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_moreButtonImage];
    
    _fourImageView = [UIScrollView new];
    _fourImageView.delegate = self;
    [self.contentView addSubview:_fourImageView];
    
    _lineLabel = [UILabel new];
    [self.contentView addSubview:_lineLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _colorLabel.frame = CGRectMake(5, 10, 6, 18);
    _colorLabel.backgroundColor = [UIColor orangeColor];
    _colorLabel.layer.cornerRadius = 2.0;
    _colorLabel.clipsToBounds = YES;
    
    _gameNameLabel.frame = CGRectMake(maxX(_colorLabel)+7, minY(_colorLabel), width(self.contentView.frame)-100, 20);
    
    _moreButton.frame = CGRectMake(width(self.contentView.frame)-70, minY(_colorLabel)-10, 40, height(_colorLabel.frame)+20);
    [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _moreButtonImage.frame = CGRectMake(maxX(_moreButton), midY(_colorLabel)-7, 14, 14);
    [_moreButtonImage addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _fourImageView.frame = CGRectMake(10, maxY(_colorLabel)+5, width(self.contentView.frame)-20, (width(self.contentView.frame)-20)/3);
    
    _lineLabel.frame = CGRectMake(0, maxY(_fourImageView), width(self.contentView.frame), 1);
    _lineLabel.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    [self reloadImage];
    
}

- (void)moreButtonAction:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(ButtonAction:)]) {
        [_delegate ButtonAction:_model.cate_id];
    }
}

- (void)reloadImage {
    for (id obj in [_fourImageView subviews]) {
        [obj removeFromSuperview];
    }
    
    for (int i = 0; i < _model.roomlist.count; i++) {
        
        CSDateModel *roomList = _model.roomlist[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(((width(self.contentView.frame)-20)/2+10)*i, 0, (width(self.contentView.frame)-20)/2-5, height(self.contentView.frame)-70)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:roomList.room_src] placeholderImage:[UIImage imageNamed:@"scroll_bgImage"]];
        
        imageView.tag = 100+i;
        
        [_fourImageView addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView), width(imageView.frame), 30)];
        nameLabel.text = roomList.room_name;
        nameLabel.font = [UIFont systemFontOfSize:13];
        [_fourImageView addSubview:nameLabel];
        
        UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-14, width(imageView.frame), 14)];
        linView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_fourImageView addSubview:linView];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 10, 10)];
        image.image = [UIImage imageNamed:@"user"];
        [linView addSubview:image];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(maxX(image)+2, minY(image)-2, (width(imageView.frame)-28)/4*3, 14)];
        name.text = roomList.nickname;
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont systemFontOfSize:10];
        [linView addSubview:name];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(width(linView.frame)-50, minY(name)+2, 50, 10);
        [button setImage:[UIImage imageNamed:@"users"] forState:UIControlStateNormal];
        
        NSInteger online = [roomList.online integerValue];
        
        if (online > 10000) {
            float number = online/10000.0;
            [button setTitle:[NSString stringWithFormat:@"%.1f万",number] forState:UIControlStateNormal];
        } else {
            [button setTitle:roomList.online forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10];
        
        [linView addSubview:button];
    }
    _fourImageView.contentSize = CGSizeMake(((width(self.contentView.frame)-20)/2+10)*_model.roomlist.count, height(self.contentView.frame)-80);
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    NSInteger viewTag = tap.view.tag-100;
    
    CSDateModel *dataModel = _model.roomlist[viewTag];
    
    NSLog(@"%@",dataModel.room_id);
    
    if (_delegate && [_delegate respondsToSelector:@selector(ViewAction:)]) {
        [_delegate ViewAction:dataModel.room_id];
    }
}

- (void)setModel:(CSChanneDataModel *)model {
    _model = model;
    [self reloadData];
}

- (void)reloadData {
    _gameNameLabel.text = _model.title;
    _gameNameLabel.font = [UIFont systemFontOfSize:16];
    
    [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [_moreButton setTitleColor:[UIColor colorWithRed:221/255.0 green:119/255.0 blue:20/255.0 alpha:1] forState:UIControlStateNormal];
    _moreButton.hidden = YES;
    
    
    _moreButtonImage.backgroundColor = [UIColor colorWithRed:221/255.0 green:119/255.0 blue:20/255.0 alpha:1];
    [_moreButtonImage setBackgroundImage:[UIImage imageNamed:@"chevron-small-right"] forState:UIControlStateNormal];
    _moreButtonImage.layer.cornerRadius = 7.0;
    _moreButtonImage.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x >= _fourImageView.contentSize.width/2) {
        _moreButtonImage.hidden = NO;
        _moreButton.hidden = NO;
    } else {
        _moreButtonImage.hidden = YES;
        _moreButton.hidden = YES;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
