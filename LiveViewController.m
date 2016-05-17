//
//  LiveViewController.m
//  CSVideo
//
//  Created by qianfeng on 15/10/15.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "LiveViewController.h"
#import "UIView+Common.h"
#import "NewbieModel.h"
#import "LimitDefine.h"
#import <AFNetworking.h>
#import "VideoViewController.h"
#import "LiveTableViewCell.h"
#import <MJRefresh.h>

@interface LiveViewController () <UITableViewDataSource, UITableViewDelegate, LiveTableViewCellDegelate> {
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createTableView];
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

- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20+44, screenWidth(), screenHeight()-20-44-44) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width(_tableView.frame), 10)];
    _tableView.tableHeaderView = aView;
    
    MJRefreshNormalHeader *mjHeard = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData:NO];
    }];
    _tableView.header = mjHeard;
    
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getData:YES];
    }];
    _tableView.footer = mjFooter;
    
    [mjHeard beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return height(_tableView.frame)/4.2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataArray.count%2 == 1) {
        return _dataArray.count/2 + 1;
    }
    return _dataArray.count/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[LiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.delegate = self;
    
    if ((_dataArray.count%2 == 1) && (_dataArray.count/2 == indexPath.row)) {
        cell.dataArray = @[[_dataArray lastObject]];
    } else {
        cell.dataArray = @[_dataArray[indexPath.row*2],_dataArray[indexPath.row*2+1]];
    }

    return  cell;
}

- (void)getData:(BOOL)isMore {
    
    NSInteger page = 20;
    
    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    NSString *url = @"";
    
    if (isMore) {
        if (_dataArray.count%page == 0) {
            page = _dataArray.count + 20;
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            [_tableView.footer endRefreshing];
            return;
        }
    }
    
    if (_isYES) {
        url = [NSString stringWithFormat:liveIdUrl,_number,page,time];
    } else {
        url = [NSString stringWithFormat:liveUrl,page,time];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NewbieModel *gameModel = [[NewbieModel alloc] initWithData:responseObject error:nil];
        
        if (!isMore) {
            [_dataArray removeAllObjects];
        }
        
        NSInteger number = gameModel.data.count;
        
        if (number < _dataArray.count) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            [_tableView.footer endRefreshing];
            return ;
        }
        
        NSLog(@"-(%ld)-",number);
        
        
        NSRange range = NSMakeRange(_dataArray.count, number-_dataArray.count);
        
        NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:range];
        
        
        NSArray *array = [gameModel.data objectsAtIndexes:index];
        
        [_dataArray addObjectsFromArray:array];
        
        
        NSLog(@"(%ld)",_dataArray.count);
        
        [self reloadScrollViewData];
        
        [_tableView reloadData];
        
        isMore == YES ? [_tableView.footer endRefreshing] : [_tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isMore == YES ? [_tableView.footer endRefreshing] : [_tableView.header endRefreshing];
    }];
}

- (void)reloadScrollViewData {
    
    if (_dataArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂无直播间开启" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}

- (void)ViewAction:(NSString *)url {
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = url;
    videoView.modalTransitionStyle = UIModalPresentationFormSheet;
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
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
