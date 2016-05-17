//
//  ViewController.m
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "CSChannelViewController.h"
#import "LimitDefine.h"
#import <AFNetworking.h>
#import "CSScrollViewModel.h"
#import "NewbieModel.h"
#import "CSChannelModel.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>
#import "CSChannelTableViewCell.h"
#import "LiveViewController.h"
#import "VideoViewController.h"
#import <MJRefresh.h>

@interface CSChannelViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CSChannelDelegate> {
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    NSMutableArray *_dataScrollArray;
    NSMutableArray *_newDataScrollArray;
    UIScrollView *_bigScrollView;
    UIScrollView *_smallScrollView;
    UIPageControl *_pageControl;
}

@end

@implementation CSChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    _dataArray = [NSMutableArray array];
    _dataScrollArray = [NSMutableArray array];
    _newDataScrollArray = [NSMutableArray array];
    [self createSmallScrollView];
    [self createTableView];
    [self createBigScrollView];
    
    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reloadButton.frame = CGRectMake((screenWidth()-40)/2, 2, 40, 40);
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"topButtonH"] forState:UIControlStateNormal];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"topButton"] forState:UIControlStateHighlighted];
    [reloadButton addTarget:self action:@selector(reloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:reloadButton];
}

- (void)reloadButtonClick:(UIButton *)button {
    [_tableView.header beginRefreshing];
}

#pragma mark -
#pragma mark - 创建 大的scrollView
- (void)createBigScrollView {
    UIView *bigBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth(), screenWidth()/2+screenWidth()/2.8+30)];
    
    _bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth(), screenWidth()/2)];
    _bigScrollView.delegate = self;
    _bigScrollView.contentSize = CGSizeMake(screenWidth()*8, screenWidth()/2);
    _bigScrollView.pagingEnabled = YES;
    _bigScrollView.showsHorizontalScrollIndicator = NO;
    _bigScrollView.showsVerticalScrollIndicator = NO;
    [bigBackgroundView addSubview:_bigScrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenWidth()-120, maxY(_bigScrollView)-26, 20*6, 26)];
    _pageControl.numberOfPages = 6;
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.4];
    [bigBackgroundView addSubview:_pageControl];
    
    //小的 ScrollView
    UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, maxY(_bigScrollView), screenWidth(), screenWidth()/2.8+30)];
    
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 6, 18)];
    colorLabel.backgroundColor = [UIColor orangeColor];
    colorLabel.layer.cornerRadius = 2.0;
    colorLabel.clipsToBounds = YES;
    [smallView addSubview:colorLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxX(colorLabel)+7, 10, screenWidth()-30, 20)];
    titleLabel.text = @"新秀推荐";
    titleLabel.font = [UIFont systemFontOfSize:16];
    [smallView addSubview:titleLabel];
    
    UILabel *linesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, maxY(_smallScrollView)-5, screenWidth(), 1)];
    linesLabel.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    [smallView addSubview:linesLabel];
    
    [smallView addSubview:_smallScrollView];
    
    [bigBackgroundView addSubview:smallView];
    
    _tableView.tableHeaderView = bigBackgroundView;
}

- (void)createSmallScrollView {
    _smallScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, screenWidth(), screenWidth()/2.8)];
    _smallScrollView.delegate = self;
    _smallScrollView.showsHorizontalScrollIndicator = NO;
    _smallScrollView.showsVerticalScrollIndicator = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _bigScrollView) {
        NSInteger index = scrollView.contentOffset.x/width(_bigScrollView.frame);
        _pageControl.currentPage = index-1;
        if (scrollView.contentOffset.x <= 0) {
            _bigScrollView.contentOffset = CGPointMake(width(_bigScrollView.frame)*6, 0);
            _pageControl.currentPage = 5;
        }
        
        if (scrollView.contentOffset.x >= width(_bigScrollView.frame)*7) {
            _bigScrollView.contentOffset = CGPointMake(width(_bigScrollView.frame), 0);
            _pageControl.currentPage = 0;
        }
    }
}

#pragma mark -
#pragma mark - 获取数据
- (void)getData {

    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",channelScrollUrl,time];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CSScrollViewModel *scrollModel = [[CSScrollViewModel alloc] initWithData:responseObject error:nil];
        [_dataScrollArray removeAllObjects];
        [_dataScrollArray addObjectsFromArray:scrollModel.data];
        
        [self reloadBigScrollData];
        [_tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView.header endRefreshing];
    }];
    
    url = [NSString stringWithFormat:@"%@%@",newbieUrl,time];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NewbieModel *newbieModel = [[NewbieModel alloc] initWithData:responseObject error:nil];
        [_newDataScrollArray removeAllObjects];
        [_newDataScrollArray addObjectsFromArray:newbieModel.data];
        
        [self reloadSmallScrollData];
        [_tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView.header endRefreshing];
    }];
    
    url = [NSString stringWithFormat:@"%@%@",channelUrl,time];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CSChannelModel *channeModel = [[CSChannelModel alloc] initWithData:responseObject error:nil];
        
        [_dataArray removeAllObjects];
        [_dataArray addObjectsFromArray:channeModel.data];
        
        [_tableView reloadData];
        [_tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView.header endRefreshing];
    }];
    
}

- (void)reloadBigScrollData {
    CSScrollViewDataModel *dataModel = [_dataScrollArray lastObject];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth(), height(_bigScrollView.frame))];
    [_bigScrollView addSubview:imageView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.pic_url] placeholderImage:nil];
    UILabel *textLable = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-26, screenWidth(), 26)];
    textLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    textLable.text = [NSString stringWithFormat:@"   %@",dataModel.title];
    textLable.textColor = [UIColor whiteColor];
    textLable.font = [UIFont systemFontOfSize:14];
    [_bigScrollView addSubview:textLable];
    
    for (id obj in [_bigScrollView subviews]) {
        [obj removeFromSuperview];
    }
    
    for (int i = 0; i < 6; i++) {
        CSScrollViewDataModel *dataModel = _dataScrollArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth()*(i+1), 0, screenWidth(), height(_bigScrollView.frame))];
        imageView.tag = 1000+i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigTapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [_bigScrollView addSubview:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.pic_url] placeholderImage:nil];
        
        UILabel *textLable = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-26, screenWidth(), 26)];
        textLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        textLable.text = [NSString stringWithFormat:@"   %@",dataModel.title];
        textLable.textColor = [UIColor whiteColor];
        textLable.font = [UIFont systemFontOfSize:14];
        [_bigScrollView addSubview:textLable];
    }
    
    dataModel = [_dataScrollArray firstObject];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth()*7, 0, screenWidth(), height(_bigScrollView.frame))];
    [_bigScrollView addSubview:imageView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.pic_url] placeholderImage:nil];
    textLable = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)-26, screenWidth(), 26)];
    textLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    textLable.text = [NSString stringWithFormat:@"   %@",dataModel.title];
    textLable.textColor = [UIColor whiteColor];
    textLable.font = [UIFont systemFontOfSize:14];
    [_bigScrollView addSubview:textLable];
    
    _bigScrollView.contentOffset = CGPointMake(screenWidth(), 0);
}

- (void)reloadSmallScrollData {
    NSInteger num = _newDataScrollArray.count;
    
    CGFloat viewWidth = (screenWidth()-10*5)/4;
    
    for (id obj in [_smallScrollView subviews]) {
        [obj removeFromSuperview];
    }
    
    for (int i = 0; i < num; i++) {
        
        CSDateModel *dataModel = _newDataScrollArray[i];
        
        NSString *url = [NSString stringWithFormat:iconNewBieUrl,dataModel.owner_uid];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+(10+viewWidth)*i, 5, viewWidth, viewWidth)];
        imageView.layer.cornerRadius = viewWidth/2;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = 1000+i;
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallTapAction:)];
        [imageView addGestureRecognizer:tap];
        
        [_smallScrollView addSubview:imageView];
        
        UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(minX(imageView), maxY(imageView)+5, width(imageView.frame), 15)];
        nickName.text = dataModel.nickname;
        nickName.textAlignment = NSTextAlignmentCenter;
        nickName.font = [UIFont systemFontOfSize:13];
        [_smallScrollView addSubview:nickName];
        
        UILabel *gameName = [[UILabel alloc] initWithFrame:CGRectMake(minX(nickName), maxY(nickName), width(nickName.frame), 12)];
        gameName.text = dataModel.game_name;
        gameName.textAlignment = NSTextAlignmentCenter;
        gameName.font = [UIFont systemFontOfSize:10];
        gameName.textColor = [UIColor grayColor];
        [_smallScrollView addSubview:gameName];
        
    }
    _smallScrollView.contentSize = CGSizeMake(10+(10+viewWidth)*_newDataScrollArray.count, height(_smallScrollView.frame));
}

- (void)bigTapAction:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 1000;
    
    CSScrollViewDataModel *model = _dataScrollArray[tag];
    
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = model.room_id;
    videoView.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
}

- (void)smallTapAction:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 1000;
    
    CSDateModel *model = _newDataScrollArray[tag];
    
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = model.room_id;
    videoView.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark - 创建 TableView
- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20+44, screenWidth(), screenHeight()-20-44-44) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    MJRefreshNormalHeader *mjHeard = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    _tableView.header = mjHeard;
    
    [_tableView.header beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    CSChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CSChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _dataArray[indexPath.row];
    
    return  cell;
}

- (void)ViewAction:(NSString *)url {
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = url;
    videoView.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
}

- (void)ButtonAction:(NSString *)cate_id {
    LiveViewController *liveView = [LiveViewController new];
    liveView.isYES = YES;
    liveView.number = cate_id;
    liveView.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:liveView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (width(self.view.frame)-20)/3+40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
