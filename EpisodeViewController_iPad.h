//
//  EpisodeViewController_iPad.h
//  Oznoz
//
//  Created by Tony Stark on 2/4/13.
//  Copyright (c) 2013 Oznoz Entertainment, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIPaginator.h"
#import "UIOznozVolume.h"
#import "UIOznozBrand.h"
#import "MenuSettingsViewController.h"
#import "EpisodeCell.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>

@interface EpisodeViewController_iPad : UIViewController<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,MenuSettinsDelegate,EpisodeCellProtocol,UIOznozVolumeDelegate,PaginatorDelegate,MBProgressHUDDelegate>{
    UIOznozBrand *oznozBrand;
    //NSMutableArray *volumes;
    UILabel* lbNavTitle;
    MenuSettingsViewController *mSettings;
    UIPopoverController *settings_popoverController;
    NSString *_sku;
    NSString *_language;
    NSInteger total;
    BOOL connectionStatus;
    NSInteger beginPlayer;
    NSInteger endPlayer;
    NSInteger totalTimeViewed;
    NSMutableDictionary *dataLog;
    //MBProgressHUD *HUD;
    NSInteger playIndex;
    NSInteger volumeIndex;
    NSInteger seasonIndex;
    
    NSString *playLanguages;
    NSString *episodeWatchType;
    MPMoviePlayerController* theMovie;
    MPMoviePlayerViewController *theMovieController;
}
@property (nonatomic) NSTimeInterval previousPlaybackTime;
@property (nonatomic) NSTimeInterval currentPlaybackTime;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic, assign) UIOznozVolume *oznozvolume;
@property (nonatomic, assign) UILabel *footerLabel;
@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) APIPaginator *apiPaginator;
@property (nonatomic) NSInteger brand_id;
@property (nonatomic) NSInteger theFirstLoad;
@property (nonatomic,readwrite) NSInteger volume_id;
@property (nonatomic, retain)  Brand *brand;
@property (nonatomic)  BOOL *playVideo;
@property (nonatomic)  BOOL showSubscriber;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) UIButton  *btDownload;
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) BOOL isSubcription;
@property (nonatomic, assign) UIPopoverController *popoverController;
- (void)vdidDisappear;
- (void)reloadDatabase;
- (void)reloadDatabase1;
- (void)reloadDatabase2;
- (void)reloadDatabase3;
- (void)reloadLoadingView;
- (void)reloadDatabaseVolChanged;
-(void) downloadPlay:(NSString *)sku withLanguage:(NSString *)language;
-(void) watchPlay:(NSString *)sku withLanguage:(NSString *)language;
-(void) watchPreviewPlay:(NSString *)sku withLanguage:(NSString *)language;
-(IBAction)watchVolumePlay:(NSString *)sku withLanguage:(NSString *)language;
//- (void)vdidDisappear;
@end
