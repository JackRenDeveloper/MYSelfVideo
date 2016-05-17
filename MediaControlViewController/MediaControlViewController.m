//
//  MediaControlViewController.m
//  KS3PlayerDemo
//
//  Created by Blues on 15/3/18.
//  Copyright (c) 2015年 KSY. All rights reserved.
//

#import "MediaControlViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"
#import "MediaControlView.h"
#import "MediaControlDefine.h"
#import "ThemeManager.h"
#import "MediaVoiceView.h"
#import "KSYDefine.h"
#import "UIView+Common.h"
#import "CSMediaCell.h"

@interface MediaControlViewController () <UITableViewDataSource, UITableViewDelegate>{
    BOOL _isKSYPlayerPling;
    UIActivityIndicatorView *_indicatorView;
    UILabel *_indicatorLabel;
    BOOL _isPrepared;
}

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat curPosition;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, assign) NSInteger audioAmplify;
@property (nonatomic, assign) CGFloat curVoice;
@property (nonatomic, assign) CGFloat curBrightness;
@property (nonatomic, assign) KSYGestureType gestureType;

@end

@implementation MediaControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // **** player delegate
    _dataArray = [NSMutableArray array];
    KSYPlayer *player = [(VideoViewController *)_delegate player];
    player.delegate = self;
    
    _isActive = YES;
    _isCompleted = NO;
    _isLocked = NO;
    _audioAmplify = 1;
    _gestureType = kKSYUnknown;
    
    // **** 主题包管理
    ThemeManager *themeManager = [ThemeManager sharedInstance];
//    [themeManager changeTheme:@"blue"];
//    [themeManager changeTheme:@"green"];
//    [themeManager changeTheme:@"orange"];
//    [themeManager changeTheme:@"pink"];
    [themeManager changeTheme:@"red"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect mediaControlRect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height / 2);
    MediaControlView *mediaControlView = [[MediaControlView alloc] initWithFrame:mediaControlRect];
    self.view = mediaControlView;
    mediaControlView.controller = self;
    
    [self performSelector:@selector(hideAllControls) withObject:nil afterDelay:3.0];
    [self refreshControl];
    
    UIButton *playBtn = (UIButton *)[self.view viewWithTag:kBarPlayBtnTag];
    UIImage *playImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
    UIImage *playImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_hl"];
    UIImage *pauseImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_pause_normal"];
    UIImage *pauseImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_pause_hl"];
    if (!player.shouldAutoplay) {
        [playBtn setImage:playImg_n forState:UIControlStateNormal];
        [playBtn setImage:playImg_h forState:UIControlStateHighlighted];
        
    }else{
        [playBtn setImage:pauseImg_n forState:UIControlStateNormal];
        [playBtn setImage:pauseImg_h forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshControl {
    UILabel *startLabel = (UILabel *)[self.view viewWithTag:kProgressCurLabelTag];
    UILabel *endLabel = (UILabel *)[self.view viewWithTag:kProgressMaxLabelTag];
    UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
    
    NSInteger duration = (NSInteger)[(VideoViewController *)_delegate player].duration;
    NSInteger position = (NSInteger)[(VideoViewController *)_delegate player].currentPlaybackTime;
    int iMin  = (int)(position / 60);
    int iSec  = (int)(position % 60);
    startLabel.text = [NSString stringWithFormat:@"%02d:%02d/", iMin, iSec];
    if (duration > 0) {
        int iDuraMin  = (int)(duration / 60);
        int iDuraSec  = (int)(duration % 3600 % 60);
        endLabel.text = [NSString stringWithFormat:@"%02d:%02d", iDuraMin, iDuraSec];
        progressSlider.value = position;
        progressSlider.maximumValue = duration;
    }
    else {
        endLabel.text = @"--:--";
        progressSlider.value = 0.0f;
        progressSlider.maximumValue = 1.0f;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshControl) object:nil];
    if (_isActive == YES) {
        [self performSelector:@selector(refreshControl) withObject:nil afterDelay:1.0];
    }
}

#pragma mark - Actions

- (void)clickPlayBtn:(id)sender
{
    if (!_isPrepared) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    UIImage *playImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
    UIImage *paueImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_pause_normal"];
    if ([_delegate respondsToSelector:@selector(isPlaying)] == YES) {
        if ([_delegate isPlaying] == NO && [_delegate respondsToSelector:@selector(play)] == YES) {
            [_delegate play];
            [btn setImage:paueImg forState:UIControlStateNormal];
        }
        else if ([_delegate isPlaying] == YES && [_delegate respondsToSelector:@selector(pause)] == YES) {
            [_delegate pause];
            [btn setImage:playImg forState:UIControlStateNormal];
        }
    }
}

- (void)clickQualityBtn:(id)sender
{
    UIView *qualityView = [self.view viewWithTag:kQualityViewTag];
    UIView *scaleView = [self.view viewWithTag:kScaleViewTag];
    if (qualityView != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            qualityView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [qualityView removeFromSuperview];
        }];
        return ;
    }
    if (scaleView != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            scaleView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [scaleView removeFromSuperview];
        }];
    }
    UIButton *qualityBtn = (UIButton *)sender;
    CGPoint btnLocation = [qualityBtn.superview convertPoint:qualityBtn.frame.origin toView:self.view];
    CGRect rect = CGRectMake(btnLocation.x - 5, btnLocation.y - 120, qualityBtn.frame.size.width + 10, 115);
    qualityView = [[UIView alloc] initWithFrame:rect];
    qualityView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:qualityView];
    qualityView.tag = kQualityViewTag;
    
    UIView *qualityBgView = [[UIView alloc] initWithFrame:qualityView.bounds];
    qualityBgView.backgroundColor = [UIColor blackColor];
    qualityBgView.alpha = 0.6;
    qualityBgView.layer.masksToBounds = YES;
    qualityBgView.layer.cornerRadius = 3;
    [qualityView addSubview:qualityBgView];
    NSArray *arrTitles = @[@"流畅", @"高清", @"超清"];
    for (NSInteger i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:arrTitles[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(5, 5 + 35 * i, rect.size.width - 10, 30);
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        btn.tag = i;
        [btn addTarget:self action:@selector(adjustVideoQuality:) forControlEvents:UIControlEventTouchUpInside];
        [qualityView addSubview:btn];
    }
}

- (void)adjustVideoQuality:(KSYVideoQuality)qualty {
    if ([_delegate respondsToSelector:@selector(setVideoQuality:)] == YES) {
        [_delegate setVideoQuality:qualty];
    }
    UIView *qualityView = [self.view viewWithTag:kQualityViewTag];
    [UIView animateWithDuration:0.3 animations:^{
        qualityView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [qualityView removeFromSuperview];
    }];
}

- (void)progressDidBegin:(id)slider
{
    KSYPlayer *player = [(VideoViewController *)_delegate player];
    _isKSYPlayerPling = player.isPlaying;
    UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot"];
    [(UISlider *)slider setThumbImage:dotImg forState:UIControlStateNormal];
    NSInteger duration = (NSInteger)[(VideoViewController *)_delegate player].duration;
    if (duration > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshControl) object:nil];
        if ([_delegate isPlaying] == YES) {
            _isActive = NO;
            [_delegate pause];
            UIImage *playImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
            UIButton *btn = (UIButton *)[self.view viewWithTag:kBarPlayBtnTag];
            [btn setImage:playImg forState:UIControlStateNormal];
        }
    }
}

- (void)progressChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (!_isPrepared) {
        slider.value = 0.0f;
        return;
    }
    NSInteger duration = (NSInteger)[(VideoViewController *)_delegate player].duration;
    if (duration > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshControl) object:nil];
        UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
        UILabel *startLabel = (UILabel *)[self.view viewWithTag:kProgressCurLabelTag];

        if ([_delegate isPlaying] == YES) {
            _isActive = NO;
            [_delegate pause];
            UIImage *playImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
            UIButton *btn = (UIButton *)[self.view viewWithTag:kBarPlayBtnTag];
            [btn setImage:playImg forState:UIControlStateNormal];
        }
        NSInteger position = progressSlider.value;
        int iMin  = (int)(position / 60);
        int iSec  = (int)(position % 60);
        NSString *strCurTime = [NSString stringWithFormat:@"%02d:%02d/", iMin, iSec];
        startLabel.text = strCurTime;
    }
    else {
        slider.value = 0.0f;
        [self showNotice:@"直播不支持拖拽"];
    }
}

- (void)progressChangeEnd:(id)sender {
    if (!_isPrepared) {
        return;
    }
    
    UISlider *slider = (UISlider *)sender;
    UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot_normal"];
    [slider setThumbImage:dotImg forState:UIControlStateNormal];
    NSInteger duration = (NSInteger)[(VideoViewController *)_delegate player].duration;
    if (duration > 0) {
        if ([_delegate respondsToSelector:@selector(seekProgress:)] == YES) {
            [_delegate seekProgress:slider.value];
        }
    }
    else {
        slider.value = 0.0f;
        //NSLog(@"###########当前是直播状态无法拖拽进度###########");
    }
}

- (void)brightnessChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [[UIScreen mainScreen] setBrightness:slider.value];
}

- (void)brightnessDidBegin:(id)sender {
    UISlider *slider = (UISlider *)sender;
    UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot"];
    [slider setThumbImage:dotImg forState:UIControlStateNormal];
}

- (void)brightnessChangeEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot_normal"];
    [slider setThumbImage:dotImg forState:UIControlStateNormal];
}

- (void)voiceChanged:(id)sender
{
    UISlider *voiceSlider = (UISlider *)sender;
    MPMusicPlayerController *musicPlayer;
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [musicPlayer setVolume:voiceSlider.value];
}

- (void)clickFullBtn:(id)sender {
    
    VideoViewController *videoView = (VideoViewController *)_delegate;
    if (videoView.fullScreenModeToggled) {
        videoView.beforeOrientation = UIDeviceOrientationPortrait;
        [videoView minimizeVideo];
        videoView.deviceOrientation = UIDeviceOrientationPortrait;
    }else{
        videoView.beforeOrientation = UIDeviceOrientationLandscapeLeft;
        [videoView launchFullScreen];
        videoView.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
}

- (void)clickScaleBtn:(id)sender {
    UIView *scaleView = [self.view viewWithTag:kScaleViewTag];
    UIView *qualityView = [self.view viewWithTag:kQualityViewTag];
    if (scaleView != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            scaleView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [scaleView removeFromSuperview];
        }];
        return ;
    }
    if (qualityView != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            qualityView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [qualityView removeFromSuperview];
        }];
    }
    UIButton *qualityBtn = (UIButton *)sender;
    CGPoint btnLocation = [qualityBtn.superview convertPoint:qualityBtn.frame.origin toView:self.view];
    CGRect rect = CGRectMake(btnLocation.x - 5, btnLocation.y - 90, qualityBtn.frame.size.width + 10, 90);
    scaleView = [[UIView alloc] initWithFrame:rect];
    scaleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scaleView];
    scaleView.tag = kScaleViewTag;
    
    UIView *scaleBgView = [[UIView alloc] initWithFrame:scaleView.bounds];
    scaleBgView.backgroundColor = [UIColor blackColor];
    scaleBgView.alpha = 0.6;
    scaleBgView.layer.masksToBounds = YES;
    scaleBgView.layer.cornerRadius = 3;
    [scaleView addSubview:scaleBgView];
    NSArray *arrTitles = @[@"16:9", @"4:3"];
    for (NSInteger i = 0; i < arrTitles.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:arrTitles[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(5, 5 + 35 * i, rect.size.width - 10, 30);
        btn.tag = i;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [btn addTarget:self action:@selector(adjustVideoScale:) forControlEvents:UIControlEventTouchUpInside];
        [scaleView addSubview:btn];
    }
}

- (void)adjustVideoScale:(id)sender {
    UIButton *showScaleBtn = (UIButton *)[self.view viewWithTag:kScaleBtnTag];
    UIButton *scaleBtn = (UIButton *)sender;
    KSYVideoScale scale = kKSYVideo16W9H;
    if (scaleBtn.tag == 0) {
        scale = kKSYVideo16W9H;
        [showScaleBtn setTitle:@"16:9" forState:UIControlStateNormal];
    }
    else if (scaleBtn.tag == 1) {
        scale = kKSYVideo4W3H;
        [showScaleBtn setTitle:@"4:3" forState:UIControlStateNormal];
    }
    if ([_delegate respondsToSelector:@selector(setVideoScale:)] == YES) {
        [_delegate setVideoScale:scale];
    }
    
    UIView *scaleView = [self.view viewWithTag:kScaleViewTag];
    [UIView animateWithDuration:0.3 animations:^{
        scaleView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [scaleView removeFromSuperview];
    }];
}

- (void)clickEpisodeBtn:(id)sender {
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight(), screenWidth())];
    aView.backgroundColor = [UIColor clearColor];
    
    UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight()/3*2, screenWidth())];
    bView.backgroundColor = [UIColor clearColor];
    [aView addSubview:bView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenHeight()/3*2, 0, screenHeight()/3, screenWidth()) style:UITableViewStylePlain];
    
    aView.tag = csAviewTag;
    
    tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    tableView.tag = csTableViewTag;
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [bView addGestureRecognizer:tap];
    
    [aView addSubview:tableView];
    
    aView.alpha = 1.0;
    
    [self.view addSubview:aView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self clickPlayBtn:nil];
    
    
    VideoViewController *videoView = [VideoViewController new];
    videoView.room_id = [_dataArray[indexPath.row] room_id];
    [self presentViewController:videoView animated:YES completion:^{
        
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    CSMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CSMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.model = _dataArray[indexPath.row];
    
    return cell;
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    
    UIView *aView = [self.view viewWithTag:csAviewTag];
    [aView removeFromSuperview];
    
//    UITableView *tableView = (UITableView *)[self.view viewWithTag:csTableViewTag];
//    [tableView removeFromSuperview];
}

- (void)clickSnapBtn:(id)sender {
    KSYPlayer *player = [(VideoViewController *)_delegate player];
    UIImage *snapImage = [player thumbnailImageAtCurrentTime];
    UIImageWriteToSavedPhotosAlbum(snapImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)clickLockBtn:(id)sender {
    _isLocked = !_isLocked;
    UIView *barView = [self.view viewWithTag:kBarViewtag];
    UIView *voiceView = [self.view viewWithTag:kVoiceViewTag];
    UIView *brightnessView = [self.view viewWithTag:kBrightnessViewTag];
    UIView *toolView = [self.view viewWithTag:kToolViewTag];
    UIView *qualityView = [self.view viewWithTag:kQualityViewTag];
    UIView *scaleView = [self.view viewWithTag:kScaleViewTag];
    UIButton *lockBtn = (UIButton *)sender;
    if (_isLocked == YES) {
        barView.alpha = 0.0;
        voiceView.alpha = 0.0;
        brightnessView.alpha = 0.0;
        toolView.alpha = 0.0;
        qualityView.alpha = 0.0;
        scaleView.alpha = 0.0;
        UIImage *lockCloseImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_lock_close_normal"];
        UIImage *lockCloseImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_lock_close_hl"];
        [lockBtn setImage:lockCloseImg_n forState:UIControlStateNormal];
        [lockBtn setImage:lockCloseImg_h forState:UIControlStateHighlighted];
    }
    else {
        barView.alpha = 1.0;
        voiceView.alpha = 1.0;
        brightnessView.alpha = 1.0;
        toolView.alpha = 1.0;
        qualityView.alpha = 1.0;
        scaleView.alpha = 1.0;
        UIImage *lockOpenImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_lock_open_normal"];
        UIImage *lockOpenImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_lock_open_hl"];
        [lockBtn setImage:lockOpenImg_n forState:UIControlStateNormal];
        [lockBtn setImage:lockOpenImg_h forState:UIControlStateHighlighted];
    }
}

#pragma mark - Snap delegate

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        
        CGRect noticeRect = CGRectMake(0, 0, 100, 100);
        UIView *noticeView = [[UIView alloc] initWithFrame:noticeRect];
        noticeView.backgroundColor = [UIColor clearColor];
        CGPoint center = self.view.center;
        noticeView.center = CGPointMake(center.y, center.x);
        [self.view addSubview:noticeView];
        
        UIView *noticeBgView = [[UIView alloc] initWithFrame:noticeView.bounds];
        noticeBgView.backgroundColor = [UIColor blackColor];
        noticeBgView.alpha = 0.6f;
        noticeBgView.layer.masksToBounds = YES;
        noticeBgView.layer.cornerRadius = 3;
        [noticeView addSubview:noticeBgView];
        
        // **** mark
        CGRect imgRect = CGRectMake(32, 7, 36, 36);
        UIImageView *completeImgView = [[UIImageView alloc] initWithFrame:imgRect];
        UIImage *snapCompleteImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_complete_normal"];
        completeImgView.image = snapCompleteImg;
        [noticeView addSubview:completeImgView];
        
        CGRect labelRect = CGRectMake(0, 57, 100, 36);
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = @"截图成功";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [noticeView addSubview:label];
        
        // **** dismiss
        [UIView animateWithDuration:1.0 animations:^{
            noticeView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [noticeView removeFromSuperview];
        }];
    }
}

#pragma mark - Touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    KSYPlayer *player = [(VideoViewController *)_delegate player];
    _isKSYPlayerPling = player.isPlaying;
    UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
    _startPoint = [[touches anyObject] locationInView:self.view];
    _curPosition = progressSlider.value;
    _curBrightness = [[UIScreen mainScreen] brightness];
    _curVoice = [MPMusicPlayerController applicationMusicPlayer].volume;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // **** 锁屏状态下，屏幕禁用
    if (_isLocked == YES) {
        return;
    }
    CGPoint curPoint = [[touches anyObject] locationInView:self.view];
    CGFloat deltaX = curPoint.x - _startPoint.x;
    CGFloat deltaY = curPoint.y - _startPoint.y;
    CGFloat totalWidth = self.view.frame.size.width;
    CGFloat totalHeight = self.view.frame.size.height;
    if (totalHeight == [[UIScreen mainScreen] bounds].size.height) {
        totalWidth = self.view.frame.size.height;
        totalHeight = self.view.frame.size.width;
    }
    NSInteger duration = (NSInteger)[(VideoViewController *)_delegate player].duration;
    if (fabs(deltaX) < fabs(deltaY)) {
        // **** 亮度
        if ((curPoint.x < totalWidth / 2) && (_gestureType == kKSYUnknown || _gestureType == kKSYBrightness)) {
            CGFloat deltaBright = deltaY / totalHeight * 1.0;
            [[UIScreen mainScreen] setBrightness:_curBrightness - deltaBright];
            UISlider *brightnessSlider = (UISlider *)[self.view viewWithTag:kBrightnessSliderTag];
            [brightnessSlider setValue:_curBrightness - deltaBright animated:NO];
            UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot"];
            [brightnessSlider setThumbImage:dotImg forState:UIControlStateNormal];
            _gestureType = kKSYBrightness;
        }
        // **** 声音
        else if (_gestureType == kKSYUnknown || _gestureType == kKSYVoice) {
            CGFloat deltaVoice = deltaY / totalHeight * 1.0;
            MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
            CGFloat voiceValue = _curVoice - deltaVoice;
            if (voiceValue < 0) {
                voiceValue = 0;
            }
            else if (voiceValue > 1) {
                voiceValue = 1;
            }
            [musicPlayer setVolume:voiceValue];
            MediaVoiceView *mediaVoiceView = (MediaVoiceView *)[self.view viewWithTag:kMediaVoiceViewTag];
            [mediaVoiceView setIVoice:voiceValue];
            _gestureType = kKSYVoice;
        }
        return ;
    }
    else if (duration > 0 && (_gestureType == kKSYUnknown || _gestureType == kKSYProgress)) {
        
        if (!_isPrepared) {
            return;
        }
        if (fabs(deltaX) > fabs(deltaY)) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshControl) object:nil];
            if ([_delegate isPlaying] == YES) {
                [self clickPlayBtn:nil]; // **** 拖拽进度时，暂停播放
            }
            _gestureType = kKSYProgress;
            
            [self performSelector:@selector(showORhideProgressView:) withObject:@NO];
            CGFloat deltaProgress = deltaX / totalWidth * duration;
            UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
            UIView *progressView = [self.view viewWithTag:kProgressViewTag];
            UILabel *progressViewCurLabel = (UILabel *)[self.view viewWithTag:kCurProgressLabelTag];
            UIImageView *wardImageView = (UIImageView *)[self.view viewWithTag:kWardMarkImgViewTag];
            UILabel *startLabel = (UILabel *)[self.view viewWithTag:kProgressCurLabelTag];
            NSInteger position = _curPosition + deltaProgress;
            if (position < 0) {
                position = 0;
            }
            else if (position > duration) {
                position = duration;
            }
            progressSlider.value = position;
            int iMin1  = ((int)labs(position) / 60);
            int iSec1  = ((int)labs(position) % 60);
            int iMin2  = ((int)fabs(deltaProgress) / 60);
            int iSec2  = ((int)fabs(deltaProgress) % 60);
            NSString *strCurTime1 = [NSString stringWithFormat:@"%02d:%02d/", iMin1, iSec1];
            NSString *strCurTime2 = [NSString stringWithFormat:@"%02d:%02d", iMin2, iSec2];
            startLabel.text = strCurTime1;
            if (deltaX > 0) {
                strCurTime2 = [@"+" stringByAppendingString:strCurTime2];
                UIImage *forwardImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_forward_normal"];
                wardImageView.frame = CGRectMake(progressView.frame.size.width - 30, 15, 20, 20);
                wardImageView.image = forwardImg;
            }
            else {
                strCurTime2 = [@"-" stringByAppendingString:strCurTime2];
                UIImage *backwardImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_backward_normal"];
                wardImageView.frame = CGRectMake(10, 15, 20, 20);
                wardImageView.image = backwardImg;
            }
            progressViewCurLabel.text = strCurTime2;
            UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot"];
            [progressSlider setThumbImage:dotImg forState:UIControlStateNormal];
        }
    }
    else if (duration <= 0 && (_gestureType == kKSYUnknown || _gestureType == kKSYProgress)) {
        if (!_isPrepared) {
            return;
        }
        [self showNotice:@"直播不支持拖拽"];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_gestureType == kKSYUnknown) { // **** tap 动作
        if (_isActive == YES) {
            [self hideAllControls];
        }
        else {
            [self showAllControls];
        }
    }
    else if (_gestureType == kKSYProgress) {
        if (!_isPrepared) {
            return;
        }
        
        UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
        if ([_delegate respondsToSelector:@selector(seekProgress:)] == YES) {
            [_delegate seekProgress:progressSlider.value];
        }
        UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot_normal"];
        [progressSlider setThumbImage:dotImg forState:UIControlStateNormal];
    }
    else if (_gestureType == kKSYBrightness) {
        UISlider *brightnessSlider = (UISlider *)[self.view viewWithTag:kBrightnessSliderTag];
        UIImage *dotImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"img_dot_normal"];
        [brightnessSlider setThumbImage:dotImg forState:UIControlStateNormal];
    }
    _gestureType = kKSYUnknown;
}

- (void)seekCompletedWithPosition:(CGFloat)position {
    UISlider *progressSlider = (UISlider *)[self.view viewWithTag:kProgressSliderTag];
    UIButton *btn = (UIButton *)[self.view viewWithTag:kBarPlayBtnTag];
    progressSlider.value = position;
    if (_isCompleted == YES) {
        _isCompleted = NO;
        UIImage *playImg = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
        [btn setImage:playImg forState:UIControlStateNormal];
    }
    else {

        KSYPlayer *player = [(VideoViewController *)_delegate player];
        if (_isKSYPlayerPling) {
            [player play];
        }else{
            _isKSYPlayerPling = NO;
            [player pause];
        }
        _isActive = YES;
        [self refreshControl];
    }
}

#pragma mark - KSYMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(KSYPlayerState)PlayerState {
    
    if (PlayerState != KSYPlayerStateError) {
        [self removeError];
    }
    KSYPlayer *player = [(VideoViewController *)_delegate player];
    if (PlayerState == KSYPlayerStateInitialized) {
        _isPrepared = NO;
        [self showLoading];
    }else if (PlayerState == KSYPlayerStatePrepared){
        [self performSelectorOnMainThread:@selector(removeError) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(removeLoading) withObject:nil waitUntilDone:NO];
    }
    UIButton *btn = (UIButton *)[self.view viewWithTag:kBarPlayBtnTag];
    UIImage *pauseImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_pause_normal"];
    UIImage *pauseImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_pause_hl"];
    UIImage *playImg_n = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_normal"];
    UIImage *playImg_h = [[ThemeManager sharedInstance] imageInCurThemeWithName:@"bt_play_hl"];
    if (PlayerState == KSYPlayerStatePlaying) {
        [btn setImage:pauseImg_n forState:UIControlStateNormal];
        [btn setImage:pauseImg_h forState:UIControlStateHighlighted];
    }else if (PlayerState == KSYPlayerStatePaused || player.state == KSYPlayerStateStopped) {
        [btn setImage:playImg_n forState:UIControlStateNormal];
        [btn setImage:playImg_h forState:UIControlStateHighlighted];
    }
    if (PlayerState == KSYPlayerStatePrepared) {
        _isPrepared = YES;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    //NSLog(@"time changed: %@", aNotification);
    
}

- (void)mediaPlayerCompleted:(KSYPlayer *)player {
    NSLog(@"播放结束");
    _isCompleted = YES;
    [_delegate seekProgress:0.0];
    if ([(VideoViewController *)_delegate isCycleplay] == YES && _errorView.hidden == YES) {
        [_delegate play];
    }
}

- (void)mediaPlayerWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    [self showError];
    [self removeLoading];
}

- (void)mediaPlayerBuffing:(KSYBufferingState)bufferingState {
    if (bufferingState == KSYPlayerBufferingStart) {
        [self showLoading];
    }
    else {
        [self performSelectorOnMainThread:@selector(removeLoading) withObject:nil waitUntilDone:NO];
    }
}

- (void)mediaPlayerSeekCompleted:(KSYPlayer *)player {
    CGFloat position = player.currentPlaybackTime;
    [self seekCompletedWithPosition:position];
}

#pragma mark - Helper

- (void)showAllControls {
    UIView *barView = [self.view viewWithTag:kBarViewtag];
    UIView *voiceView = [self.view viewWithTag:kVoiceViewTag];
    UIView *brightnessView = [self.view viewWithTag:kBrightnessViewTag];
    UIView *toolView = [self.view viewWithTag:kToolViewTag];
    UIView *lockView = (UIButton *)[self.view viewWithTag:kLockViewTag];
    UIView *topView = [self.view viewWithTag:cstopBgViewTag];
    [UIView animateWithDuration:0.3 animations:^{
        if (_isLocked == NO) {
            barView.alpha = 1.0;
            voiceView.alpha = 1.0;
            brightnessView.alpha = 1.0;
            toolView.alpha = 1.0;
            topView.alpha = 1.0;
        }
        lockView.alpha = 1.0;
    } completion:^(BOOL finished) {
        _isActive = YES;
        [self refreshControl];
    }];
}

- (void)hideAllControls {
    UIView *barView = [self.view viewWithTag:kBarViewtag];
    UIView *voiceView = [self.view viewWithTag:kVoiceViewTag];
    UIView *brightnessView = [self.view viewWithTag:kBrightnessViewTag];
    UIView *toolView = [self.view viewWithTag:kToolViewTag];
    UIView *qualityView = [self.view viewWithTag:kQualityViewTag];
    UIView *scaleView = [self.view viewWithTag:kScaleViewTag];
    UIView *lockView = [self.view viewWithTag:kLockViewTag];
    UIView *topView = [self.view viewWithTag:cstopBgViewTag];
    [UIView animateWithDuration:0.3 animations:^{
        if (_isLocked == NO) {
            barView.alpha = 0.0;
            voiceView.alpha = 0.0;
            brightnessView.alpha = 0.0;
            toolView.alpha = 0.0;
            qualityView.alpha = 0.0;
            scaleView.alpha = 0.0;
            topView.alpha = 0.0;
        }
        lockView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [qualityView removeFromSuperview];
        [scaleView removeFromSuperview];
        _isActive = NO;
    }];
}

- (void)showORhideProgressView:(NSNumber *)bShowORHide {
    UIView *progressView = [self.view viewWithTag:kProgressViewTag];
    progressView.hidden = bShowORHide.boolValue;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideProgressView) object:nil];
    if (!bShowORHide.boolValue) {
        [self performSelector:@selector(hideProgressView) withObject:nil afterDelay:1];
    }
}

- (void)hideProgressView {
    UIView *progressView = [self.view viewWithTag:kProgressViewTag];
    progressView.hidden = YES;
}

- (void)showNotice:(NSString *)strNotice {
    static BOOL isShowing = NO;
    if (isShowing == NO) {
        CGRect noticeRect = CGRectMake(0, 0, 150, 30);
        UIView *noticeView = [[UIView alloc] initWithFrame:noticeRect];
        noticeView.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:noticeView.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 5;
        bgView.alpha = 0.6;
        [noticeView addSubview:bgView];
        
        UILabel *noticeLabel = [[UILabel alloc] initWithFrame:noticeView.bounds];
        noticeLabel.text = strNotice;
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.textColor = [UIColor whiteColor];
        [noticeView addSubview:noticeLabel];
        [self.view addSubview:noticeView];
        
        noticeView.center = self.view.center;
        if (self.view.frame.size.height == [[UIScreen mainScreen] bounds].size.height) {
            noticeView.center = CGPointMake(self.view.center.y, self.view.center.x);
        }
        
        [UIView animateWithDuration:1.0 animations:^{
            noticeView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [noticeView removeFromSuperview];
            isShowing = NO;
        }];
    }
}

#pragma mark - Player state

- (void)reSetLoadingViewFrame
{
    if (!_loadingView.hidden) {
        _loadingView.frame = self.view.bounds;
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[_loadingView viewWithTag:kLoadIndicatorViewTag];
        indicatorView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y - 10);
        UILabel *indicatorLabel = (UILabel *)[_loadingView viewWithTag:kLoadIndicatorLabelTag];
        indicatorLabel.center = CGPointMake(_loadingView.center.x, _loadingView.center.y + 20);
    }
    if (!_errorView.hidden) {
        _errorView.frame = self.view.bounds;
        UILabel *indicatorLabel = (UILabel *)[_errorView viewWithTag:kErrorLabelTag];
        indicatorLabel.center = CGPointMake(_errorView.center.x, _errorView.center.y);
    }
}

- (void)showLoading {
    if (_loadingView == nil) {
        _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        _loadingView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_loadingView];
        [self.view sendSubviewToBack:_loadingView];
        
        // **** activity
        CGSize size = self.view.frame.size;
        if ((NSInteger)size.height == (NSInteger)[[UIScreen mainScreen] bounds].size.height) {
            CGFloat temp = size.width;
            size.width = size.height;
            size.height = temp;
        }
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.tag = kLoadIndicatorViewTag;
        _indicatorView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y - 10);
        [_indicatorView startAnimating];
        [_loadingView addSubview:_indicatorView];
        
        CGRect labelRect = CGRectMake(0, 0, 100, 30);
        _indicatorLabel = [[UILabel alloc] initWithFrame:labelRect];
        _indicatorLabel.tag = kLoadIndicatorLabelTag;
        _indicatorLabel.text = @"加载中...";
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
        _indicatorLabel.textColor = [UIColor whiteColor];
        [_loadingView addSubview:_indicatorLabel];
    }
    _indicatorLabel.center = CGPointMake(_loadingView.center.x, _loadingView.center.y + 20);
    _loadingView.hidden = NO;
    [self reSetLoadingViewFrame];
}

- (void)removeLoading {
    _loadingView.hidden = YES;
}

- (void)showError {
    if (_errorView == nil) {
        _errorView = [[UIView alloc] initWithFrame:self.view.bounds];
        _errorView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_errorView];
        [self.view sendSubviewToBack:_errorView]; // **** 可以让视图返回
        
        // **** indicator
        CGSize size = self.view.frame.size;
        if ((NSInteger)size.height == (NSInteger)[[UIScreen mainScreen] bounds].size.height) {
            CGFloat temp = size.width;
            size.width = size.height;
            size.height = temp;
        }
        CGRect labelRect = CGRectMake(size.width / 2 - 50, size.height / 2 - 45, 100, 50);
        UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:labelRect];
        indicatorLabel.tag = kErrorLabelTag;
        indicatorLabel.text = @"直播间未开播";
        indicatorLabel.textColor = [UIColor whiteColor];
        [_errorView addSubview:indicatorLabel];
    }
    _errorView.hidden = NO;
    [self reSetLoadingViewFrame];
}

- (void)removeError{
    _errorView.hidden = YES;
}

int count = 0;

- (void)retiveDrmKey:(NSString *)drmVersion player:(KSYPlayer *)player
{
    DrmRelativeModel *relativeModle = [DrmRelativeModel new];
    relativeModle.kscDrmHost = @"115.231.96.89:80";
    relativeModle.customName = @"service";
    relativeModle.drmMethod = @"GetCek";
    relativeModle.expire = @"1710333224";
    relativeModle.nonce = @"12341234";
    relativeModle.accessKeyId = @"2HITWMQXL2VBB3XMAEHQ";
//    relativeModle.signature = @"5iZ1rTfBjF/9v3U0k/1Pezx98RE=";
    relativeModle.cekVersion = drmVersion;
    [player setRelativeFullURLWithAccessKey:@"2HITWMQXL2VBB3XMAEHQ" secretKey:@"ilZQ9p/NHAK1dOYA/dTKKeIqT/t67rO6V2PrXUNr" drmRelativeModel:relativeModle];
//    [player setDrmKey:@"72" cek:@"123a9bd9af2aa4f85d84099d9e6b6be3"];
    count++;
}

@end
