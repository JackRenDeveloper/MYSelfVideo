//
//  CollectViewController.m
//  CS_Doctor
//
//  Created by qianfeng on 15/10/11.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "CollectViewController.h"
#import "JWCache.h"
#import "UIView+Common.h"
#import "CSGameDetailModel.h"
#import "NewbieModel.h"
#import <UIImageView+WebCache.h>
#import "VideoViewController.h"

@interface CollectViewController () {
    UIScrollView *_scrollView;
//    UITableView *_tableView;
    NSMutableArray *_dataArray;
    NSArray *_keyArray;
    NSMutableArray *_buttonArray;
    NSMutableArray *_littleButtonArray;
    NSMutableArray *_removeDataArray;
}

@end

@implementation CollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    _buttonArray = [NSMutableArray array];
    _littleButtonArray = [NSMutableArray array];
    _removeDataArray = [NSMutableArray array];
    [self createScrollView];
    [self setCacheData];
    [self createDownView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth()-100)/2, 20, 100, 44)];
    titleLabel.text = @"我的足迹";
    titleLabel.textColor = [UIColor colorWithRed:224/255.0 green:89/255.0 blue:43/255.0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:titleLabel];
}

- (void)createScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20+44, screenWidth(), screenHeight()-20-44-44)];
//    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

- (void)reloadScrollViewData {
    
    CGFloat buttonWidth = (screenWidth()-30)/2;
    CGFloat buttonHeight = height(_scrollView.frame)/4.2;
    
    NSInteger number = _dataArray.count;
    
    for (int i = 0; i < number; i++) {
        
        CSDateModel *_model = _dataArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(buttonWidth+10)*(i%2), 10+(buttonHeight+10)*(i/2), buttonWidth, buttonHeight-36)];
        
        imageView.tag = 1000+i;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ViewAction:)];
        [imageView addGestureRecognizer:tap];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:_model.room_src] placeholderImage:[UIImage imageNamed:@"scroll_bgImage"]];
        
        [_scrollView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView), width(imageView.frame), 30)];
        nameLabel.text = _model.room_name;
        nameLabel.font = [UIFont systemFontOfSize:13];
        [_scrollView addSubview:nameLabel];
        
        UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-14, width(imageView.frame), 14)];
        linView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [_scrollView addSubview:linView];
        
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
        
        
        UIButton *bigButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bigButton.frame = CGRectMake(minX(imageView), minY(imageView), buttonWidth, buttonHeight);
        [bigButton addTarget:self action:@selector(rmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        bigButton.tag = i;
        bigButton.hidden = YES;
        [_scrollView addSubview:bigButton];
        [_buttonArray addObject:bigButton];
        
        UIButton *littleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        littleButton.frame = CGRectMake(maxX(bigButton)-15, minY(bigButton)-10, 20, 20);
        [littleButton setImage:[UIImage imageNamed:@"radio-unchecked"] forState:UIControlStateNormal];
        [littleButton setImage:[UIImage imageNamed:@"radio-checked"] forState:UIControlStateSelected];
        littleButton.hidden = YES;
        littleButton.tag = i;
        [_scrollView addSubview:littleButton];
        [_littleButtonArray addObject:littleButton];
        
    }
    
    NSInteger index = number/2;
    
    if (number%2) {
        index = index+1;
    }
    
    
    
    _scrollView.contentSize = CGSizeMake(screenWidth(), (buttonHeight+10)*index+10);
}

- (void)createDownView {
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, height(self.view.frame)-44, width(self.view.frame), 44)];
    downView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:downView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 10, 24, 24);
    [button setImage:[UIImage imageNamed:@"arrow-bold-left"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:button];
    
    
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    removeButton.frame = CGRectMake(screenWidth()-20-24, 10, 24, 24);
    [removeButton addTarget:self action:@selector(removeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setBackgroundImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
    [downView addSubview:removeButton];
}

- (void)removeButtonClick:(UIButton *)button {
    if (!button.selected) {
        [self createButton];
    } else {
        [self removeButton];
    }
    button.selected = !button.selected;
}

- (void)createButton {
    for (UIButton *button in _buttonArray) {
        button.hidden = NO;
    }
    for (UIButton *button in _littleButtonArray) {
        button.hidden = NO;
    }
}

- (void)rmButtonClick:(UIButton *)button {
    
    NSInteger index = button.tag;
    
    UIButton *litButton = _littleButtonArray[index];
    litButton.selected = !litButton.selected;
    
}

- (void)removeButton {
    
    for (UIButton *btn in _buttonArray) {
        btn.hidden = YES;
    }
    for (UIButton *btn in _littleButtonArray) {
        
        if (btn.selected) {
            
            CSDateModel *dataModel = _dataArray[btn.tag];
            
            [JWCache delateObjectForKey:dataModel.room_id];
            
        }
        
        btn.hidden = YES;
    }
    [self setCacheData];
}

- (void)buttonClick:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setCacheData {
    for (id obj in [_scrollView subviews]) {
        [obj removeFromSuperview];
    }
    [_dataArray removeAllObjects];
    [_buttonArray removeAllObjects];
    [_littleButtonArray removeAllObjects];
    
    [JWCache cacheDirectory];
    _keyArray = [JWCache giveMeAllKey];
    
    if (_keyArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您没有观看过直播!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        return;
    }
    
    for (NSString *strKey in _keyArray) {
        NSData *responseObject = [JWCache objectForKey:strKey];
        CSGameDetailModel *dataModel = [[CSGameDetailModel alloc] initWithData:responseObject error:nil];
        [_dataArray addObject:dataModel.data];
    }
    [self reloadScrollViewData];
}

- (void)ViewAction:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag - 1000;
    
    CSDateModel *dataModel = _dataArray[index];
    
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = dataModel.room_id;
    videoView.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
}

//- (void)createTableView {
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20+44, width(self.view.frame), height(self.view.frame)-104) style:UITableViewStylePlain];
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    
//    _tableView.tableFooterView = [UIView new];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    
//    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width(_tableView.frame), 10)];
//    _tableView.tableHeaderView = aView;
//    
//    [self.view addSubview:_tableView];
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return height(_tableView.frame)/4.2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (_dataArray.count%2 == 1) {
//        return _dataArray.count/2 + 1;
//    }
//    return _dataArray.count/2;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *identifier = @"identifier";
//    LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[LiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//    
//    cell.delegate = self;
//    
//    if ((_dataArray.count%2 == 1) && (_dataArray.count/2 == indexPath.row)) {
//        cell.dataArray = @[[_dataArray lastObject]];
//    } else {
//        cell.dataArray = @[_dataArray[indexPath.row*2],_dataArray[indexPath.row*2+1]];
//    }
//    
//    return  cell;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
