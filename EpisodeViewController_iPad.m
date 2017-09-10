//
//  EpisodeViewController_iPad.m
//  Oznoz
//
//  Created by Tony Stark on 2/4/13.
//  Copyright (c) 2013 Oznoz Entertainment, LLC. All rights reserved.
//

#import "EpisodeViewController_iPad.h"
#import "AppDelegate.h"
#import "WPReachability.h"
#import "Brand.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ToolBar.h"
#import "UIDevice-Hardware.h"

#import "AgeFilterViewController.h"
#import "LanguagesViewController.h"
#import "ModalLoginViewController_iPad.h"
#import "ResultsViewController_iPad.h"
#import "DownloadsViewController_iPad.h"
#import "AboutViewController.h"
#import "MyStuffViewController_iPad.h"
#import "EpisodeViewController_iPad.h"
#import "AllViewController_iPad.h"
#import "FeaturedViewController_iPad.h"
#import "MySubscriptionViewController.h"
#import "MoviePlayerControllerDoneButton.h"
#import "PurchaseViewController_iPad.h"
#import "OznozVideoPlayerViewController.h"
#import "Utils.h"
@interface EpisodeViewController_iPad ()

@end
#define PageSize 7
@implementation EpisodeViewController_iPad
@synthesize playVideo,type,oznozvolume,apiPaginator,footerLabel,activityIndicator,volume_id,
brand_id,brand,tableView,popoverController,theFirstLoad,showSubscriber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        volume_id=0;
        brand_id=0;
        playIndex=0;
        volumeIndex=0;
        seasonIndex=0;
        type=@"";
        theMovieController = NULL;
    }
    return self;
}
-(void)reloadLoadingViewAfterbought{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
       &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
        //&& [brand.subcription isEqualToString:@"TRUE"]==TRUE){
        self.isSubcription = YES;
    }else{
        self.isSubcription = NO;
    }
   [self reloadLoadingView];
}
- (void)viewDidLoad
{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_nextepisode1"];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLoadingViewAfterbought) name:@"RELOADPAGE1" object:nil];
    dataLog = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    connectionStatus=appDelegate.connectionStatus;
    [UIView setAnimationsEnabled:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_toolbar_ios7.png"] forBarMetrics:UIBarMetricsDefault];
    brand=[[dbCore sharedInstance] brandByBrandId:brand_id];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
       &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
        //&& [brand.subcription isEqualToString:@"TRUE"]==TRUE){
        self.isSubcription = YES;
    }else{
        self.isSubcription = NO;
    }
    theFirstLoad = 0;
    
   
    NSInteger w=self.view.bounds.size.width,h=311;
    UIInterfaceOrientation toInterfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            h=311;

            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            h=279;

            break;
        default:
            //ngang
            if ([[UIScreen mainScreen] bounds].size.height == 911 ) {

                h=279;
                
            }
            //dung
            if ([[UIScreen mainScreen] bounds].size.height == 655 ) {
                h=311;

            }
            //dung
            if ([[UIScreen mainScreen] bounds].size.height == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 1004) {

                h=311;
            }
            //ngang
            if ([[UIScreen mainScreen] bounds].size.height == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 1024 ) {
                h=279;

            }
            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 748 ) {
                h=279;
                
            }
            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 768 ) {
                h=279;
                
            }
            //ngang
            if (self.view.frame.size.width == 1024 && self.view.frame.size.height == 704 ) {
                h=279;
                
            }
            break;
    }
    oznozBrand = [[UIOznozBrand alloc] initWithFrame:CGRectMake(0, 0, w,311) withData: brand];
    oznozBrand.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    oznozBrand.autoresizesSubviews=TRUE;
    oznozBrand.delegate=self;
    [self.view addSubview:oznozBrand];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    CGSize lblTitleSize = [brand.name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,0,lblTitleSize.width,40)];
    lbNavTitle.textAlignment = NSTextAlignmentCenter;
    lbNavTitle.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    lbNavTitle.backgroundColor = [UIColor clearColor];
    lbNavTitle.font = [UIFont systemFontOfSize:20];
    lbNavTitle.text = brand.name;
    self.navigationItem.titleView = lbNavTitle;
    
    oznozvolume = [[UIOznozVolume alloc]  initWithFrame:CGRectMake(0, h,w,90) delegate:self brand:brand] ;
    oznozvolume.brand_id=brand_id;
    oznozvolume.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:oznozvolume];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,h+90, self.view.frame.size.width,self.view.frame.size.height-(h+150)) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    [self addToolBar];
    playVideo  = NO;
    showSubscriber = NO;
    [[dbCore sharedInstance] syncEpisodeOneDay];
}

- (NSString *) truncateString:(NSString *)$string toLimit:(int)$limit {
    if ([$string length] > $limit) {
        $string = [$string substringToIndex:$limit];
        long index = [$string length];
        for (int i=0; i<[$string length]; ++i) {
            char charValue = [$string characterAtIndex:i];
            NSString * value = [NSString stringWithFormat:@"%c", charValue];
            if ([value isEqualToString:@" "]) {
                index = i;
            }
        }
        $string = [$string substringToIndex:index];
        $string = [NSString stringWithFormat:@"%@...", $string];
    }
    return $string;
}


-(void)orientationChanged:(NSNotification *)dict
{
    
    NSInteger h=311;
    if(brand==nil){
        brand=[[dbCore sharedInstance] brandByBrandId:brand_id];
    }
    
    UIInterfaceOrientation toInterfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    switch(toInterfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            h=311;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            h=279;
            break;
        default:
            //ngang
            if ([[UIScreen mainScreen] bounds].size.height == 911 ) {
                h=279;
            }
            //dung
            if ([[UIScreen mainScreen] bounds].size.height == 655 ) {
                h=311;
            }
            //dung
            if ([[UIScreen mainScreen] bounds].size.height == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 1004) {
                h=311;
            }
            //ngang
            if ([[UIScreen mainScreen] bounds].size.height == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 748 ) {
                h=279;
            }
            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 748 ) {
                h=279;
                
            }
            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width == 1024 && [[UIScreen mainScreen] applicationFrame].size.height == 768 ) {
                h=279;
                
            }
            //ngang
            if (self.view.frame.size.width == 1024 && self.view.frame.size.height == 704 ) {
                h=279;
                
            }
            break;
    }
    oznozBrand.frame=CGRectMake(0, 0,  oznozBrand.frame.size.width,oznozBrand.frame.size.height);

    oznozvolume.frame=CGRectMake(0,h+0,  self.view.frame.size.width,90);
    self.tableView.frame = CGRectMake(0,h+90, self.view.frame.size.width,self.view.frame.size.height-(h+150));
    [self.tableView reloadData];
    [oznozvolume refeshViewRotation];
    //[self setupTableViewFooter];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return YES;
}


- (BOOL)shouldAutorotate {
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(void) viewWillAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_nextepisode1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self addToolBar];
//      AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.paymentObserver buy:@"BBB25407" withType:@"products"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_bought"];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"kNetworkReachabilityChangedNotification" object:nil];
    self.tabBarController.tabBar.hidden = FALSE;
    
    if(!self.playVideo || self.showSubscriber ==YES){
        self.showSubscriber = NO;
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
           &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
            self.isSubcription = YES;
        }else{
            self.isSubcription = NO;
        }
        if(brand==nil){
            brand = [[dbCore sharedInstance] brandByBrandId:brand_id];
        }
        if([self.apiPaginator.results count]==0 ||![[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] isEqualToString:@"All"]|| ![[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] isEqualToString:@"All"]){
        //if (![[[UIDevice currentDevice] platformString] isEqualToString:@"iPad 1G"]){
                if([brand.synce integerValue] == 1){
                    [self reloadLoadingView];
                }else{
                    [self reloadDatabase];
                }
        }else{
            [self reloadDatabase];
        }
        [self setupTableViewFooter];
    }
    self.playVideo = NO;
    self.tabBarController.tabBar.hidden = FALSE;
    
}
- (void)reloadLoadingView{
  
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *vols =[[dbCore sharedInstance] volumeListbyBrand:brand];
        if ([vols count]>0) {
            Volume *info=[vols objectAtIndex:0];
            if ([info.is_group isEqualToString:@"true"]) {
                volume_id = 0;
            }else{
                volume_id = info.VolumeId;
            }
        }
        self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];
        theFirstLoad=1;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [oznozvolume refeshViewAfter:vols];
            [self.tableView reloadData];
        });
    });
}
- (void)reloadDatabase{
    NSMutableArray *vols =[[dbCore sharedInstance] volumeListbyBrand:brand];
    if ([vols count]>0) {
        Volume *info=[vols objectAtIndex:0];
        if ([info.is_group isEqualToString:@"true"]) {
            volume_id = 0;
        }else{
            volume_id = info.VolumeId;
        }
    }
    self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];

    theFirstLoad=1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [oznozvolume refeshViewAfter:vols];
        [self.tableView reloadData];
    });

}

- (void)reloadDatabaseVolChanged{

    if((volume_id>0 && [[dbCore sharedInstance] volumesSynce:volume_id]==NO)
           || (volume_id==0 && [brand.volumes isEqualToString:@"0"]==NO)){
            [self reloadDatabaseChanged];
    }else{
        if(volume_id>0){
            self.oznozvolume.btnBuyVolume.hidden = TRUE;
        }
        [self.apiPaginator.results removeAllObjects];
        theFirstLoad=0;
        [self.tableView reloadData];
        [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [self.tableView reloadData];
                if(self.apiPaginator.results.count<1){
                    self.oznozvolume.btnBuyVolume.hidden = TRUE;
                }else{
                    if(volume_id>0){
                        Volume *infoVolume=[[dbCore sharedInstance] volumeExist:volume_id];
                        if (infoVolume.is_bought==1 || [infoVolume.RegularPrice floatValue]==0
                            || self.isSubcription==YES
                            ||[[dbCore sharedInstance] checkBoughtVolume:infoVolume.VolumeId]==TRUE
                            || [[dbCore sharedInstance] checkBoughtVolume1:infoVolume.VolumeId]){
                            self.oznozvolume.btnBuyVolume.hidden = TRUE;
                        }else{
                            //  self.oznozvolume.btnBuyVolume.hidden = FALSE;
                            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_vod_flag"] isEqualToString:@"0"]) {
                                self.oznozvolume.btnBuyVolume.hidden=TRUE;
                            }else
                                self.oznozvolume.btnBuyVolume.hidden=FALSE;
                        }
                        infoVolume =nil;
                    }
                }
                
                [self.activityIndicator stopAnimating];
                [self.footerLabel setNeedsDisplay];
            });
        });
    }

}
- (void)reloadDatabaseChanged{
   
    self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];
        theFirstLoad=1;
    //[[dbCore sharedInstance] productList:brand_id withVolume:volume_id withPage:page withPageSize:pageSize]
    [self.tableView reloadData];
    if(self.apiPaginator.results.count<1){
        self.oznozvolume.btnBuyVolume.hidden = TRUE;
    }else{
        if(volume_id>0){
            Volume *infoVolume=[[dbCore sharedInstance] volumeExist:volume_id];
            if (infoVolume.is_bought==1 || [infoVolume.RegularPrice floatValue]==0
                || self.isSubcription==YES
                ||[[dbCore sharedInstance] checkBoughtVolume:infoVolume.VolumeId]==TRUE
                || [[dbCore sharedInstance] checkBoughtVolume1:infoVolume.VolumeId]){
                self.oznozvolume.btnBuyVolume.hidden = TRUE;
            }else{
              //  self.oznozvolume.btnBuyVolume.hidden = FALSE;
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_vod_flag"] isEqualToString:@"0"]) {
                    self.oznozvolume.btnBuyVolume.hidden=TRUE;
                }else
                    self.oznozvolume.btnBuyVolume.hidden=FALSE;
            }
            infoVolume =nil;
        }
    }
}

- (void)reloadDatabase1{
    if (![[[UIDevice currentDevice] platformString] isEqualToString:@"iPad 1G"])
    {
        [self performSelectorInBackground:@selector(addToolBar) withObject:nil];
    }else{
        [self addToolBar];
    }
    self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];
    
    [self.tableView reloadData];
    if(self.apiPaginator.results.count<1){
        self.oznozvolume.btnBuyVolume.hidden = TRUE;
    }else{
        if(volume_id>0){
            Volume *infoVolume=[[dbCore sharedInstance] volumeExist:volume_id];
            if (infoVolume.is_bought==1 || [infoVolume.RegularPrice floatValue]==0
                ||[[dbCore sharedInstance] checkBoughtVolume:infoVolume.VolumeId]==TRUE
                || [[dbCore sharedInstance] checkBoughtVolume1:infoVolume.VolumeId]){
                self.oznozvolume.btnBuyVolume.hidden = TRUE;
            }else{
               // self.oznozvolume.btnBuyVolume.hidden = FALSE;
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_vod_flag"] isEqualToString:@"0"]) {
                    self.oznozvolume.btnBuyVolume.hidden=TRUE;
                }else
                    self.oznozvolume.btnBuyVolume.hidden=FALSE;
            }
            infoVolume =nil;
        }
    }
}
- (void)reloadDatabase2{

    self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:0 withType:0];
    
    [self.tableView reloadData];
}
- (void)reloadDatabase3{
    self.apiPaginator = [[APIPaginator alloc] initWithPageSize:PageSize delegate:self withBrand:brand_id withVolume:volume_id withType:0];
    
    [self.tableView reloadData];
}
#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    total =self.apiPaginator.results.count ;
	if (total== 0)
	{
		return 1;
	}
	return total;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && UIInterfaceOrientationIsPortrait(interfaceOrientation) && self.apiPaginator.results.count == 0) {
        // handle portrait
        return 97*3;
    }

	return 97;
}
- (UITableViewCell *)tableView:(UITableView *)tbView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    EpisodeCell *cell = [tbView dequeueReusableCellWithIdentifier:cellIdentifier];
    //cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (cell == nil)
    {
        cell = [[EpisodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier delegate:self];
    }
    
    if (total<1 || indexPath == nil){
        [cell setDataNoitems:@""];
        if (theFirstLoad==1) {
            cell.textLabel.text =@"No items.";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.autoresizesSubviews = YES;
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            theFirstLoad=0;
        }
        
    }else{
        [cell setDataNoitems:@""];
        Product *info = [self.apiPaginator.results objectAtIndex:indexPath.row];
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
        NSInteger width=0;
        if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            // handle landscape
            width=1024;
        } else if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            // handle portrait
            width=768;
        }else{
            //ngang
            if ([[UIScreen mainScreen] bounds].size.width==768 && [[UIScreen mainScreen] applicationFrame].size.width == 748){
                width= 1024;
                
            }
            //dung
            if ([[UIScreen mainScreen] bounds].size.width==768 && [[UIScreen mainScreen] applicationFrame].size.width == 768){
                width= 768;
                
            }

            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width==1024 && [[UIScreen mainScreen] applicationFrame].size.height == 748){
                width= 1024;
                
            }
            //ngang
            if ([[UIScreen mainScreen] applicationFrame].size.width==1024 && [[UIScreen mainScreen] applicationFrame].size.height == 768){
                width= 1024;
                
            }
        }
        
        [cell setData:info subcription:self.isSubcription];
        //[cell setData:info];
         cell.textLabel.text = @"";
        cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell.titleLabel.frame=CGRectMake(133+15+55,cell.imageView.frame.origin.y-3,width-WIDTH_BTN-195-cell.imageView.frame.size.width,cell.titleLabel.frame.size.height);
        
        CGSize titleLabelSize = [info.name sizeWithAttributes:@{NSFontAttributeName:cell.titleLabel.font}];
                                 //sizeWithFont:cell.titleLabel.font constrainedToSize:CGSizeMake(width-WIDTH_BTN-195-cell.imageView.frame.size.width,40) lineBreakMode:cell.titleLabel.lineBreakMode];
        if (titleLabelSize.height>20) {
            cell.languageLabel.frame= CGRectMake(133+15+55,cell.titleLabel.frame.origin.y+titleLabelSize.height+6,width-WIDTH_BTN-195-cell.imageView.frame.size.width,cell.languageLabel.frame.size.height);
            cell.runtimeLabel.frame=CGRectMake(133+15+55,cell.languageLabel.frame.origin.y+cell.languageLabel.frame.size.height,width-WIDTH_BTN-195-cell.imageView.frame.size.width,cell.runtimeLabel.frame.size.height);
        }else{
            cell.languageLabel.frame= CGRectMake(133+15+55,cell.titleLabel.frame.origin.y+titleLabelSize.height+26,width-WIDTH_BTN-195-cell.imageView.frame.size.width,cell.languageLabel.frame.size.height);
            
            cell.runtimeLabel.frame=CGRectMake(133+15+55,cell.languageLabel.frame.origin.y+cell.languageLabel.frame.size.height,width-WIDTH_BTN-195-cell.imageView.frame.size.width,cell.runtimeLabel.frame.size.height);
        }
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_vod_flag"] isEqualToString:@"0"]) {
            cell.btnBuy.frame=CGRectMake(width-180,cell.imageView.frame.origin.y,WIDTH_BTN,HEIGHT_BTN);
            cell.btnDownload.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.imageView.frame.origin.y,WIDTH_BTN,HEIGHT_BTN);
            if(cell.lblPurchased.hidden)
                cell.btnWatch.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.titleLabel.frame.origin.y+45,WIDTH_BTN,HEIGHT_BTN);
            else
                cell.btnWatch.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.titleLabel.frame.origin.y+35,WIDTH_BTN,HEIGHT_BTN);
            
            cell.btnWatch1.frame = CGRectMake(width-180,cell.imageView.frame.origin.y,WIDTH_BTN,HEIGHT_BTN);
            cell.lblPurchased.frame = CGRectMake(width-180,cell.imageView.frame.origin.y+59,WIDTH_BTN,HEIGHT_BTN);
            cell.btnWatchPreview.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.titleLabel.frame.origin.y+40,WIDTH_BTN,HEIGHT_BTN);
            
        }else{

            cell.btnBuy.frame=CGRectMake(width-180,cell.imageView.frame.origin.y,WIDTH_BTN,HEIGHT_BTN);
            cell.btnDownload.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.imageView.frame.origin.y-5,WIDTH_BTN,HEIGHT_BTN);
            cell.btnWatch.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.titleLabel.frame.origin.y+40,WIDTH_BTN,HEIGHT_BTN);
            cell.btnWatch1.frame = CGRectMake(width-180,cell.imageView.frame.origin.y,WIDTH_BTN,HEIGHT_BTN);
            cell.lblPurchased.frame = CGRectMake(width-180,cell.imageView.frame.origin.y+60,WIDTH_BTN,HEIGHT_BTN);
            cell.btnWatchPreview.frame = CGRectMake(cell.btnBuy.frame.origin.x,cell.titleLabel.frame.origin.y+40,WIDTH_BTN,HEIGHT_BTN);
        }
       //NSLog(@"info.entityId:%ld",(long)info.entityId);
        // NSLog(@"[[[NSUserDefaults standardUserDefaults] objectForKey:@\"oznoztv_episode_one_day\"] integerValue]:%ld",(long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_episode_one_day"] integerValue]);
        // NSLog(@"info.name:%@",info.name);
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_episode_one_day"] integerValue]>0 && info.entityId == [[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_episode_one_day"] integerValue])
        [cell.btnWatch1 setBackgroundImage:[UIImage imageNamed:@"FreeToday"] forState: UIControlStateNormal ];
        else
            [cell.btnWatch1 setBackgroundImage:[UIImage imageNamed:WATCH_BTN] forState: UIControlStateNormal ];
       
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

    }
    return cell;
}
#pragma mark -
#pragma mark Buy Action
-(IBAction)buyVolumeClick:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.connectionStatus) {
        
        UIButton *btnBuy = (UIButton *) sender;
        NSString *ID=btnBuy.tag;
        if ([SKPaymentQueue canMakePayments]) {
            [appDelegate.paymentObserver buy:ID withType:@"products" withVolume:1 withBrand:brand_id];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_bought"];
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Syncing your order, please wait a moment." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
            [alert show];
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            // Adjust the indicator so it is up a few pixels from the bottom of the alert
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            [indicator release];
            NSMutableArray  *list=[[dbCore sharedInstance] productList:brand_id withVolume:volume_id withPage:0 withPageSize:0];
            NSString* customerUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
            if ([customerUuid length]<30)
            {
                for (Product *item in list)
                {
                    [[dbCore sharedInstance] purchasedINSERT:item.sku withWEBAPI:0 withBandID:item.brandsId];
                }
            }else {
                for (Product *item in list)
                {
                    [[dbCore sharedInstance] purchasedINSERT:item.sku withWEBAPI:0 withBandID:item.brandsId];
                    [[dbCore sharedInstance] purchasedINSERT:item.sku withWEBAPI:1 withBandID:item.brandsId];
                }
                
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_bought"];
            
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            btnBuy.hidden=TRUE;
            [self reloadDatabase];
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Attention"
                              message: @"You cannot purchase or download in offline mode."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(IBAction)buyClick:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.connectionStatus) {
        UIButton *btnBuy = (UIButton *) sender;
 //       Product *_product=[[dbCore sharedInstance] productBySKU:@"BBB25397"];
        Product *_product=[[dbCore sharedInstance] productBySKU:btnBuy.tag];
        if ([SKPaymentQueue canMakePayments]) {
            NSLog(@"Start In App Purchase!");
            
            [appDelegate.paymentObserver buy:btnBuy.tag withType:@"products"];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_bought"];
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Syncing your order, please wait a moment." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
            [alert show];
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            // Adjust the indicator so it is up a few pixels from the bottom of the alert
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            [indicator release];
            NSString* customerUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
            
            if ([customerUuid length]<30)
            {
                [[dbCore sharedInstance] purchasedINSERT:_product.sku withWEBAPI:0 withBandID:_product.brandsId];
            }else {
                [[dbCore sharedInstance] buyPost:_product.sku];
                
            }
            [self performSelector:@selector(reloadDatabase) withObject:nil afterDelay:0.0];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_bought"];
            
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
        
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Attention"
                              message: @"You cannot purchase or download in offline mode."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}
-(IBAction)watchPreviewClick:(id)sender
{
    episodeWatchType=@"";
    [self.popoverController dismissPopoverAnimated:FALSE];
    self.popoverController = nil;
    UIButton *btnWatch = (UIButton *) sender;
    Product *product  =[[dbCore sharedInstance] productBySKU:btnWatch.tag];
    //if (self.popoverController == nil || [self.popoverController.contentViewController isKindOfClass:[AgeFilterViewController class]]||[self.popoverController.contentViewController isKindOfClass:[LanguagesViewController class]]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
    languages.sku=btnWatch.tag;
    if ([type isEqualToString:@"all"]) {
            languages.type=@"allWatchPreview";
    }else if([type isEqualToString:@"featured"]){
            languages.type=@"featuredWatchPreview";
    }else{
            languages.type=@"mystuffWatchPreview";
    }
    languages.preferredContentSize =CGSizeMake(300, 175);
    languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"WatchPreview" withProduct:product];
    if (languages.listOfLanguages.count<2) {
        [self watchPreviewPlay:product.sku withLanguage:product.languages];
    }else{
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
        self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
        self.popoverController.delegate = self;
	
        CGRect popoverRect = [self.view convertRect:[btnWatch frame] fromView:[btnWatch superview]];
        popoverRect.size.width = MIN(popoverRect.size.width, 100);
        [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    }
}
-(IBAction)watchClick:(id)sender
{
    
    [self.popoverController dismissPopoverAnimated:FALSE];
    self.popoverController = nil;
    UIButton *btnWatch = (UIButton *) sender;
    //[self.popoverController dismissPopoverAnimated:FALSE];
    Product *product  =[[dbCore sharedInstance] productBySKU:btnWatch.tag];
    episodeWatchType=@"";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
    languages.sku=btnWatch.tag;
    languages.preferredContentSize =CGSizeMake(300,175);
    if ([type isEqualToString:@"all"]) {
            languages.type=@"allWatch";
    }else{
            languages.type=@"featuredWatch";
    }
    languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Watch" withProduct:product];
    
    
    if (languages.listOfLanguages.count<2 ) {
        Language *lang=languages.listOfLanguages[0];
        [self watchPlay:languages.sku withLanguage:lang.name];
    }else{
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
        self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
        self.popoverController.delegate = self;
        CGRect popoverRect = [self.view convertRect:[btnWatch frame] fromView:[btnWatch superview]];
        popoverRect.size.width = MIN(popoverRect.size.width, 100);
        
        [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
        
    }

}

-(IBAction)watchClick1:(id)sender
{
    
    [self.popoverController dismissPopoverAnimated:FALSE];
    self.popoverController = nil;
    UIButton *btnWatch = (UIButton *) sender;
    Product *product  =[[dbCore sharedInstance] productBySKU:btnWatch.tag];
    if(product.hasBought || product.price==0
       || ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]
           && [[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"])){
           episodeWatchType = @"";
           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
           LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
           languages.sku=btnWatch.tag;
           languages.preferredContentSize =CGSizeMake(300,175);
           if ([type isEqualToString:@"all"]) {
               languages.type=@"allWatch";
           }else{
               languages.type=@"featuredWatch";
           }
           languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Watch" withProduct:product];
           NSArray *mylanguages = [product.languages componentsSeparatedByString:@", "];
           if (languages.listOfLanguages.count<2) {
               
               if([mylanguages count]==1){
                    [self watchPlay:languages.sku withLanguage:product.languages];
               }else{
                    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"]) {
                        for (int j=0; j<[mylanguages count]; j++) {
                            NSString*_lang =mylanguages[j];
                            NSString* defaultlanguages=[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"];
                            if([defaultlanguages containsString:_lang]){
                            
                                 [self watchPlay:languages.sku withLanguage:_lang];
                                break;
                            }
                        }
                    }else{
                        [self watchPlay:languages.sku withLanguage:mylanguages[0]];
                    }
                  
               }
           }else{
               self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
               self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
               self.popoverController.delegate = self;
               CGRect popoverRect = [self.view convertRect:[btnWatch frame] fromView:[btnWatch superview]];
               popoverRect.size.width = MIN(popoverRect.size.width, 100);
               
               [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
               
           }
           
       }else{
           NSString *episodeIdAday = [[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_episode_one_day"];
           NSString *oznozAccount = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
           if (product.typeId>0 && oznozAccount.length>30 && ([episodeIdAday intValue]==0 || [episodeIdAday intValue]==product.entityId)) {
               episodeWatchType=@"watchFreeOneDay";
               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
               LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
               languages.sku=btnWatch.tag;
               languages.preferredContentSize =CGSizeMake(300,175);
               if ([type isEqualToString:@"all"]) {
                   languages.type=@"allWatch";
               }else{
                   languages.type=@"featuredWatch";
               }
               languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Watch" withProduct:product];
               NSArray *mylanguages = [product.languages componentsSeparatedByString:@", "];
               if (languages.listOfLanguages.count<2) {
                   if (![[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"]) {
                       for (int j=0; j<[mylanguages count]; j++) {
                           NSString*_lang =mylanguages[j];
                           NSString* defaultlanguages=[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"];
                           if([defaultlanguages containsString:_lang]){
                               
                               [self watchPlay:languages.sku withLanguage:_lang];
                               break;
                           }
                       }
                   }else{
                       [self watchPlay:languages.sku withLanguage:mylanguages[0]];
                   }
 
               }else{
                   self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
                   self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
                   self.popoverController.delegate = self;
                   CGRect popoverRect = [self.view convertRect:[btnWatch frame] fromView:[btnWatch superview]];
                   popoverRect.size.width = MIN(popoverRect.size.width, 100);
                   
                   [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
                   
               }
               
               
           }else{
               NSString *oznozUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
               if ([oznozUuid length]>30) {
                   [[NSNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(reloadLoadingView) name:@"RELOADPAGE" object:nil];
                   UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                   PurchaseViewController_iPad *vc = [storyboard instantiateViewControllerWithIdentifier:@"PURCHASE"];
                   vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                   [vc.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
                   
                   [self presentViewController:vc animated:YES completion:nil];
               }else{
                   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                   [appDelegate clearLoginData];
                   [appDelegate setWindowMod:@"Login"];
               }
               
           }
       }
    
    
}
-(IBAction)previewClick:(id)sender
{
}
-(IBAction)watchVolumePlay:(NSString *)sku withLanguage:(NSString *)language
{
    NSString* customerUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
    if ([customerUuid length]>30) {
     int index=0;
     Product *info =[[Product alloc]init];
     NSString* lang=@"";
     for (int i=0; i<[self.apiPaginator.results count]; i++) {
     if (i<[self.apiPaginator.results count] && playIndex != i) {
     playIndex =  index=i;
     info = [self.apiPaginator.results objectAtIndex:index];
     NSMutableArray *listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Watch" withProduct:info];
    if([language length]>0 || !language){ NSLog(@"language:%@",language);
        playLanguages=language; NSLog(@"playLanguages:%@",playLanguages);
         goto play_now;
         }else if (![[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"]) {
     playLanguages=  [[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"];
              goto play_now;
     }else{
     if (listOfLanguages.count<2) {
     playLanguages=   lang=info.languages;
     goto play_now;
     
     }else{
     for (int j=0; j<[listOfLanguages count]; j++) {
     Language *_lang =listOfLanguages[j];
     if(playLanguages != _lang.name){
     playLanguages=   lang=_lang.name;
     goto play_now;
     }
     }
     
     }
     }
     }
     
     
     
     }
     play_now:
     [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_nextepisode1"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     info = [self.apiPaginator.results objectAtIndex:playIndex];
     [self watchAllPlay:info.sku withLanguage:playLanguages];
     }else{
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle: @"Subscribe Now"
     message: @"An Oznoz Video subscription is required to watch."
     delegate: self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];
     [alert release];
         
     }
    
}
-(IBAction)watchVolumeClick:(id)sender
{
   
    [self.popoverController dismissPopoverAnimated:FALSE];
    self.popoverController = nil;
    UIButton *btnWatch = (UIButton *) sender;
    [self.popoverController dismissPopoverAnimated:FALSE];
 
    
    Product *product =[[Product alloc]init];
    Brand *tmpBrand= [[dbCore sharedInstance] brandByBrandId:brand_id];
    NSMutableArray  * volumes=[[dbCore sharedInstance] volumeListbyBrand:tmpBrand];
    Volume *row=[volumes objectAtIndex:0];
    
    NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:brand_id];
    product  = [episodes objectAtIndex:0];
     _sku=product.sku;
    volumeIndex =  0;
    playIndex =  0;

     NSLog(@"product.sku:%@",product.sku);
    if(product.hasBought || product.price==0
       || ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]
           && [[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"])){
           
           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
           LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
           languages.sku=btnWatch.tag;
           languages.preferredContentSize =CGSizeMake(300,175);
           if ([type isEqualToString:@"all"]) {
               languages.type=@"allWatchall";
           }else{
               languages.type=@"featuredWatchall";
           }
           languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Watch" withProduct:product];
  
           self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
           self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
           self.popoverController.delegate = self;
           CGRect popoverRect = [self.view convertRect:[btnWatch frame] fromView:[btnWatch superview]];
           popoverRect.size.width = MIN(popoverRect.size.width, 100);
           
           [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
           
       }else{
           NSString *oznozUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
           if ([oznozUuid length]>30) {
               [[NSNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(reloadLoadingView) name:@"RELOADPAGE" object:nil];
               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
               PurchaseViewController_iPad *vc = [storyboard instantiateViewControllerWithIdentifier:@"PURCHASE"];
               vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
               [vc.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
               
               [self presentViewController:vc animated:YES completion:nil];
           }else{
               AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
               [appDelegate clearLoginData];
               [appDelegate setWindowMod:@"Login"];
           }
           
           
//           UIAlertView *alert = [[UIAlertView alloc]
//                                 initWithTitle: @"Subscribe Now"
//                                 message: @"An Oznoz Video subscription is required to watch."
//                                 delegate: self
//                                 cancelButtonTitle:@"OK"
//                                 otherButtonTitles:nil];
//           [alert show];
//           [alert release];
           
       }
    
}
-(IBAction)downloadClick:(id)sender
{
    [self.popoverController dismissPopoverAnimated:FALSE];
    self.popoverController = nil;
    UIButton *btnDownload = (UIButton *) sender;
    Product *product  =[[dbCore sharedInstance] productBySKU:btnDownload.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
    languages.sku=btnDownload.tag;
    languages.type=@"Download";
    languages.listOfLanguages=[[dbCore sharedInstance] loadLanguages:@"Download" withProduct:product];
    languages.preferredContentSize =CGSizeMake(300, 175);
    self.btDownload = btnDownload;
    if (languages.listOfLanguages.count==1) {
        Language *lang = [languages.listOfLanguages objectAtIndex:0];
        [self downloadPlay:product.sku withLanguage:lang.name];
        
    }else{
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:languages];
        self.popoverController.popoverContentSize =  CGSizeMake(300, 175);
        self.popoverController.delegate = self;
        CGRect popoverRect = [self.view convertRect:[btnDownload frame] fromView:[btnDownload superview]];
        popoverRect.size.width = MIN(popoverRect.size.width, 100);
        [self.popoverController presentPopoverFromRect:popoverRect inView:self.view  permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    }
    
}
-(IBAction)languagesClick:(id)sender
{
    [self.popoverController dismissPopoverAnimated:FALSE];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    LanguagesViewController *languages = [storyboard instantiateViewControllerWithIdentifier:@"LANGUAGES"];
    languages.listOfLanguages=[[dbCore sharedInstance] languageList];
    languages.preferredContentSize =CGSizeMake(300,335);
    languages.type=@"products";
    UIPopoverController *popover =  [[UIPopoverController alloc] initWithContentViewController:languages];
    popover.popoverContentSize =  CGSizeMake(300, 335);
    popover.delegate = self;
    self.popoverController = popover;
	//}
     [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (IBAction)ageFilterClick:(id)sender
{
    [self.popoverController dismissPopoverAnimated:FALSE];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        AgeFilterViewController *ages = [storyboard instantiateViewControllerWithIdentifier:@"AGES"];
        ages.ageList=[[dbCore sharedInstance] ageList];
        ages.type=@"productsAge";
        ages.preferredContentSize =CGSizeMake(300, 280);
        UIPopoverController *popover =  [[UIPopoverController alloc] initWithContentViewController:ages];
        popover.popoverContentSize =  CGSizeMake(300, 280);
        popover.delegate = self;
        self.popoverController = popover;
   // }
     [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  //  [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(IBAction)searchClick:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Oznoz Video" message:@""
                                                   delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Submit", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
	[alert release];
	
}
#pragma mark -
#pragma mark Popover Controller
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)poController {
    [poController dismissPopoverAnimated:NO];
   // [popoverController dismissPopoverAnimated:NO];
}
#pragma mark -
#pragma mark Media Player
- (NSString *) storageDirectory:(NSString *)filenameTemp{
    NSString* storageDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [[storageDirectory stringByAppendingPathComponent:filenameTemp] copy];
	return filename;
}
- (void) oznozMoviePlayerWatchAll:(NSString *)strFile TypePlay:(NSString *)typePlay{
    //begin logs stats video
    if (self.popoverController!=nil) {
        [self.popoverController dismissPopoverAnimated:NO];
    }
    beginPlayer = 0;
    endPlayer = 0;
    totalTimeViewed = 0;
    if (dataLog!=nil) {
        [dataLog release];
    }
    dataLog = [[NSMutableDictionary alloc] init];
    Product *pro = [[dbCore sharedInstance] productBySKU:_sku];
    NSString *watchType = @"";
    if ([typePlay isEqualToString:@"local"]) {
        watchType = @"download-";
    }
    
    if ([typePlay isEqualToString:@"preview"]) {
        [dataLog setValue:@"preview" forKeyPath:@"watch_type"];
    }else{
        if(pro.hasBought==FALSE || pro.price==0){
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
               &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
                
                [dataLog setValue:[NSString stringWithFormat:@"%@subscription",watchType] forKeyPath:@"watch_type"];
            }else{
                [dataLog setValue:[NSString stringWithFormat:@"%@freeEpisode",watchType] forKeyPath:@"watch_type"];
            }
        }else{
            [dataLog setValue:[NSString stringWithFormat:@"%@purchased",watchType] forKeyPath:@"watch_type"];
        }
    }
    [dataLog setValue:[NSString stringWithFormat:@"%ld",(long)brand_id] forKeyPath:@"brand_id"];
    
    NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [NSDate date];
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"date_play"];
    
    df.dateFormat = @"HH:mm:ss";
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"begin_play"];
    [dataLog setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_username_preference"] forKeyPath:@"email"];
    [dataLog setValue:@"watchvideo" forKeyPath:@"command"];
    [dataLog setValue:@"playing" forKeyPath:@"status"];
    [dataLog setValue:_sku forKeyPath:@"sku"];
    [dataLog setValue:_language forKeyPath:@"language"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_nextepisode1"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    [self addObserverNotification];
    NSURL* videoURL = nil;
    if ([typePlay isEqualToString:@"local"]) {
        //videoURL =  [NSURL fileURLWithPath:[self storageDirectory:strFile]];
        videoURL =  [NSURL fileURLWithPath:strFile];
        [dataLog setValue:@"local" forKeyPath:@"typePlayer"];
    }else if([typePlay isEqualToString:@"stream"]){
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"stream" forKeyPath:@"typePlayer"];
    }else{
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"preview" forKeyPath:@"typePlayer"];
    }
    //end log stats video
    
    theMovieController = [[MPMoviePlayerViewController alloc] initWithContentURL: videoURL];
    MPMoviePlayerController* theMovie = [theMovieController moviePlayer];
    [theMovie setFullscreen:YES];
    [[theMovieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];//MPMovieControlStyleFullscreen

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(myMovieFinishedCallbackWatchAll:) name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];

    UIButton *doneButton = MoviePlayerControllerDoneButton(theMovie);
    //[doneButton setTitle:@"✖" forState:UIControlStateNormal];
    //doneButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [doneButton addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    theMovie.allowsAirPlay=TRUE;
    theMovie.useApplicationAudioSession = NO;
    [theMovie prepareToPlay];
   // [[theMovieController moviePlayer] setContentURL:videoURL]; //change url video
    [self presentModalViewController:theMovieController animated:NO];
    [[theMovieController moviePlayer] play];
    
}
-(void) doneClick:(id) sender
{
 NSLog(@"you just touch the done button");
    playIndex=0;
    volumeIndex=0;
    _sku=@"";
     _language=@"";
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_nextepisode1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) oznozMoviePlayerPreview:(NSString *)strFile TypePlay:(NSString *)typePlay{
    //begin logs stats video
    if (self.popoverController!=nil) {
        [self.popoverController dismissPopoverAnimated:NO];
    }
    beginPlayer = 0;
    endPlayer = 0;
    totalTimeViewed = 0;
    if (dataLog!=nil) {
        [dataLog release];
    }
    dataLog = [[NSMutableDictionary alloc] init];
    Product *pro = [[dbCore sharedInstance] productBySKU:_sku];
    NSString *watchType = @"";
    if ([typePlay isEqualToString:@"local"]) {
        watchType = @"download-";
    }
    
    if ([typePlay isEqualToString:@"preview"]) {
        [dataLog setValue:@"preview" forKeyPath:@"watch_type"];
    }else{
        if(pro.hasBought==FALSE || pro.price==0){
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
               &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
                
                [dataLog setValue:[NSString stringWithFormat:@"%@subscription",watchType] forKeyPath:@"watch_type"];
            }else{
                [dataLog setValue:[NSString stringWithFormat:@"%@freeEpisode",watchType] forKeyPath:@"watch_type"];
            }
        }else{
            [dataLog setValue:[NSString stringWithFormat:@"%@purchased",watchType] forKeyPath:@"watch_type"];
        }
    }
    [dataLog setValue:[NSString stringWithFormat:@"%ld",(long)brand_id] forKeyPath:@"brand_id"];
    
    NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [NSDate date];
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"date_play"];
    
    df.dateFormat = @"HH:mm:ss";
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"begin_play"];
    [dataLog setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_username_preference"] forKeyPath:@"email"];
    [dataLog setValue:@"watchvideo" forKeyPath:@"command"];
    [dataLog setValue:@"playing" forKeyPath:@"status"];
    [dataLog setValue:_sku forKeyPath:@"sku"];
    [dataLog setValue:_language forKeyPath:@"language"];
    
    
    [self addObserverNotification1];
    NSURL* videoURL = nil;
    if ([typePlay isEqualToString:@"local"]) {
        //videoURL =  [NSURL fileURLWithPath:[self storageDirectory:strFile]];
        videoURL =  [NSURL fileURLWithPath:strFile];
        [dataLog setValue:@"local" forKeyPath:@"typePlayer"];
    }else if([typePlay isEqualToString:@"stream"]){
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"stream" forKeyPath:@"typePlayer"];
    }else{
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"preview" forKeyPath:@"typePlayer"];
    }
    //end log stats video
    
    MPMoviePlayerViewController *theMovieController = [[MPMoviePlayerViewController alloc] initWithContentURL: videoURL];
    theMovie = [theMovieController moviePlayer];
    [theMovie setFullscreen:YES];
    [[theMovieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];//MPMovieControlStyleFullscreen
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self selector: @selector(myMovieFinishedCallback1:) name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
    theMovie.allowsAirPlay=TRUE;
    theMovie.useApplicationAudioSession = NO;
    [theMovie prepareToPlay];
    //UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    //theMovieController.view.tag = 919191919;
    //[theMovieController.view setFrame:backgroundWindow.frame];
    //[backgroundWindow addSubview:theMovieController.view];
    //[[theMovieController moviePlayer] play];
    
    //[self presentMoviePlayerViewControllerAnimated:theMovieController];
    [self presentModalViewController:theMovieController animated:NO];
    [[theMovieController moviePlayer] play];
    
}
-(void)addObserverNotification1{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange1:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackIsPreparedToPlayDidChange1:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    
    
}
-(void)removeObserverNotification1{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
}

-(void) moviePlayerPlaybackStateDidChange1:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    if (moviePlayer.currentPlaybackTime>0) {
        [dataLog setValue:[self strFormatTime:moviePlayer.duration] forKey:@"duration"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.duration] forKey:@"vduration"];
        
        [dataLog setValue:[self strFormatTime:moviePlayer.currentPlaybackTime] forKeyPath:@"time_play"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.currentPlaybackTime] forKey:@"vtimeplayer"];
        NSLog(@"moviePlayerPlaybackStateDidChange: %f",moviePlayer.currentPlaybackTime);
        int tMins = (int)(moviePlayer.currentPlaybackTime/60) % 60;
        int tMins1 = (int)(moviePlayer.duration/60) % 60;
        if (tMins>=2 || tMins1<=5) {
            [self myMovieFinishedCallback1:notification];
        }
    }
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped:
            NSLog(@"MPMoviePlaybackStateStopped");
            [self.timer invalidate];
            self.timer = nil;
            break;
        case MPMoviePlaybackStatePlaying:
            NSLog(@"MPMoviePlaybackStatePlaying: %f",moviePlayer.currentPlaybackTime);
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
            [self.timer fire];
            if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"local"] && beginPlayer>0) {
                if (totalTimeViewed ==0) {
                    
                    totalTimeViewed = beginPlayer;
                }else if(beginPlayer>endPlayer){
                    totalTimeViewed += (beginPlayer-endPlayer);
                }
                endPlayer = moviePlayer.currentPlaybackTime;
                beginPlayer = 0;
            }
            
            break;
        case MPMoviePlaybackStatePaused:
            //totalTimeViewed = totalTimeViewed + [[NSDate date] timeIntervalSinceDate:beginDate];
            NSLog(@"MPMoviePlaybackStatePaused");
            break;
        case MPMoviePlaybackStateInterrupted:
            break;
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"MPMoviePlaybackStateSeekingBackward");
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
        case MPMoviePlaybackStateSeekingForward:
            //[moviePlayer beginSeekingForward];
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
    }
    
}
- (void)timedJob {
    
    if (theMovie.playbackState == MPMoviePlaybackStateSeekingBackward) return;
    if (theMovie.playbackState == MPMoviePlaybackStateSeekingForward) return;
    self.currentPlaybackTime = theMovie.currentPlaybackTime;
    int tMins = (int)(theMovie.currentPlaybackTime/60) % 60;
    int tMins1 = (int)(theMovie.duration/60) % 60;
    NSLog(@"currentPlaybackTime:%@",[self strFormatTime:theMovie.currentPlaybackTime]);
    if (tMins>=2 || tMins1<=5) {
        [theMovie stop];
        [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
        _sku=@"";
        _language=@"";
        theMovie = nil;
        [self removeObserverNotification1];
        if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"preview"]==NO && [[dataLog allKeys] containsObject:@"vduration"]) {
            float duration = [[dataLog valueForKey:@"vduration"] floatValue];
            long timePlayer = [[dataLog valueForKey:@"vtimeplayer"] intValue];
            long trueTimePlayer =0;
            //if (timePlayer==0) {
                //trueTimePlayer = duration;
            if(totalTimeViewed>0){
                trueTimePlayer =totalTimeViewed +  timePlayer - endPlayer;
            }else{
                trueTimePlayer = timePlayer;
            }
            trueTimePlayer = labs(trueTimePlayer);
            NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease]; df.dateFormat = @"HH:mm:ss";
            float percent_play =   ((float)trueTimePlayer / duration) * 100;
            [dataLog setValue:@"complete" forKeyPath:@"status"];
            [dataLog setValue:[NSString stringWithFormat:@"%ld",trueTimePlayer] forKeyPath:@"truetime_play"];
            [dataLog setValue:[NSString stringWithFormat:@"%.02f",percent_play] forKeyPath:@"percent_play"];
            [dataLog setValue:[df stringFromDate:[NSDate date]] forKeyPath:@"end_play"];
            [[dbCore sharedInstance] saveWatchLog:dataLog];
        }
        
        [dataLog removeAllObjects];
        dataLog = nil;
        totalTimeViewed = 0;
        endPlayer = 0;
        beginPlayer = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
}
-(void) playbackIsPreparedToPlayDidChange1:(NSNotification*)notification{
    MPMoviePlayerController *moviePlayer = notification.object;
    if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"stream"]) {
        if (totalTimeViewed ==0) {
            totalTimeViewed = beginPlayer;
        }else if(beginPlayer>endPlayer){
            totalTimeViewed += (beginPlayer-endPlayer);
        }
        endPlayer = moviePlayer.currentPlaybackTime;
        beginPlayer =0;
    }
    
}
- (NSString*)strFormatTime:(int) value{
    int tHours=value/3600;
    int tMins = (int)(value/60) % 60;
    int tSecs= value % 60;
    return [NSString stringWithFormat:@"%i:%02d:%02d", tHours, tMins, tSecs];
}
- (void) oznozMoviePlayer:(NSString *)strFile TypePlay:(NSString *)typePlay{
    //begin logs stats video
    if (self.popoverController!=nil) {
        [self.popoverController dismissPopoverAnimated:NO];
    }
    beginPlayer = 0;
    endPlayer = 0;
    totalTimeViewed = 0;
    if (dataLog!=nil) {
        [dataLog release];
    }
    dataLog = [[NSMutableDictionary alloc] init];
    Product *pro = [[dbCore sharedInstance] productBySKU:_sku];
    NSString *watchType = @"";
    
    [dataLog setValue:[NSString stringWithFormat:@"%ld",(long)pro.entityId] forKey:@"episodeId"];
    if ([episodeWatchType isEqualToString:@"watchFreeOneDay"]) {
        [dataLog setValue:episodeWatchType forKeyPath:@"watch_type"];
    }else{
        if ([typePlay isEqualToString:@"local"]) {
            watchType = @"download-";
        }
        
        if ([typePlay isEqualToString:@"preview"]) {
            [dataLog setValue:@"preview" forKeyPath:@"watch_type"];
        }else{
            if(pro.hasBought==FALSE || pro.price==0){
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscriber"] isEqualToString:@"TRUE"]==TRUE
                   &&[[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_subscription_expired"] isEqualToString:@"FALSE"]){
                    
                    [dataLog setValue:[NSString stringWithFormat:@"%@subscription",watchType] forKeyPath:@"watch_type"];
                }else{
                    [dataLog setValue:[NSString stringWithFormat:@"%@freeEpisode",watchType] forKeyPath:@"watch_type"];
                }
            }else{
                [dataLog setValue:[NSString stringWithFormat:@"%@purchased",watchType] forKeyPath:@"watch_type"];
            }
        }
    }
    
    [dataLog setValue:[NSString stringWithFormat:@"%ld",(long)brand_id] forKeyPath:@"brand_id"];
    
    NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [NSDate date];
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"date_play"];
    
    df.dateFormat = @"HH:mm:ss";
    [dataLog setValue:[df stringFromDate:date] forKeyPath:@"begin_play"];
    [dataLog setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_username_preference"] forKeyPath:@"email"];
    [dataLog setValue:@"watchvideo" forKeyPath:@"command"];
    [dataLog setValue:@"playing" forKeyPath:@"status"];
    [dataLog setValue:_sku forKeyPath:@"sku"];
    [dataLog setValue:_language forKeyPath:@"language"];
    
    
    [self addObserverNotification];
    NSURL* videoURL = nil;
    if ([typePlay isEqualToString:@"local"]) {
        //videoURL =  [NSURL fileURLWithPath:[self storageDirectory:strFile]];
        videoURL =  [NSURL fileURLWithPath:strFile];
        [dataLog setValue:@"local" forKeyPath:@"typePlayer"];
    }else if([typePlay isEqualToString:@"stream"]){
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"stream" forKeyPath:@"typePlayer"];
    }else{
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strFile]];
        [dataLog setValue:@"preview" forKeyPath:@"typePlayer"];
    }
    //end log stats video
    
    MPMoviePlayerViewController *theMovieController = [[MPMoviePlayerViewController alloc] initWithContentURL: videoURL];
	MPMoviePlayerController* theMovie = [theMovieController moviePlayer];
    [theMovie setFullscreen:YES];
    [[theMovieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];//MPMovieControlStyleFullscreen

    [[NSNotificationCenter defaultCenter]
	 addObserver: self selector: @selector(myMovieFinishedCallback:) name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
    theMovie.allowsAirPlay=TRUE;
    theMovie.useApplicationAudioSession = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"oznoztv_nextepisode1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIButton *doneButton = MoviePlayerControllerDoneButton(theMovie);
    [doneButton addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    
	[theMovie prepareToPlay];
    [self presentModalViewController:theMovieController animated:NO];
    [[theMovieController moviePlayer] play];
   
}

-(void) myMovieFinishedCallbackWatchAll: (NSNotification*) aNotification
{
    NSLog(@"myMovieFinishedCallbackWatchAll");
    MPMoviePlayerController* theMovie = [aNotification object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
    theMovie = nil;
    //[[[[UIApplication sharedApplication] keyWindow] viewWithTag:919191919] removeFromSuperview];
    [self removeObserverNotification];
    if ([[dataLog allKeys] containsObject:@"vduration"]) {
        float duration = [[dataLog valueForKey:@"vduration"] floatValue];
        long timePlayer = [[dataLog valueForKey:@"vtimeplayer"] intValue];
        long trueTimePlayer =0;
        /*if (timePlayer==0) {
            trueTimePlayer = duration;
        }else */if(totalTimeViewed>0){
            trueTimePlayer =totalTimeViewed +  timePlayer - endPlayer;
        }else{
            trueTimePlayer = timePlayer;
        }
        NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease]; df.dateFormat = @"HH:mm:ss";
        float percent_play =   ((float)trueTimePlayer / duration) * 100;
        [dataLog setValue:@"complete" forKeyPath:@"status"];
        [dataLog setValue:[NSString stringWithFormat:@"%ld",trueTimePlayer] forKeyPath:@"truetime_play"];
        [dataLog setValue:[NSString stringWithFormat:@"%.02f",percent_play] forKeyPath:@"percent_play"];
        [dataLog setValue:[df stringFromDate:[NSDate date]] forKeyPath:@"end_play"];
        [[dbCore sharedInstance] saveWatchLog:dataLog];
    }
    
    //NSDate *tmpd = [NSDate date];[tmpd timeIntervalSinceDate:beginDate];
    [dataLog removeAllObjects];
    dataLog = nil;
    totalTimeViewed = 0;
    endPlayer = 0;
    beginPlayer = 0;
   // _sku=@"";
   // _language=@"";
 if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_nextepisode1"] isEqualToString:@"0"]){
    dispatch_async(dispatch_get_main_queue(), ^{
        Product *info =[[Product alloc]init];
        NSArray  *seasons = [[dbCore sharedInstance] syncSeasonsByBrand:brand_id];
        Brand *tmpBrand= [[dbCore sharedInstance] brandByBrandId:brand_id];
        NSLog(@"seasonIndex:%ld",(long)seasonIndex);
        NSLog(@"volumeIndex:%ld",(long)volumeIndex);
        if(seasonIndex>0){
            tmpBrand=  [[dbCore sharedInstance] brandByBrandId:[[[seasons objectAtIndex:seasonIndex] objectForKey:@"brands_id"] integerValue]];
        }
        NSMutableArray  * volumes=[[dbCore sharedInstance] volumeListbyBrand:tmpBrand];
        for (int i=0; i<[volumes count]; i++) {
            
            
            Volume *row=[volumes objectAtIndex:i];
            NSLog(@"row.Season:%@",row.Season);
            NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
            for (int j=0; j<[episodes count]; j++) {
                info = [episodes objectAtIndex:j];
                if([info.sku containsString:_sku] ){
                    _sku=info.sku;
                    volumeIndex =  i;
                    playIndex =  j;
                    goto next;break;
                }
                
            }
            
            
        }
    next:
        
        
        info =[[dbCore sharedInstance] productBySKU:_sku];
        Volume *volume = [[dbCore sharedInstance] volumeExist:info.volume_id];
        NSLog(@"row.Season:%@",volume.Season);
        NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:volume.VolumeId ByBrandID:tmpBrand.brandsId];
        
        NSLog(@"seasons:%ld",(long)[seasons count]);
        if(playIndex >= 0 && playIndex < ([episodes count]-1 ))
        {
            NSLog(@"next episode");
            NSLog(@"seasonIndex:%ld",(long)seasonIndex);
            NSLog(@"volumeIndex:%ld",(long)volumeIndex);
            playIndex++;
            Product* nextInfo =[episodes objectAtIndex:playIndex];
            _sku =nextInfo.sku;
            
            [self watchAllPlay:_sku withLanguage:_language];
        }else{
            NSLog(@"next volume");
            
            //next volume
            playIndex =  -1;
            Volume *row=[volumes objectAtIndex:volumeIndex];
            NSLog(@"row.Season:%@",volume.Season);
            volumeIndex=volumeIndex+1;
            NSLog(@"seasonIndex:%ld",(long)seasonIndex);
            NSLog(@"volumeIndex:%ld",(long)volumeIndex);
            // NSLog(@"[volumes count]:%ld",(long)[volumes count]);
            if(volumeIndex >= 0 && volumeIndex < [volumes count])
            {
                row=[volumes objectAtIndex:volumeIndex];
                //   NSLog(@"volumeIndex:%ld",(long)volumeIndex);
                //   NSLog(@"row.VolumeId:%ld",(long)row.VolumeId);
                
                episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
                playIndex++;
                if(playIndex >= 0 && playIndex < [episodes count])
                {
                    
                    Product* nextInfo =[episodes objectAtIndex:playIndex];
                    _sku =nextInfo.sku;
                    
                    [self watchAllPlay:_sku withLanguage:_language];
                }
            }else if(seasonIndex >= 0 && seasonIndex < ([seasons count]-1)){
                //next volume.Season
                seasonIndex++;
                NSLog(@"next volume.Season");
                volumeIndex=0;
                playIndex=0;
                 if([seasons count]>0 && seasonIndex<[seasons count]){
                NSDictionary *item= [seasons objectAtIndex:seasonIndex];
                Brand *tmpBrand= [[dbCore sharedInstance] brandByBrandId:[[item objectForKey:@"brands_id"] integerValue]];
                NSMutableArray  * volumes=[[dbCore sharedInstance] volumeListbyBrand:tmpBrand Season:[[item objectForKey:@"season"] integerValue]];
                if([volumes  count]>0){
                    Volume *row=[volumes objectAtIndex:volumeIndex];
                    
                    NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
                    if([episodes count]>0){
                        info = [episodes objectAtIndex:playIndex];
                        _sku=info.sku;
                        [self watchAllPlay:_sku withLanguage:_language];
                        
                    }
                }
                 }else{
                     //end
                 }
            }
            
        }
    });
 }
  
}

-(void) myMovieFinishedCallback: (NSNotification*) aNotification
{
    NSLog(@"myMovieFinishedCallback");
    MPMoviePlayerController* theMovie = [aNotification object];
    [theMovie stop];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
    theMovie = nil;
    [self removeObserverNotification];
    if ([[dataLog allKeys] containsObject:@"vduration"]) {
        float duration = [[dataLog valueForKey:@"vduration"] floatValue];
        long timePlayer = [[dataLog valueForKey:@"vtimeplayer"] intValue];
        long trueTimePlayer =0;
        /*if (timePlayer==0) {
            trueTimePlayer = duration;
        }else */if(totalTimeViewed>0){
            trueTimePlayer =totalTimeViewed +  timePlayer - endPlayer;
        }else{
            trueTimePlayer = timePlayer;
        }
        NSString *episodeId = [dataLog valueForKey:@"episodeId"];
        NSDateFormatter* df = [[[NSDateFormatter alloc]init] autorelease]; df.dateFormat = @"HH:mm:ss";
        float percent_play =   ((float)trueTimePlayer / duration) * 100;
        [dataLog setValue:@"complete" forKeyPath:@"status"];
        [dataLog setValue:[NSString stringWithFormat:@"%ld",trueTimePlayer] forKeyPath:@"truetime_play"];
        [dataLog setValue:[NSString stringWithFormat:@"%.02f",percent_play] forKeyPath:@"percent_play"];
        [dataLog setValue:[df stringFromDate:[NSDate date]] forKeyPath:@"end_play"];
        [[dbCore sharedInstance] saveWatchLog:dataLog];
        if ([episodeWatchType isEqualToString:@"watchFreeOneDay"]) {
            NSUserDefaults *oznozUser = [NSUserDefaults standardUserDefaults];
            float timeDelay = 120;
            float timePercent = 0.15;
            if ([oznozUser valueForKey:@"oznoztv_episode_one_day_delay"]!=nil) {
                timeDelay = [[oznozUser valueForKey:@"oznoztv_episode_one_day_delay"] floatValue];
            }
            
            if ([oznozUser valueForKey:@"oznoztv_episode_one_day_percent"]!=nil) {
                timePercent = [[oznozUser valueForKey:@"oznoztv_episode_one_day_percent"] floatValue];
            }
            
            if (trueTimePlayer>=timeDelay || (trueTimePlayer>(duration*timePercent) && duration<780)) {
                [oznozUser setObject:episodeId forKey:@"oznoztv_episode_one_day"];
                [oznozUser synchronize];
                [tableView reloadData];
                
            }
            [[dbCore sharedInstance] postWatchPlayEpisodeOneday];
            [dataLog removeAllObjects];
            return;
        }
    }
    
    //NSDate *tmpd = [NSDate date];[tmpd timeIntervalSinceDate:beginDate];
    [dataLog removeAllObjects];
    dataLog = nil;
    totalTimeViewed = 0;
    endPlayer = 0;
    beginPlayer = 0;
  //  _sku=@"";
  //  _language=@"";
    
    return;
   if([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_nextepisode"] isEqualToString:@"1"]){//NSLog(@"oznoztv_nextepisode");
        dispatch_async(dispatch_get_main_queue(), ^{
             Product *info =[[Product alloc]init];
            NSArray  *seasons = [[dbCore sharedInstance] syncSeasonsByBrand:brand_id];
            Brand *tmpBrand= [[dbCore sharedInstance] brandByBrandId:brand_id];
            NSLog(@"seasonIndex:%ld",(long)seasonIndex);
            NSLog(@"volumeIndex:%ld",(long)volumeIndex);
            if(seasonIndex>0){
                tmpBrand=  [[dbCore sharedInstance] brandByBrandId:[[[seasons objectAtIndex:seasonIndex] objectForKey:@"brands_id"] integerValue]];
            }
            NSMutableArray  * volumes=[[dbCore sharedInstance] volumeListbyBrand:tmpBrand];
            for (int i=0; i<[volumes count]; i++) {
               
                  
                    Volume *row=[volumes objectAtIndex:i];
                    NSLog(@"row.Season:%@",row.Season);
                    NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
                    for (int j=0; j<[episodes count]; j++) {
                        info = [episodes objectAtIndex:j];
                        if([info.sku containsString:_sku] ){
                            _sku=info.sku;
                            volumeIndex =  i;
                            playIndex =  j;
                            goto next;break;
                        }
                        
                    }
             
              
            }
        next:
            
           
          info =[[dbCore sharedInstance] productBySKU:_sku];
          Volume *volume = [[dbCore sharedInstance] volumeExist:info.volume_id];
            NSLog(@"row.Season:%@",volume.Season);
          NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:volume.VolumeId ByBrandID:tmpBrand.brandsId];
            
            NSLog(@"seasons:%ld",(long)[seasons count]);
            if(playIndex >= 0 && playIndex < ([episodes count]-1 ))
            {
                NSLog(@"next episode");
                NSLog(@"seasonIndex:%ld",(long)seasonIndex);
                NSLog(@"volumeIndex:%ld",(long)volumeIndex);
                playIndex++;
                Product* nextInfo =[episodes objectAtIndex:playIndex];
                _sku =nextInfo.sku;
              
                 [self watchPlay:_sku withLanguage:_language];
            }else{
                NSLog(@"next volume");
                
                //next volume
                 playIndex =  -1;
                Volume *row=[volumes objectAtIndex:volumeIndex];
                NSLog(@"row.Season:%@",volume.Season);
                 volumeIndex=volumeIndex+1;
                NSLog(@"seasonIndex:%ld",(long)seasonIndex);
                NSLog(@"volumeIndex:%ld",(long)volumeIndex);
               // NSLog(@"[volumes count]:%ld",(long)[volumes count]);
                if(volumeIndex >= 0 && volumeIndex < [volumes count])
                {
                    row=[volumes objectAtIndex:volumeIndex];
                 //   NSLog(@"volumeIndex:%ld",(long)volumeIndex);
                 //   NSLog(@"row.VolumeId:%ld",(long)row.VolumeId);

                    episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
                   playIndex++;
                    if(playIndex >= 0 && playIndex < [episodes count])
                    {
                        
                        Product* nextInfo =[episodes objectAtIndex:playIndex];
                        _sku =nextInfo.sku;
                      
                         [self watchPlay:_sku withLanguage:_language];
                    }
                }else if(seasonIndex >= 0 && seasonIndex < ([seasons count]-1)){
                    //next volume.Season
                     seasonIndex++;
                    NSLog(@"next volume.Season");
                    volumeIndex=0;
                    playIndex=0;
                    if([seasons count]>0 && seasonIndex<[seasons count]){
                        NSDictionary *item= [seasons objectAtIndex:seasonIndex];
                        Brand *tmpBrand= [[dbCore sharedInstance] brandByBrandId:[[item objectForKey:@"brands_id"] integerValue]];
                        NSMutableArray  * volumes=[[dbCore sharedInstance] volumeListbyBrand:tmpBrand Season:[[item objectForKey:@"season"] integerValue]];
                        if([volumes  count]>0){
                            Volume *row=[volumes objectAtIndex:volumeIndex];
                            
                            NSMutableArray  *episodes = [[dbCore sharedInstance] productListByVolumeID:row.VolumeId ByBrandID:tmpBrand.brandsId];
                            if([episodes count]>0){
                                info = [episodes objectAtIndex:playIndex];
                                _sku=info.sku;
                                [self watchPlay:_sku withLanguage:_language];
                                
                            }
                        }
                    }else{
                        //end
                    }
                    
                
                }
                
            }

      
        });
    }


    
}
-(void)addObserverNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
}
-(void)removeObserverNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
}
-(void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    if (moviePlayer.currentPlaybackTime>0) {
        [dataLog setValue:[self strFormatTime:moviePlayer.duration] forKey:@"duration"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.duration] forKey:@"vduration"];
        
        [dataLog setValue:[self strFormatTime:moviePlayer.currentPlaybackTime] forKeyPath:@"time_play"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.currentPlaybackTime] forKey:@"vtimeplayer"];
        NSLog(@"moviePlayerPlaybackStateDidChange: %f",moviePlayer.currentPlaybackTime);
    }
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped:
            NSLog(@"MPMoviePlaybackStateStopped");
            
            
            break;
        case MPMoviePlaybackStatePlaying:
            NSLog(@"MPMoviePlaybackStatePlaying: %f",moviePlayer.currentPlaybackTime);
            if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"local"] && beginPlayer>0) {
                if (totalTimeViewed ==0) {
                    totalTimeViewed = beginPlayer;
                }else if(beginPlayer>endPlayer){
                    totalTimeViewed += (beginPlayer-endPlayer);
                }
                endPlayer = moviePlayer.currentPlaybackTime;
                beginPlayer = 0;
            }
            break;
        case MPMoviePlaybackStatePaused:
            //totalTimeViewed = totalTimeViewed + [[NSDate date] timeIntervalSinceDate:beginDate];
          //  NSLog(@"MPMoviePlaybackStatePaused");
            break;
        case MPMoviePlaybackStateInterrupted:
            break;
        case MPMoviePlaybackStateSeekingBackward:
           // NSLog(@"MPMoviePlaybackStateSeekingBackward");
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
        case MPMoviePlaybackStateSeekingForward:
            //[moviePlayer beginSeekingForward];
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
    }
    
}
-(void) moviePlayerPlaybackStateDidChange2:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    if (moviePlayer.currentPlaybackTime>0) {
        [dataLog setValue:[self strFormatTime:moviePlayer.duration] forKey:@"duration"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.duration] forKey:@"vduration"];
        
        [dataLog setValue:[self strFormatTime:moviePlayer.currentPlaybackTime] forKeyPath:@"time_play"];
        [dataLog setValue:[NSString stringWithFormat:@"%f",moviePlayer.currentPlaybackTime] forKey:@"vtimeplayer"];
        NSLog(@"moviePlayerPlaybackStateDidChange: %f",moviePlayer.currentPlaybackTime);
    }
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped:
            NSLog(@"MPMoviePlaybackStateStopped");
     
            break;
        case MPMoviePlaybackStatePlaying:
            NSLog(@"MPMoviePlaybackStatePlaying: %f",moviePlayer.currentPlaybackTime);
            if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"local"] && beginPlayer>0) {
                if (totalTimeViewed ==0) {
                    totalTimeViewed = beginPlayer;
                }else if(beginPlayer>endPlayer){
                    totalTimeViewed += (beginPlayer-endPlayer);
                }
                endPlayer = moviePlayer.currentPlaybackTime;
                beginPlayer = 0;
            }
            
//            if(moviePlayer.currentPlaybackTime == moviePlayer.duration){
//                NSURL* videoURL = nil;
//                NSLog(@"next video");
//                //[[theMovieController moviePlayer] stop];
//                videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://d3mm5apfntsy6t.cloudfront.net/Iconnix/TYO/S01_01/English/002/TAYO_S01_E02_ENG_ios_Main.m3u8"]];
//                [dataLog setValue:@"stream" forKeyPath:@"typePlayer"];
//                [[theMovieController moviePlayer] setContentURL:videoURL];
//                NSTimeInterval toTime = 0.0;
//                [[theMovieController moviePlayer] setInitialPlaybackTime:toTime];
//                [[theMovieController moviePlayer] play];
//            }
            break;
        case MPMoviePlaybackStatePaused:
            //totalTimeViewed = totalTimeViewed + [[NSDate date] timeIntervalSinceDate:beginDate];
            //  NSLog(@"MPMoviePlaybackStatePaused");
            break;
        case MPMoviePlaybackStateInterrupted:
            break;
        case MPMoviePlaybackStateSeekingBackward:
            // NSLog(@"MPMoviePlaybackStateSeekingBackward");
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
        case MPMoviePlaybackStateSeekingForward:
            //[moviePlayer beginSeekingForward];
            beginPlayer = moviePlayer.currentPlaybackTime;
            break;
    }
    
}
-(void) playbackIsPreparedToPlayDidChange:(NSNotification*)notification{
    MPMoviePlayerController *moviePlayer = notification.object;
    if ([[dataLog valueForKey:@"typePlayer"] isEqualToString:@"stream"]) {
        if (totalTimeViewed ==0) {
            totalTimeViewed = beginPlayer;
        }else if(beginPlayer>endPlayer){
            totalTimeViewed += (beginPlayer-endPlayer);
        }
        endPlayer = moviePlayer.currentPlaybackTime;
        beginPlayer =0;
    }
    
}

#pragma mark -
#pragma mark Download and Watch Action
- (void)reloadDataDownload{
    /*NSMutableArray *_datasource=(NSMutableArray *)[[dbCore sharedInstance] downloadList:@"0"];
    
    NSInteger totalDl=[_datasource count];
    if ( totalDl > 0) {
        [[[[[self tabBarController] viewControllers] objectAtIndex: 3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)totalDl]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalDl;
    }else
    {   [[[[[self tabBarController] viewControllers] objectAtIndex: 3] tabBarItem] setBadgeValue:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = nil;
    }*/
    
    //self.tabBarController.selectedViewController = [[self.tabBarController viewControllers] objectAtIndex:3];
    NSMutableArray *_datasource=(NSMutableArray *)[[dbCore sharedInstance] downloadList:@"0"];
    NSInteger totalDL=[_datasource count];
    if ( totalDL > 0) {
        if (_btDownload!=nil) {
            _btDownload.hidden = TRUE;
        }
        [[[[[self tabBarController] viewControllers] objectAtIndex: 3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)totalDL]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalDL;
    }else{
        [[[[[self tabBarController] viewControllers] objectAtIndex: 3] tabBarItem] setBadgeValue:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = nil;
    }
    for(UIViewController *view in [[[self.tabBarController viewControllers] objectAtIndex:3] viewControllers]) {
        if([view isKindOfClass:[DownloadsViewController_iPad class]]){
            [(DownloadsViewController_iPad *)view performSelectorOnMainThread:@selector(reloadDatabase) withObject:nil waitUntilDone:NO];
        }
    }
}
-(void) downloadPlay:(NSString *)sku withLanguage:(NSString *)language
{
    if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
        [[dbCore sharedInstance] syncDownloadAPI:sku withLanguage:language];
        [self performSelectorOnMainThread:@selector(reloadDataDownload) withObject:nil waitUntilDone:NO];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Attention"
                              message: @"You cannot watch or download in offline mode."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}
-(void) watchPlay:(NSString *)sku withLanguage:(NSString *)language
{
//#if TARGET_IPHONE_SIMULATOR
   
//        playVideo = YES;
//        
//        _sku=sku;
//        _language=language;
//        
//        Download *dict = [[dbCore sharedInstance] downloadWithSKU:sku withLanguage:language];
//        NSString *filePath    = [self storageDirectory:[NSString stringWithFormat:@"%@",dict.file]];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if(dict!= nil){
//            if ([fileManager fileExistsAtPath:filePath]) {
//                [self oznozMoviePlayer:filePath TypePlay:@"local"];
//            }
//        }else{
//            if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
//                
//                NSString *watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:_language];
//                NSLog(@"watch_url:%@",watch_url);
//                NSLog(@"sku:%@",sku);
//                NSLog(@"language:%@",_language);
//                
//               
//                dispatch_async(dispatch_get_main_queue(), ^ {
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
//                    OznozVideoPlayerViewController *videoplayer = [storyboard instantiateViewControllerWithIdentifier:@"OznozVideoPlayerViewController"];
//                    videoplayer.accessibilityValue =[Utils getJsonString:@{@"brand_id":[@(brand.brandsId) stringValue],
//                                                                           @"property_id":[@(brand.property_id) stringValue],
//                                                                           @"sku":sku,
//                                                                           @"language":language,
//                                                                           @"watch_type":@"",
//                                                                           @"videoURL":watch_url}];
//                    //videoplayer.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//                    videoplayer.modalPresentationStyle = UIModalPresentationFullScreen;
//                     [self presentViewController:videoplayer animated:NO completion:nil];
//                });
//               
//                
//            }else{
//                UIAlertView *alert = [[UIAlertView alloc]
//                                      initWithTitle: @"Attention"
//                                      message: @"You cannot watch or download in offline mode."
//                                      delegate: nil
//                                      cancelButtonTitle:@"OK"
//                                      otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//        }
//        

    
    
//#elif TARGET_OS_IPHONE
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_nextepisode1"] isEqualToString:@"0"] ) {
        playVideo = YES;
        
        _sku=sku;
        _language=language;
        
        Download *dict = [[dbCore sharedInstance] downloadWithSKU:sku withLanguage:language];
        NSString *filePath    = [self storageDirectory:[NSString stringWithFormat:@"%@",dict.file]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(dict!= nil){
            if ([fileManager fileExistsAtPath:filePath]) {
                [self oznozMoviePlayer:filePath TypePlay:@"local"];
            }
        }else{
            if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
                
                NSString *watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:_language];
                NSLog(@"watch_url:%@",watch_url);
                NSLog(@"sku:%@",sku);
                NSLog(@"language:%@",language);
                //  NSLog(@"playLanguages:%@",playLanguages);
                if([watch_url containsString:@".m3u8"])
                    [self oznozMoviePlayer:watch_url TypePlay:@"stream"];
                else
                    [self myMovieFinishedCallback:NULL];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Attention"
                                      message: @"You cannot watch or download in offline mode."
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        
        
    }
//#endif
    


   

}
-(void) watchPreviewPlay:(NSString *)sku withLanguage:(NSString *)language
{
    playVideo = YES;
    _sku=sku;
    _language=language;

    if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
        NSString *watch_url=[[dbCore sharedInstance] watchPreviewURL:sku withLanguage:language];
          NSLog(@"watch_url:%@",watch_url);
        if([watch_url isEqualToString:@"http://oznoz.com/preview.mp4"] ){
            watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:language];
            [self oznozMoviePlayerPreview:watch_url TypePlay:@"preview"];
        }else if([watch_url length] == 0){
            watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:language];
            NSLog(@"watch_url1:%@",watch_url);
            if([watch_url length] > 0)
                [self oznozMoviePlayerPreview:watch_url TypePlay:@"preview"];
        }else
            [self oznozMoviePlayer:watch_url TypePlay:@"preview"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Attention"
                              message: @"You cannot watch or download in offline mode."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}
-(void) watchAllPlay:(NSString *)sku withLanguage:(NSString *)language
{
//    playVideo = YES;
//    
//    _sku=sku;
//    _language=language;
//    
//    Download *dict = [[dbCore sharedInstance] downloadWithSKU:sku withLanguage:language];
//    NSString *filePath    = [self storageDirectory:[NSString stringWithFormat:@"%@",dict.file]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if(dict!= nil){
//        if ([fileManager fileExistsAtPath:filePath]) {
//            [self oznozMoviePlayer:filePath TypePlay:@"local"];
//        }
//    }else{
//        if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
//            
//            NSString *watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:_language];
//            NSLog(@"watch_url:%@",watch_url);
//            NSLog(@"sku:%@",sku);
//            NSLog(@"language:%@",_language);
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^ {
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
//                OznozVideoPlayerViewController *videoplayer = [storyboard instantiateViewControllerWithIdentifier:@"OznozVideoPlayerViewController"];
//                videoplayer.accessibilityValue =[Utils getJsonString:@{@"brand_id":[@(brand.brandsId) stringValue],
//                                                                       @"property_id":[@(brand.property_id) stringValue],
//                                                                       @"sku":sku,
//                                                                       @"language":language,
//                                                                       @"watch_type":@"",
//                                                                       @"videoURL":watch_url}];
//                //videoplayer.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//                videoplayer.modalPresentationStyle = UIModalPresentationFullScreen;
//                [self presentViewController:videoplayer animated:NO completion:nil];
//            });
//            
//            
//        }else{
//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle: @"Attention"
//                                  message: @"You cannot watch or download in offline mode."
//                                  delegate: nil
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
//    }
     if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_nextepisode1"] isEqualToString:@"0"] ) {
    playVideo = YES;

    _sku=sku;
    _language=language;
         
    Download *dict = [[dbCore sharedInstance] downloadWithSKU:sku withLanguage:language];
         NSString *filePath    = [self storageDirectory:[NSString stringWithFormat:@"%@",dict.file]];
         NSFileManager *fileManager = [NSFileManager defaultManager];
         if(dict!= nil){
             if ([fileManager fileExistsAtPath:filePath]) {
                 [self oznozMoviePlayerWatchAll:filePath TypePlay:@"local"];
             }
         }else{
             if ([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable) {
                 NSString *watch_url=[[dbCore sharedInstance] watchURL:sku withLanguage:language];
                 NSLog(@"watch_url:%@",watch_url);
                 NSLog(@"sku:%@",sku);
                 NSLog(@"language:%@",language);
                 if([watch_url containsString:@".m3u8"]){//cloudfront.net/
//                     if(theMovieController != NULL){
//                         NSURL* videoURL = nil;
//                         videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",watch_url]];
//                         [dataLog setValue:@"stream" forKeyPath:@"typePlayer"];
//                         [[theMovieController moviePlayer] setContentURL:videoURL];
//                         NSTimeInterval toTime = 0.0;
//                         [[theMovieController moviePlayer] setInitialPlaybackTime:toTime];
//                         [[theMovieController moviePlayer] play];
//                     }else
//                 
                     [self oznozMoviePlayerWatchAll:watch_url TypePlay:@"stream"];
                 }else{
                     [self myMovieFinishedCallbackWatchAll:NULL];
                 }
             }else{
                 UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle: @"Attention"
                                       message: @"You cannot watch or download in offline mode."
                                       delegate: nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                 [alert show];
                 [alert release];
             }
         }
   

     }
}
- (void) addToolBar
{
    ToolBar *tools = [[ToolBar alloc] initWithFrame:CGRectMake(0,0, 300, 45)];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSString *LanguagesTitle=@"All Languages";
    UIImage *bg_filter = [UIImage imageNamed:@"border_gray_ios7.png"];
    UIColor *color=[UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    
    //UIColor *color=[UIColor whiteColor];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] length] > 0 ) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"] isEqualToString:@"All"]) {
            LanguagesTitle=@"All Languages";
            
        }else
        {
            color=[UIColor whiteColor];
            //color=[UIColor colorWithRed:237/255.0 green:0/255.0 blue:140/255.0 alpha:1];
            LanguagesTitle=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_language"]];
            bg_filter = [UIImage imageNamed:@"border_red_ios7.png"];
        }
    }
    CGSize lblTitleSize = [LanguagesTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    
    UIButton *btnLanguages = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLanguages.userInteractionEnabled = YES;
    [btnLanguages setFrame:CGRectMake(5,0.0, (lblTitleSize.width<70)?100:(lblTitleSize.width+20), 28.0)];
    [btnLanguages setBackgroundImage:bg_filter forState:UIControlStateNormal];
    [btnLanguages setTitle:LanguagesTitle forState: UIControlStateNormal];
    btnLanguages.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnLanguages setTitleColor:color forState:UIControlStateNormal];
    [btnLanguages addTarget:self action:@selector(languagesClick:)    forControlEvents:UIControlEventTouchUpInside];
    //    UITapGestureRecognizer *tappedLanguages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(languagesClick:)];
    //    tappedLanguages.numberOfTapsRequired = 1;
    //    [btnLanguages addGestureRecognizer:tappedLanguages];
    [btnLanguages setNeedsDisplay];
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithCustomView:btnLanguages];
    [buttons addObject:bi];
    
    bg_filter = [UIImage imageNamed:@"border_gray_ios7.png"];
    //color=[UIColor colorWithRed:177/255.0 green:181/255.0 blue: 193/255.0 alpha:1];
    color=[UIColor colorWithRed:102/255.0 green:102/255.0 blue: 102/255.0 alpha:1];
    NSString *ageTitle=@"Select Age";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] length] > 0 ) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"] isEqualToString:@"All"]) {
            ageTitle=@"Select Age";
        }else
        {
            color=[UIColor whiteColor];
            //color=[UIColor colorWithRed:237/255.0 green:0/255.0 blue:140/255.0 alpha:1];
            ageTitle=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_age"]];
            bg_filter = [UIImage imageNamed:@"border_red_ios7.png"];
        }
    }
    lblTitleSize = [ageTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    UIButton *btnAgeFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAgeFilter.userInteractionEnabled = YES;
    [btnAgeFilter setFrame:CGRectMake(0.0,0.0, (lblTitleSize.width<70)?100:(lblTitleSize.width), 28.0)];
    [btnAgeFilter setBackgroundImage:bg_filter forState:UIControlStateNormal];
    [btnAgeFilter setTitle:ageTitle forState: UIControlStateNormal ];
    btnAgeFilter.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnAgeFilter setTitleColor:color forState:UIControlStateNormal];
    [btnAgeFilter addTarget:self action:@selector(ageFilterClick:)    forControlEvents:UIControlEventTouchUpInside];
    //    UITapGestureRecognizer *tappedAgeFilter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ageFilterClick:)];
    //    tappedAgeFilter.numberOfTapsRequired = 1;
    //    [btnAgeFilter addGestureRecognizer:tappedAgeFilter];
    [btnAgeFilter setNeedsDisplay];
    bi = [[UIBarButtonItem alloc] initWithCustomView:btnAgeFilter];
    bi.tintColor=color;
    [buttons addObject:bi];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setBackgroundImage: [UIImage imageNamed: @"ico_search_ios7.png"] forState:UIControlStateNormal];
    [btnSearch setBackgroundImage: [UIImage imageNamed: @"ico_search_ios7.png"] forState:UIControlStateHighlighted];
    btnSearch.frame= CGRectMake(0, 0, 20, 20);
    [btnSearch addTarget:self action:@selector(searchClick:)    forControlEvents:UIControlEventTouchUpInside];
    
    bi = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    //bi.width=20;
    [buttons addObject:bi];
    
    UIButton *btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSetting setBackgroundImage: [UIImage imageNamed: @"ico_setting_ios7.png"] forState:UIControlStateNormal];
    [btnSetting setBackgroundImage: [UIImage imageNamed: @"ico_setting_ios7.png"] forState:UIControlStateHighlighted];
    btnSetting.frame= CGRectMake(0, 0, 20, 20);
    [btnSetting addTarget:self action:@selector(settingList:)    forControlEvents:UIControlEventTouchUpInside];
    
    bi = [[UIBarButtonItem alloc] initWithCustomView:btnSetting];
    //bi.width=20;
    [buttons addObject:bi];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [buttons addObject:spacer];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *negativeSeparator=[[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = negativeSeparator;

}
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"alertView:%@",[alert title]);
	if ( [[alert title] isEqualToString:@"Search Oznoz Video"]){
		if (buttonIndex != [alert cancelButtonIndex])
		{
            // Clicked the Submit button
            
            NSString *inputText = [[alert textFieldAtIndex:0] text];
            NSUInteger lenght=[inputText length];
            NSString *keyword=inputText;
            if(lenght > 0 ){
                playVideo = YES;
                ResultsViewController_iPad *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SEARCH_VIEW"];
                vc.keyword=keyword;
                [self.navigationController pushViewController:vc animated:NO];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Attention"
                                      message: @"Please try again!"
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            
		}
	}
    
	if ( [[alert title] isEqualToString:@"Are you sure you want to logout?"] || [[alert title] isEqualToString:@"Attention"]){
        if (buttonIndex != [alert cancelButtonIndex])
        {
            [[dbCore sharedInstance] logoutAuth];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate clearLoginData];
            [appDelegate setWindowMod:@"Login"];
        }
    }
    //Restore In App Purchased
    if ( [[alert title] isEqualToString:@"Sync Purchases"]){
        if (buttonIndex != [alert cancelButtonIndex])
        {
            [[dbCore sharedInstance] syncPurchasedBrands];
            [[dbCore sharedInstance] syncUpdateChanged];
            [oznozvolume refeshViewRotation];
            [self reloadDatabase1];
            
        }
    }
    if ( [[alert title] isEqualToString:@"Subscribe Now"]){NSLog(@"Subscribe Now");
        NSString *oznozUuid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztvCustomerUuid"]];
        if ([oznozUuid length]>30) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            PurchaseViewController_iPad *vc = [storyboard instantiateViewControllerWithIdentifier:@"PURCHASE"];
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [vc.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
            
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate clearLoginData];
            [appDelegate setWindowMod:@"Login"];
        }
    }
    
}
#pragma mark MenuSettingsDelegate
- (void)menuSelected:(NSInteger )menu {
    [popoverController dismissPopoverAnimated:FALSE];
    UIViewController *viewController = nil;
    switch (menu) {
        case 3:
            if (([[WPReachability sharedReachability] internetConnectionStatus] != NotReachable)) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to logout?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
                [alert show];
                [alert release];
            }
            break;
        case 0:
            self.title =nil;
            self.playVideo =YES;
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ABOUT_VIEW"];
            viewController.title = @"What is Oznoz";
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        case 1:
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"oznoztv_app_go_skip"] isEqualToString:@"TRUE"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"FALSE" forKey:@"oznoztv_app_go_skip"];
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] setWindowMod:@"Login"];
            }else{
                self.title =nil;
                self.playVideo =YES;
                self.showSubscriber = YES;
                viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MYSUBSCRIPTION_VIEW"];
                viewController.title = @"My Subscription";
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        case 4:
            self.title =nil;
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MYSETTING_VIEW"];
            viewController.title = @"My Setting";
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        case 2:
           
            NSLog(@"Feature Controller");
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"oznoztv_bought"];
            // [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            //}
            break;
            
    }
}
- (IBAction)settingList:(id)sender {//MENUSETTINGS_VIEW
    [popoverController dismissPopoverAnimated:NO];
    MenuSettingsViewController *_mSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"MENUSETTINGS_VIEW"];
    _mSettings.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_mSettings];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:nav];
    nav = nil;
     [popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //[popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _mSettings = nil;
    
}
#pragma mark - Pager
- (void)fetchNextPage
{
    [self.apiPaginator goNextPage:brand_id withVolume:volume_id];
    [self.activityIndicator startAnimating];
}
- (void)setupTableViewFooter
{
    int _width=[[UIScreen mainScreen] applicationFrame].size.width;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    switch(interfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _width=[[UIScreen mainScreen] applicationFrame].size.height;
            break;
        default:
            if (self.view.bounds.size.width==768) {
                _width=self.view.bounds.size.width;
            }
            if (self.view.bounds.size.width==1024) {
                _width=self.view.bounds.size.width;
            }
            if (self.view.bounds.size.width==768 && self.view.bounds.size.height==1004) {
                _width=self.view.bounds.size.width;
            }
            
            break;
    }
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    self.footerLabel.frame=CGRectMake(0, 0, _width, 44);
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(_width/2-11, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if (self.apiPaginator.total > PageSize && ![self.apiPaginator reachedLastPage])
    {
        
        [self.activityIndicator startAnimating];
    } else
    {
        [self.activityIndicator stopAnimating];
    }
    
    [self.footerLabel setNeedsDisplay];
}
#pragma mark - Paginator delegate methods

- (void)paginator:(id)paginator didReceiveResults:(NSMutableArray *)results
{
    if(results!=nil){
        [self.tableView reloadData];
        [self updateTableViewFooter];
    }
    
}

- (void)paginatorDidReset:(id)paginator
{
    [tableView reloadData];
    [self updateTableViewFooter];
}

- (void)paginatorDidFailToRespond:(id)paginator
{
    // Todo
}
#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        if(![self.apiPaginator reachedLastPage])
        {
            [self fetchNextPage];
        }
        
    }
    
}

- (void)dealloc {
    //[self releasaSubviesTable];
    self.apiPaginator.delegate = nil;
    self.tableView.delegate =nil;
    self.tableView.dataSource=nil;
    //[[self.tableView subviews] remo]
    [self.tableView removeFromSuperview];
    //[self.tableView release];
    //[oznozBrand releaseViews];
    [oznozBrand removeFromSuperview];
    
    //[oznozBrand release];
    oznozvolume.datasource = nil;
    oznozvolume.delegate = nil;
    [oznozvolume removeFromSuperview];
    brand = nil;
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self removeFromParentViewController];
    [self.navigationController removeFromParentViewController];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(self.playVideo ==NO){
        [self.navigationController popViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
- (void)vdidDisappear
{
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void) releasaSubviesTable{
    for (int i = 0; i < [tableView numberOfSections]; i++)
    {
        NSInteger rows =  [tableView numberOfRowsInSection:i];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:i];
            EpisodeCell *cell = (EpisodeCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell removeFromSuperview];
        }
    }
}

@end
