//
//  VideoViewController.m
//  KS3PlayerDemo
//
//  Created by Blues on 15/3/18.
//  Copyright (c) 2015年 KSY. All rights reserved.
//

#import "VideoViewController.h"
#import "MediaControlViewController.h"
#import "KSYDefine.h"
#import "MediaControlView.h"
#import "LimitDefine.h"
#import <AFNetworking.h>
#import "CSGameDetailModel.h"
#import "ThemeManager.h"
#import "UIView+Common.h"
#import <UIImageView+WebCache.h>
#import "JWCache.h"
#import "NetWorkType.h"
#import "NewbieModel.h"

@interface VideoViewController () <UIAlertViewDelegate> {
    CSGameDetailDataModel *_dataModel;
    NSData *_data;
    UIButton *_exitButton;
    UIView *_bodyView;
    UIActivityIndicatorView *_acIndicatorView;
    UIImageView *_moonImageView;
    
}

@property (nonatomic, strong) KSYPlayer *player;
@property (nonatomic) CGRect previousBounds;

@end

@implementation VideoViewController{
    MediaControlViewController *_mediaControlViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isCycleplay = YES;
    _mediaControlViewController.dataArray = [NSMutableArray array];
    _beforeOrientation = UIDeviceOrientationPortrait;
    _pauseInBackground = YES;
    _motionInterfaceOrientation = UIInterfaceOrientationMaskLandscape;
    self.view.backgroundColor = [UIColor whiteColor];
    // **** 测试改变URL
    
    _moonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _moonImageView.center = self.view.center;
    
    [self.view addSubview:_moonImageView];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    
    for (int i = 1; i <= 7; i++) {
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"sandyMoon00%d@2x",i] ofType:@"png"];
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        [imageArray addObject:image];
    }
    
    _moonImageView.animationImages = imageArray;
    
    _moonImageView.animationDuration = 1;
    
    [_moonImageView startAnimating];
    
    [self createData];
    
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(NetWork:) userInfo:nil repeats:YES];
//    [_timer setFireDate:[NSDate distant];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status != AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"没有WIFI了");
            [self pause];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络部是WIFI" delegate:self cancelButtonTitle:nil otherButtonTitles:@"继续播放",@"停止播放", nil];
            [alertView show];
        }
        
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    [self initPlayer];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        NSLog(@"继续");
        [self play];
        
    } else if (buttonIndex == 1){
    
        [self exitButtonClick:nil];
        
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setModel:(CSGameDetailDataModel *)model {
    _dataModel = model;
}

- (void)createData {
    
    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:roomUrl,_room_id,time];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CSGameDetailModel *newbieModel = [[CSGameDetailModel alloc] initWithData:responseObject error:nil];
        
        _dataModel = newbieModel.data;
        
        _data = responseObject;
        
        [_moonImageView stopAnimating];
        
        _videoUrl = [NSURL URLWithString:_dataModel.hls_url];
        
        [self initPlayer];
        [self createBodyView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [_moonImageView stopAnimating];
        
    }];
}

- (void)createBodyView {
    _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, maxY(_player.videoView), screenWidth(), screenHeight()-width(_player.videoView.frame))];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth()+2, 100)];
    
    titleView.layer.borderWidth = 1.0;
    titleView.layer.backgroundColor = [[UIColor grayColor] CGColor];
    
    titleView.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.5];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, height(titleView.frame)-20, height(titleView.frame)-20)];
    imageView.layer.cornerRadius = width(imageView.frame)/2;
    imageView.clipsToBounds = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:_dataModel.owner_avatar] placeholderImage:nil];
    [titleView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxX(imageView)+10, 13, width(titleView.frame)-width(imageView.frame), 20)];
    nameLabel.text = _dataModel.nickname;
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleView addSubview:nameLabel];
    
    UILabel *gameNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(minX(nameLabel), maxY(nameLabel)+10, 75, 15)];
    gameNameLabel.text = @"正在直播:";
    gameNameLabel.textColor = [UIColor grayColor];
    gameNameLabel.font = [UIFont systemFontOfSize:15];
    [titleView addSubview:gameNameLabel];
    
    UILabel *gameName = [[UILabel alloc] initWithFrame:CGRectMake(maxX(gameNameLabel), minY(gameNameLabel), width(titleView.frame)-maxX(gameNameLabel), 15)];
    gameName.text = _dataModel.game_name;
    gameName.textColor = [UIColor orangeColor];
    gameName.font = [UIFont systemFontOfSize:15];
    [titleView addSubview:gameName];
    
    UIImageView *littleimageView = [[UIImageView alloc] initWithFrame:CGRectMake(minX(nameLabel), maxY(gameName)+10, 20, 20)];
    littleimageView.image = [UIImage imageNamed:@"feather"];
    [titleView addSubview:littleimageView];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxX(littleimageView), minY(littleimageView), width(gameNameLabel.frame), 20)];
    numberLabel.text = _dataModel.owner_weight;
    numberLabel.textColor = [UIColor grayColor];
    numberLabel.font = [UIFont systemFontOfSize:15];
    [titleView addSubview:numberLabel];
    
    
    
    UILabel *online = [[UILabel alloc] initWithFrame:CGRectMake(maxX(numberLabel)+20, minY(numberLabel), 40, height(numberLabel.frame))];
    online.text = @"观看:";
    online.textColor = [UIColor grayColor];
    online.font = [UIFont systemFontOfSize:15];
    [titleView addSubview:online];
    
    UILabel *onlineNumber = [[UILabel alloc] initWithFrame:CGRectMake(maxX(online), minY(numberLabel), (width(titleView.frame)-maxX(numberLabel)-20)/2, 20)];
    NSInteger onlines = [_dataModel.online integerValue];
    if (onlines > 10000) {
        float onlineNumbers = onlines/10000.0;
        onlineNumber.text = [NSString stringWithFormat:@"%.1f万",onlineNumbers];
    } else {
        onlineNumber.text = _dataModel.online;
    }
    
    onlineNumber.textColor = [UIColor orangeColor];
    onlineNumber.font = [UIFont systemFontOfSize:15];
    [titleView addSubview:onlineNumber];
    
    [_bodyView addSubview:titleView];
    
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, maxY(titleView)+20, 7, 15)];
    colorLabel.backgroundColor = [UIColor orangeColor];
    colorLabel.layer.cornerRadius = 2.0;
    colorLabel.clipsToBounds = YES;
    [_bodyView addSubview:colorLabel];
    
    UILabel *GGLabel = [[UILabel alloc] initWithFrame:CGRectMake(maxX(colorLabel)+5, minY(colorLabel), 100, 15)];
    GGLabel.text = @"直播公告";
    GGLabel.font = [UIFont boldSystemFontOfSize:15];
    [_bodyView addSubview:GGLabel];
    
    UITextView *textLabel = [[UITextView alloc] initWithFrame:CGRectMake(minX(colorLabel), maxY(GGLabel), screenWidth()-20, height(_bodyView.frame)-maxY(colorLabel))];
    textLabel.editable = NO;
    textLabel.text = _dataModel.show_details;
    textLabel.textColor = [UIColor grayColor];
    [_bodyView addSubview:textLabel];
    
    [self.view addSubview:_bodyView];
    
    [JWCache cacheDirectory];
    [JWCache setObject:_data forKey:_dataModel.room_id];
    
    [self createTableViewData];
    
}

- (void)createTableViewData {
    
    NSString *time = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSInteger page = 20;
    NSString *url = [NSString stringWithFormat:liveIdUrl,_dataModel.cate_id,page,time];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NewbieModel *newbieModel = [[NewbieModel alloc] initWithData:responseObject error:nil];
        [_mediaControlViewController.dataArray addObjectsFromArray:newbieModel.data];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)initPlayer {
    _player = [[KSYPlayer alloc] initWithMURL:_videoUrl withOptions:nil];
    _player.shouldAutoplay = YES; ///+++++++ update
    _player.videoView.frame = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMinY(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2);
    _player.videoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_player.videoView];
    
    _mediaControlViewController = [[MediaControlViewController alloc] init];
    _mediaControlViewController.delegate = self;
    [self.view addSubview:_mediaControlViewController.view];
    [_player setScalingMode:MPMovieScalingModeAspectFit];
    
    [_player prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self registerApplicationObservers];
    [_player setAnalyzeduration:500];
    
    _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _exitButton.frame = CGRectMake(0, 0, 25, 25);
    
    UIImage *image = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_back_normal"];
    
    [_exitButton setBackgroundImage:image forState:UIControlStateNormal];
    [_exitButton addTarget:self action:@selector(exitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _exitButton.hidden = NO;
    
    UIView *topView = [self.view viewWithTag:132];
    [topView addSubview:_exitButton];
    
}

- (void)exitButtonClick:(UIButton *)button {
    
    [self shutdown];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
}

- (void)clickNativeBtn:(id)sender
{
//    _videoUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"a" ofType:@"mp4"]];
    _videoUrl = [NSURL URLWithString:@"http://hls3.douyutv.com/live/16101rWrkm5DLpsk/playlist.m3u8?wsSecret=2441aa81a0589d558fa8ef9cf4fa535d&wsTime=1444912934"];
    [self initPlayer];
    
    UIView *demoView = [(UIButton *)sender superview];
    [demoView removeFromSuperview];
}

- (void)adjustVideoViewScale {
    CGFloat width = _player.videoView.frame.size.width;
    CGFloat height = _player.videoView.frame.size.height;
    CGFloat x = _player.videoView.frame.origin.x;
    CGFloat y = _player.videoView.frame.origin.y;
    if (width > height * W16H9Scale) {
        x = (width - (height * W16H9Scale)) / 2;
        width = height * W16H9Scale;
    }
    else {
        y = (height - (width / W16H9Scale)) / 2;
        height = width / W16H9Scale;
    }
    _player.videoView.frame = CGRectMake(x, y, width, height);
}

- (void)registerApplicationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)unregisterApplicationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)applicationWillEnterForeground
{
}

- (void)applicationDidBecomeActive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_player isPlaying]) {
            [self play];
        }
    });
}

- (void)applicationWillResignActive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_pauseInBackground && [_player isPlaying]) {
            [self pause];
        }
    });
}

- (void)applicationDidEnterBackground
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_pauseInBackground && [_player isPlaying]) {
            [self pause];
        }
    });
}

- (void)applicationWillTerminate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_pauseInBackground && [_player isPlaying]) {
            [self pause];
        }
    });
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (self.deviceOrientation!=orientation) {
        if (orientation == UIDeviceOrientationPortrait)
        {
            self.deviceOrientation = orientation;
            
            [self minimizeVideo];
        }
        else if (orientation == UIDeviceOrientationLandscapeRight||orientation == UIDeviceOrientationLandscapeLeft)
        {
            self.deviceOrientation = orientation;
            
            [self launchFullScreen];
        }
        [_mediaControlViewController reSetLoadingViewFrame];
    }
}

- (void)showBodyView {
    _bodyView.hidden = NO;
}

- (void)launchFullScreen
{
    _exitButton.hidden = YES;
    _bodyView.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (!_fullScreenModeToggled) {
        _fullScreenModeToggled = YES;
        [self launchFullScreenWhileUnAlwaysFullscreen];
    }
    else {
        [self launchFullScreenWhileFullScreenModeToggled];
    }
     [_mediaControlViewController reSetLoadingViewFrame];
}

- (void)minimizeVideo
{
    _exitButton.hidden = NO;
    UIView *aView = [self.view viewWithTag:133];
    [aView removeFromSuperview];
    
    [self performSelector:@selector(showBodyView) withObject:nil afterDelay:0.3];
    if (_fullScreenModeToggled) {
        _fullScreenModeToggled = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationFade];
        [self minimizeVideoWhileUnAlwaysFullScreen];
    }
     [_mediaControlViewController reSetLoadingViewFrame];
}

- (void)launchFullScreenWhileFullScreenModeToggled{
    if ([UIApplication sharedApplication].statusBarOrientation == (UIInterfaceOrientation)[[UIDevice currentDevice] orientation]) {
        return;
    }
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (!KSYSYS_OS_IOS8) {
        [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
    }
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0f
                        options:(UIViewAnimationOptions)UIViewAnimationCurveLinear
                     animations:^{
                         float deviceHeight = [[UIScreen mainScreen] bounds].size.height;
                         float deviceWidth = [[UIScreen mainScreen] bounds].size.width;
                         UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
                         CGFloat angle =((orientation==UIDeviceOrientationLandscapeLeft)?(-M_PI):M_PI);
                         
                         _player.videoView.transform = CGAffineTransformRotate(_player.videoView.transform, angle);
                         _mediaControlViewController.view.transform = CGAffineTransformRotate(_mediaControlViewController.view.transform, angle);
                         
                         [_player.videoView setCenter:CGPointMake(deviceWidth/2, deviceHeight/2)];
                         _player.videoView.bounds = CGRectMake(0, 0, deviceHeight, deviceWidth);
                         [(MediaControlView *)_mediaControlViewController.view updateSubviewsLocation];
                     }
                     completion:^(BOOL finished) {
                         _beforeOrientation = [UIDevice currentDevice].orientation;
                     }];
}

- (void)launchFullScreenWhileUnAlwaysFullscreen
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeRight) {
        if (!KSYSYS_OS_IOS8) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
        }
        else {
        }
    }
    else {
        if (!KSYSYS_OS_IOS8) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            
        }
        else {
        }
    }
    self.previousBounds = _player.videoView.frame;
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionLayoutSubviews//UIViewAnimationCurveLinear
                     animations:^{
                         float deviceHeight = KSYSYS_OS_IOS8?[[UIScreen mainScreen] bounds].size.width:[[UIScreen mainScreen] bounds].size.height;
                         float deviceWidth = KSYSYS_OS_IOS8?[[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width;
                         
                         deviceHeight = [[UIScreen mainScreen] bounds].size.height;
                         deviceWidth = [UIScreen mainScreen].bounds.size.width;
                         if (orientation == UIDeviceOrientationLandscapeRight) {
                             _player.videoView.transform = CGAffineTransformRotate(_player.videoView.transform, -M_PI_2);
                             _mediaControlViewController.view.transform = CGAffineTransformRotate( _mediaControlViewController.view.transform, -M_PI_2);
                             MediaControlView *mediaControlView = (MediaControlView *)(_mediaControlViewController.view);
                             mediaControlView.center= _player.videoView.center;
                             
                         }else{
                             _player.videoView.transform = CGAffineTransformRotate(_player.videoView.transform, M_PI_2);
                             _mediaControlViewController.view.transform = CGAffineTransformRotate( _mediaControlViewController.view.transform, M_PI_2);
                             MediaControlView *mediaControlView = (MediaControlView *)(_mediaControlViewController.view);
                             mediaControlView.center= _player.videoView.center;
                         }
                         
                         if ([UIDevice currentDevice].systemVersion.floatValue < 8 ) {
                             
                             [_player.videoView setCenter:CGPointMake(deviceWidth/2, deviceHeight/2)];
                             _player.videoView.bounds = CGRectMake(0, 0, deviceHeight, deviceWidth);
                             
                             MediaControlView *mediaControlView = (MediaControlView *)(_mediaControlViewController.view);
                             mediaControlView.bounds = _player.videoView.bounds;
                             mediaControlView.center = CGPointMake(deviceWidth/2, deviceHeight/2);
                         }else{
                             [_player.videoView setCenter:CGPointMake(deviceWidth/2, deviceHeight/2)];
                             _player.videoView.bounds = CGRectMake(0, 0, deviceHeight, deviceWidth);
                             
                             MediaControlView *mediaControlView = (MediaControlView *)(_mediaControlViewController.view);
                             mediaControlView.center = CGPointMake(deviceWidth/2, deviceHeight/2);
                             mediaControlView.bounds = CGRectMake(0, 0, deviceHeight, deviceWidth);
                         }
                         [(MediaControlView *)_mediaControlViewController.view updateSubviewsLocation];
                     }
                     completion:^(BOOL finished) {
                         _beforeOrientation = [UIDevice currentDevice].orientation;
                     }
     ];
}

- (void)minimizeVideoWhileUnAlwaysFullScreen{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _player.videoView.transform = CGAffineTransformIdentity;
                         _mediaControlViewController.view.transform = CGAffineTransformIdentity;
                         _player.videoView.frame = self.previousBounds;
                         MediaControlView *mediaControlView = (MediaControlView *)(_mediaControlViewController.view);
                         mediaControlView.bounds = _player.videoView.bounds;
                         mediaControlView.center = CGPointMake(mediaControlView.bounds.size.width / 2, mediaControlView.bounds.size.height/2);
                         
                         [(MediaControlView *)_mediaControlViewController.view updateSubviewsLocation];
                     }
                     completion:^(BOOL success){
                         _beforeOrientation = [UIDevice currentDevice].orientation;
                         
                     }];
}

#pragma mark - minimize Exchange

- (void)minimizeVideoWhileIsAlwaysFullScreen{
    
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _player.videoView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2);
                     }
                     completion:^(BOOL success){
                         _beforeOrientation = [UIDevice currentDevice].orientation;
                     }];
}

- (void)getVideoState
{
    //    //NSLog(@"[_player state] = = =%d",[_player state]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (KSYPlayer *)player {
    return _player;
}

#pragma mark - KSYMediaPlayDelegate

- (void)play {
    [_player play];
}

- (void)pause {
    [_player pause];
}

- (void)stop {
    [_player stop];
}

- (BOOL)isPlaying {
    return [_player isPlaying];
}

- (void)shutdown {
    [_player shutdown];
}

- (void)seekProgress:(CGFloat)position {
    [_player setCurrentPlaybackTime:position];
}

- (void)setVideoQuality:(KSYVideoQuality)videoQuality {
    //NSLog(@"set video quality");
}

- (void)setVideoScale:(KSYVideoScale)videoScale {
    CGRect videoRect = [[UIScreen mainScreen] bounds];
    NSInteger scaleW = 16;
    NSInteger scaleH = 9;
    switch (videoScale) {
        case kKSYVideo16W9H:
            scaleW = 16;
            scaleH = 9;
            break;
        case kKSYVideo4W3H:
            scaleW = 4;
            scaleH = 3;
            break;
        default:
            break;
    }
    if (videoRect.size.height >= videoRect.size.width * scaleW / scaleH) {
        videoRect.origin.x = 0;
        videoRect.origin.y = (videoRect.size.height - videoRect.size.width * scaleW / scaleH) / 2;
        videoRect.size.height = videoRect.size.width * scaleW / scaleH;
    }
    else {
        videoRect.origin.x = (videoRect.size.width - videoRect.size.height * scaleH / scaleW) / 2;
        videoRect.origin.y = 0;
        videoRect.size.width = videoRect.size.height * scaleH / scaleW;
    }
    _player.videoView.frame = videoRect;
}

- (void)setAudioAmplify:(CGFloat)amplify {
    [_player setAudioAmplify:amplify];
}

- (void)setCycleplay:(BOOL)isCycleplay {
    
}

#pragma mark - UIInterface layout subviews

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}
- (void)dealloc
{
    [self unregisterApplicationObservers];
}

@end
