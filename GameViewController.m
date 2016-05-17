//
//  GameViewController.m
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "GameViewController.h"
#import "UIView+Common.h"
#import <AFNetworking.h>
#import "LimitDefine.h"
#import "CSGameModel.h"
#import "LiveViewController.h"
#import <UIImageView+WebCache.h>

@interface GameViewController () <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    NSMutableArray *_dataArray;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createScrollView];
    [self getData];
    self.title = @"栏目";
}

- (void)createScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20+44, screenWidth(), screenHeight()-20-44-44)];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

- (void)getData {
    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",gameUrl,time];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CSGameModel *gameModel = [[CSGameModel alloc] initWithData:responseObject error:nil];
        
        [_dataArray addObjectsFromArray:gameModel.data];
        
        [self reloadScrollViewData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)reloadScrollViewData {
    
    CGFloat buttonWidth = (screenWidth()-10*4)/3;
    CGFloat buttonHeight = (height(_scrollView.frame)-10*3)/3;
    
    NSInteger number = _dataArray.count;
    
    for (int i = 0; i < number; i++) {
        
        CSGameDataModel *dataModel = _dataArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(buttonWidth+10)*(i%3), 10+(buttonHeight+10)*(i/3), buttonWidth, buttonHeight-21)];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.game_src] placeholderImage:nil];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView), width(imageView.frame), 20)];
        nameLabel.text = dataModel.game_name;
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [_scrollView addSubview:nameLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(nameLabel), width(imageView.frame), 1)];
        lineLabel.backgroundColor = [UIColor orangeColor];
        [_scrollView addSubview:lineLabel];
        
        
        [_scrollView addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10+(buttonWidth+10)*(i%3), 10+(buttonHeight+10)*(i/3), buttonWidth, buttonHeight);
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000+i;
        [_scrollView addSubview:button];
    }
    
    NSInteger index = number/3;
    
    if (number%3) {
        index = index+1;
    }
    
    
    
    _scrollView.contentSize = CGSizeMake(screenWidth(), (buttonHeight+10)*index+10);
}

- (void)buttonAction:(UIButton *)button {
    
    NSInteger btnTag = button.tag-1000;
    
    CSGameDataModel *model = _dataArray[btnTag];
    
    LiveViewController *liveView = [LiveViewController new];
    liveView.isYES = YES;
    liveView.number = model.cate_id;
    liveView.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:liveView animated:YES];
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
