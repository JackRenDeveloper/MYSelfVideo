//
//  MyViewController.m
//  CS_Doctor
//
//  Created by qianfeng on 15/10/5.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "MyViewController.h"
#import "UIView+Common.h"
#import "CollectViewController.h"
#import "JWCache.h"

@interface MyViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    UIImageView *_imageView;
    UIButton *_collectButton;
    UILabel *_bodyLabel;
}

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20+44, width(self.view.frame), 195)];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"];
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    [self.view addSubview:_imageView];
    
    [self createButton];
    
    self.title = @"个人中心";
}

- (void)createButton {
    _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectButton.frame = CGRectMake((width(self.view.frame)-150)/2, (height(_imageView.frame)-40)/2+20+44, 150, 40);
    [_collectButton setTitle:@"我的足迹" forState:UIControlStateNormal];
    [_collectButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_collectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _collectButton.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    _collectButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _collectButton.layer.borderWidth = 1.0;
    _collectButton.layer.cornerRadius = 3.0;
    [_collectButton addTarget:self action:@selector(collectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_collectButton];
    
    _bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(_collectButton)-30, maxY(_collectButton)+20, width(_collectButton.frame)+60, 20)];
    _bodyLabel.text = @"点击我的足迹可查看观看记录";
    _bodyLabel.textColor = [UIColor whiteColor];
    _bodyLabel.textAlignment = NSTextAlignmentCenter;
    _bodyLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_bodyLabel];
}

- (void)collectButtonClick:(UIButton *)button {
    CollectViewController *collect = [CollectViewController new];
    collect.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:collect animated:YES completion:^{
        
    }];
}



- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width(self.view.frame), height(self.view.frame)) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView) {
        if (scrollView.contentOffset.y < 0) {
            [UIView animateWithDuration:0.01 animations:^{
                _imageView.frame = CGRectMake(scrollView.contentOffset.y/2, 20+44, width(self.view.frame)-scrollView.contentOffset.y, 195-scrollView.contentOffset.y);
            }];
        } else if (scrollView.contentOffset.y > 0) {
            [UIView animateWithDuration:0.01 animations:^{
                _imageView.frame = CGRectMake(0, 20+44, width(self.view.frame), 195-scrollView.contentOffset.y);
                _collectButton.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y/3*2);
                _bodyLabel.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y/4*3);
            }];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0 || indexPath.row == 3) {
            return 100;
        }
        
        return 50;
    }
    
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        imageView.layer.cornerRadius = 20.0;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"icon"];
        cell.accessoryView = imageView;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = @"峰线直播";
        
        return  cell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"客服邮箱：cs_foolforyou@sina.com";
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 2) {
        
        cell.textLabel.text = @"清除直播纪录";
        cell.textLabel.textColor = [UIColor redColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAllData:)];
        
        [cell addGestureRecognizer:tap];
        
        return cell;
    }
    if (indexPath.section == 1 && indexPath.row == 3) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width(cell.frame), 80)];
        titleLabel.text = @"峰线游戏直播平台提供高清、快捷、流畅的视频直播和游戏赛事直播服务,包含英雄联盟lol直播、穿越火线cf直播、dota2直播、美女直播等各类热门游戏赛事直播和各种名家直播.";
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        cell.accessoryView = titleLabel;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return  cell;
}

- (void)removeAllData:(UITapGestureRecognizer *)tap {
    [JWCache resetCache];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"清除成功!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    
}

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
