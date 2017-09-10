//
//  SyncViewCellTableViewController.m
//  LiteraSync
//
//  Created by Tony Shark on 22/10/2015.
//  Copyright © 2015 Litera. All rights reserved.
//

// If passcode is turned off
// Ask for the new passcode when

// glitchy for the Accounts Pagev - Done

// Folder Name on Top of the - Done

// For the Favorites save the File as a link in a Database
// re-Checking the File Name from the link

// If the file structure does not have access to task server, it should be black...

// If the files, 10 MB.

// Total Count of Files and Folder

// White bg and Trolly Black,

// Move: 1st 2 options moving to root and moving to a folder within the directory, Copy is always...
// Preparing the file for Copy, so that it could have the same file with different Directory
// Copy, is always available in the Option Actionsheet then add Paste if there are available in the Clipboard

// Use icons

// One more missing, Copy to Favorites in Tile View

// Notification list -> Filter the Notification Display on Ipad List View

// Copy should be named as Cut

// Short First Time Course Outline,
// What do you need from me,

// -- UDID

// Sort icon, adjust thickness
// Total File/Folder Label Decrease padding


// LSFT -
// Cancel Option needed
// Done -> Send

// Sort -> Remove Date Modified Red Color
// Sort -> Remove Type

// Add Modules for Send To from other Apps..


// Draft module drop the Attachment Caching for now
// Sort -> Name A-Z , Name Z-A
// Total File Cound Box -> 14px
// Export corrupt


// Aug 22
// Document Viewer Swipe Option and Header : To Fix
// Add Clipboard sticky icon when the Clipboard is activated, and dismissed with option
// Add Download API Adjustments
// Add Upload File SYNC API Adjustments
// Add File Exports SYNC API Adjustments

// Aug 25

// File form my SYNC Duplicate Issue
// iPad LSFT
// Add delimiter for the Tab when you lose focus *
// Clean the HTML Tags for Signature
// iCon issue About Litera
// Sort, the last option should be saved..
// Cache, issue on reappearing files on LSFT
// SYNC add Jira issue for the Upload File Timeout
//
// LSFT Badge Icon adjust
// LSFT Send this File Securely

// Instead of showing popup of LSFT make it show the LSFT Screen as the root controller..

// Offline handlers

// syncbaker.litera.com -> with the new API adjustments
// sync.bakermckenzie.com



#import "SyncViewCellTableViewController.h"
#import "AppDelegate.h"
#import "LSyncAPIClient.h"
#import "Constants.h"
#import "SharedAppFrameworkHeaders.h"
#import "TempStorage.h"
#import "SyncFolder.h"
#import "SWTableViewCell.h"
#import "APIRequests.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "LSFTCreateMessageViewController.h"
#import "NavHomeViewController.h"
#import "DocumentViewerController.h"
#import "iCloudViewController.h"
#import "ShareViewController.h"

#import "ZLMailComposerViewController.h"

#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import <MGSwipeTableCell/MGSwipeButton.h>
#import <QuickLook/QuickLook.h>
#import "UploadFiles.h"

#import "ShareOptViewController.h"

//#import <TWRDownloadManager/TWRDownloadManager.h>

#import "ELCImagePickerController.h"
#import "MRProgress.h"
#import "UploadPhotos.h"

#import "UtilsComponent.h"

#import "DownloaderFiles.h"

@interface SyncViewCell : SWTableViewCell
@property (strong, nonatomic) UIImageView* imgVwFileIndicator;
@property (strong, nonatomic) UILabel* lblFileorFoldername;
@property (strong, nonatomic) UILabel* lblTimePrint;
@property (strong, nonatomic) UILabel* lblFileSize;
@end


@implementation SyncViewCell
int const kRenameFileSD = 7834;
int const kRenameFolderSD = 1332834;
int const kMovetoRootFiles = 8123;
int const kCompareFilesAlrtTag = 93523;
int const kMovetoFavsFiles = 7343;
int const kDeleteFileFolders = 73243;
int const kDisableSyncFolder = 997236;
int const kMoveToOtherFoldersAlrtTag = 9827342;
int const kLSFTAttachFile = 31232;
int SelectedIndex;

int kPaste = 0;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id)delegate{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imgVwFileIndicator = [[UIImageView alloc]init];
        self.lblFileorFoldername = [[UILabel alloc]init];
        self.lblTimePrint = [[UILabel alloc]init];
        self.lblFileSize = [[UILabel alloc]init];
        [self.lblFileSize setFont:[UIFont fontWithName:@"Helvetica" size:8]];
        [self.lblFileSize setTextAlignment:NSTextAlignmentRight];
        
        [self addSubview:self.imgVwFileIndicator];
        [self addSubview:self.lblFileorFoldername];
        [self addSubview:self.lblFileSize];
        [self addSubview:self.lblTimePrint];
        
        [self setDelegate:delegate];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [self.imgVwFileIndicator setFrame:CGRectMake(10, 0, 40, 40)];
    [self.lblFileorFoldername setFrame:CGRectMake(30, 0, 40, 40)];
    [self.lblTimePrint setFrame:CGRectMake(30, 20, 40, 40)];
    [self.lblFileSize setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 40)];
}

@end


@interface SyncViewCellTableViewController ()<SWTableViewCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate, CTAssetsPickerControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, ELCAssetSelectionDelegate, ELCImagePickerControllerDelegate, UITextFieldDelegate, UISearchDisplayDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate,QLPreviewControllerDataSource, QLPreviewControllerDelegate, MGSwipeTableCellDelegate>

@property (strong, nonatomic) NSMutableArray* arrSyncDetails, *arrSearchResult, *arrCompareFile, *arrFolderList;
@property (strong, nonatomic) SyncFolder* insideSyncFolderDetails, *syncFromPush;
@property (strong, nonatomic) NSIndexPath* selectedCellIndex;
@property (strong, nonatomic) UISearchController *searchController;
//@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UISearchDisplayController* searchDspController;
@property (strong, nonatomic) UITableViewController *seachResultController;
@property (strong, nonatomic) UITableView* resultController;
@property (strong, nonatomic) UIRefreshControl* refreshCont;
@property (strong, nonatomic) UILabel* lblTotalFileCnt;
@property (strong, nonatomic) UIDocumentInteractionController* documentInteractionController;
@property (strong, nonatomic) NSString* strSortBy, *strTotalFiles;
@property (strong, nonatomic) SyncFolder* syncSelectedDetails, *syncMoveDetailsFrom;
@property (strong, nonatomic) UIView* vwForTotalFileCount;
@property (strong, nonatomic) NSURL* lsftSelectedFileImportFromSYNC;
@end

int kpageindex = 1;
BOOL bPageLimit = NO;
BOOL bForDocumentExport = NO;
BOOL fileAttachToLSFT = NO;

int const kMoveActSheetTag = 782363412;
int const kFolderOptActSheetTag = 88362364;
int const kFileOptActSheetTag = 991277123;
int const kMovePushToFolderAlertTagiPhone = 334324;
int const kMoveBacktoRootAlertTagiPhone = 2224341;

int const kSyncIphoneSort = 9823430;

int const kLSFTSyncFileDownload = 513313;
NSString* bIsAscending = @"true";


@implementation SyncViewCellTableViewController
//if (self.didDismiss)
//self.didDismiss(@"some extra data");


- (id)initWithSyncFolderDetails:(SyncFolder *)syncDets andViewDisplay:(UITableViewStyle)style{
    
    if (self = [super initWithStyle:style]) {
//        self.insideSyncFolderDetails = [[sy]];
        self.insideSyncFolderDetails = [[SyncFolder alloc]init];
        self.insideSyncFolderDetails = syncDets;
        self.syncFromPush = syncDets;
        [TempStorage SaveCustomKey:gSaveFolderDetailsTemp withValue:syncDets.strFolderId];
//        [self GetSyncData:YES andWithSyncFolderData:syncDets];
        
        if (self.insideSyncFolderDetails.strFolderName.length>1) {
            [self setTitle:self.insideSyncFolderDetails.strFolderName];
        }else{
                [self setTitle:@"Sync"];
        }
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    
    if (self = [super initWithStyle:style]) {
            UIBarButtonItem* btnLeftDrawer = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"399-list1"] style:UIBarButtonItemStyleDone target:self action:@selector(ShowDrawer)];
            [self.navigationItem setLeftBarButtonItem:btnLeftDrawer];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIButton* btnSyncD = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSyncD setFrame:CGRectMake(0, 0, 40, 40)];
    
    [btnSyncD setBackgroundImage:[UIImage imageNamed:@"Upload to the Cloud-1"] forState:UIControlStateNormal];
    [btnSyncD addTarget:self action:@selector(chooseUploadAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* btnSync = [[UIBarButtonItem alloc]initWithCustomView:btnSyncD];
    UIBarButtonItem* btnSync = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(chooseUploadAction)];
    
    UIButton* btniFilter = [UIButton buttonWithType:UIButtonTypeCustom];
    [btniFilter setFrame:CGRectMake(0, 0, 25, 25)];
    
    [btniFilter setBackgroundImage:[UIImage imageNamed:@"Sorting"] forState:UIControlStateNormal];
    [btniFilter addTarget:self action:@selector(filterSync) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* btnFilter = [[UIBarButtonItem alloc]initWithCustomView:btniFilter];
    
    self.syncSelectedDetails = [[SyncFolder alloc]init];
    
    self.refreshCont = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshCont];
    [self.refreshCont addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    if (self.insideSyncFolderDetails.strFolderName.length>1) {
        [self setTitle:self.insideSyncFolderDetails.strFolderName];
    }else{
        [self setTitle:@"Sync"];
    }
    if (!self.isComingFromLSFT) {
        [self.navigationItem setRightBarButtonItems:@[btnSync,btnFilter]];
    }else{
        
        UIBarButtonItem* btnCancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(CancelLSFTViewImport)];
        
        UIBarButtonItem* btnDone = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneLSFTVviewImport)];
        
        if ([self.title isEqualToString:@"Sync"]) {
            [self.navigationItem setLeftBarButtonItem:btnCancel];
        }
        [self.navigationItem setRightBarButtonItem:btnDone];
    }
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
//    UITableView *resultsTableView = [[UITableView alloc]initWithFrame:self.tableView.frame];
//    self.seachResultController=[[UITableViewController alloc]init];
//    self.seachResultController.tableView=resultsTableView;
//    [self.seachResultController.tableView setDelegate:self];
//    [self.seachResultController.tableView setDataSource:self];
//    [self.seachResultController.tableView setTableFooterView:[UIView new]];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SyncCell"];
//    [self.seachResultController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SyncCell"];

//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.seachResultController];
//    self.searchController.searchResultsUpdater = self;
//    self.searchController.dimsBackgroundDuringPresentation = YES;
//    [self.searchController setDelegate:self];
//    [self.searchController.searchBar setBarTintColor:[UIColor colorWithRed:1 green:0.875 blue:0.686 alpha:1]];
//    [self.searchController.searchBar setSearchBarStyle:UISearchBarStyleProminent];
//    [self.searchController.searchBar setBackgroundImage:[[UIImage alloc]init]];
//    self.searchController.searchBar.delegate = self;
//    [self.tableView setTableHeaderView:self.searchController.searchBar];
    
    //Set up search bar
    UISearchBar *mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [mySearchBar setBarTintColor:[UIColor colorWithRed:1 green:0.875 blue:0.686 alpha:1]];
    [mySearchBar setDelegate:self];
//    [mySearchBar setShowsCancelButton:YES animated:NO];
    
    // Set up search display controller
    self.searchDspController= [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    self.searchDspController.delegate = self;
    self.searchDspController.searchResultsDataSource = self;
    self.searchDspController.searchResultsDelegate = self;
    //mySearchController.displaysSearchBarInNavigationBar = YES;
//    self.searchDspController.navigationItem.titleView.opaque = NO;
//    [self.navigationController.navigationBar addSubview:self.searchDisplayController.searchBar];
    [self.tableView setTableHeaderView:self.searchDspController.searchBar];
    
    
    for (UIView *view in self.searchDspController.searchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
    self.arrSyncDetails = [[NSMutableArray alloc]init];
    self.arrSearchResult = [NSMutableArray new];
    self.arrCompareFile = [[NSMutableArray alloc] initWithCapacity:2];
    self.arrFolderList = [NSMutableArray new];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                if ([[TempStorage GetCustomKeyWithValue:tSyncCacheDetails] isKindOfClass:[NSMutableArray class]]) {
                    NSMutableArray* arrFolderList = [TempStorage GetCustomKeyWithValue:tSyncCacheDetails];
                    [self CachedDicts:arrFolderList];
                    
                }else{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Cannot identify your account. Please try again when Internet is available."];
                }
            }
                break;
                
            default:{
                kpageindex = 1;
                [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];

            }
                break;
        }
        
    }];
//    AppDelegate* appDels = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    [appDels.window addSubview:[self vwForTotalFileCount]];
    [self.navigationController.view addSubview:self.vwForTotalFileCount];
    self.strTotalFiles = @"Total File Count";
    self.strSortBy = @"CreatedDate";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PasteClipboardHere) name:sPasteFromClipboard object:nil];
    
     [TempStorage SaveCustomKey:gSaveFolderNameTemp withValue:self.insideSyncFolderDetails.strFolderName];
    
}

- (void)PasteClipboardHere{
    
    
//    NSLog(@"Paste Selected");
    
    
    
    NSDictionary* dctClipboardItem = [TempStorage GetCustomKeyWithValue:sClipboardTempFile];
    
    SyncFolder* clipboardSyncData = [[SyncFolder alloc]init];
    clipboardSyncData.strFolderName = [dctClipboardItem objectForKey:@"FolderName"];
    clipboardSyncData.strFolderId = [dctClipboardItem objectForKey:@"FolderId"];
    clipboardSyncData.strFolderPermission = [dctClipboardItem objectForKey:@"FolderPermission"];
    clipboardSyncData.strFolderbIsOwner = [dctClipboardItem objectForKey:@"FolderbIsOwner"];
    clipboardSyncData.strIsFolder = [dctClipboardItem objectForKey:@"IsFolder"];
    clipboardSyncData.strDocumentId = [dctClipboardItem objectForKey:@"DocumentId"];
    clipboardSyncData.strFolderCanSync = [dctClipboardItem objectForKey:@"FolderCanSync"];
    
    SyncFolder* ToSync = [[SyncFolder alloc]init];
    ToSync.strFolderId = [TempStorage GetCustomKeyWithValue:gSaveFolderDetailsTemp];
    
    if (kPaste == 0) {
        kPaste = 1;
        [self MoveInToNewFolder:self.insideSyncFolderDetails.strFolderId.length > 1 ? self.insideSyncFolderDetails : ToSync withCurrentFolderData:clipboardSyncData];
    }
    
    
}


- (void)AddClipboardIcon{
    
    if ([self checkifClipboardhasItem]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:sNeedToShowClipboard object:nil];
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:sNeedToHideClipboard object:nil];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.lblTotalFileCnt setText:self.strTotalFiles];
    [self AddClipboardIcon];
    NSLog(@"TRsas %@:", self.insideSyncFolderDetails.strFolderName);
    kPaste = 0;
    [TempStorage SaveCustomKey:gSaveFolderDetailsTemp withValue:self.insideSyncFolderDetails.strFolderId];
    
}

- (void)DoneLSFTVviewImport{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        
         
//             // MAKE THIS CALL
//             if (self.onDismiss) {
//                 self.onDismiss(@"Dismiss Modal");
//             }
////             dispatch_async(dispatch_get_main_queue(), ^ {
//                 
////             });
//        
//        if (self.syncIpadForLSFTDelegate) {
//            [self.syncIpadForLSFTDelegate didDismissViewModal];
//        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SecondViewControllerDismissed"
         object:nil userInfo:nil];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil]; 
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)CancelLSFTViewImport{
   
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        [self.navigationController dismissViewControllerAnimated:YES completion:^
//         {
//             // MAKE THIS CALL
//             self.onDismiss(self, @"Dismiss Modal");
//         }];
//    }else{
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (UIView *)vwForTotalFileCount{
    
    UIView* vwBg = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 60)];
    [vwBg setTag:99878];
    [vwBg setBackgroundColor:[UIColor whiteColor]];
    [vwBg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [vwBg.layer setBorderWidth:1];
    
    self.lblTotalFileCnt = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, [UIScreen mainScreen].bounds.size.width - 20, 40)];
    [self.lblTotalFileCnt setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [self.lblTotalFileCnt setText:self.strTotalFiles];
    [vwBg addSubview:self.lblTotalFileCnt];
    vwBg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    return vwBg;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGRect frame = self.vwForTotalFileCount.frame;
//    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.vwForTotalFileCount.frame.size.height;
//    self.vwForTotalFileCount.frame = frame;
//    
//    [self.tableView bringSubviewToFront:self.vwForTotalFileCount];
//}


- (void)filterSync{
    
    UIActionSheet* actSort = [[UIActionSheet alloc]initWithTitle:@"SORT" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date Modified",@"Name A-Z",@"Name Z-A", nil];//, @"Type"
    [actSort setTag:kSyncIphoneSort];
    [actSort showInView:self.view];
    
}

#pragma mark - Refresh Control

- (void)refreshTable {
    bPageLimit = NO;
    //TODO: refresh your data
    [self.refreshCont endRefreshing];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                if ([[TempStorage GetCustomKeyWithValue:tSyncCacheDetails] isKindOfClass:[NSMutableArray class]]) {
                    NSMutableArray* arrFolderList = [TempStorage GetCustomKeyWithValue:tSyncCacheDetails];
                    [self CachedDicts:arrFolderList];
                    
                    
                }else{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Cannot identify your account. Please try again when Internet is available."];
                    
                }
            }
                break;
                
            default:{
                kpageindex = 1;
                [self.arrSyncDetails removeAllObjects];
                [self.tableView reloadData];
                [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                
            }
                break;
        }
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        
//        PinCodeViewController *logView = [storyboard instantiateViewControllerWithIdentifier:@"PinCodeViewController"];
        //    LoginViewController* logView = [[LoginViewController alloc]init];
        //    logView.TouchIDNeeded = NO;

    }];
}

#pragma mark - Cached Offline Methods

- (void)CachedDicts:(NSMutableArray *)arrFolderList{
    
    for (NSDictionary* fDict in arrFolderList) {
        //                NSLog(@"IsFolderOwnerClass:%@", [[fDict objectForKey:kFolderbIsOwner] class]);
        SyncFolder* syncFile = [[SyncFolder alloc]init];
        [syncFile setStrDocumentCreatedDate:[fDict objectForKey:kDocumentCreatedDate]];
        [syncFile setStrDocumentExtension:[fDict objectForKey:kDocumentExtension]];
        [syncFile setStrDocumentId:[fDict objectForKey:kDocumentId]];
        [syncFile setStrDocumentIsDeleted:[fDict objectForKey:kDocumentIsDeleted]];
        [syncFile setStrDocumentName:[fDict objectForKey:kDocumentName]];
        [syncFile setStrDocumentSize:[[fDict objectForKey:@"DocumentSize"] intValue]];
        [syncFile setStrDocumentUrl:[fDict objectForKey:@"DocumentUrl"]];
        [syncFile setStrDocumentVersion:[fDict objectForKey:kDocumentVersion]];
        [syncFile setStrFolderCanShareFurther:[fDict objectForKey:kFolderCanShareFurther]];
        [syncFile setStrFolderCanSync:[fDict objectForKey:kFolderCanSync]];
        [syncFile setStrFolderId:[fDict objectForKey:kFolderId]];
        [syncFile setStrFolderName:[fDict objectForKey:kFolderName]];
        [syncFile setStrFolderOwnerCreatedDate:[fDict objectForKey:kFolderOwnerCreatedDate]];
        [syncFile setStrFolderOwnerFirstName:[fDict objectForKey:kFolderOwnerFirstName]];
        [syncFile setStrFolderOwnerId:[fDict objectForKey:kFolderOwnerId]];
        [syncFile setStrFolderOwnerLastName:[fDict objectForKey:kFolderOwnerLastName]];
        [syncFile setStrFolderOwnerOrgId:[fDict objectForKey:kFolderOwnerOrgId]];
        [syncFile setStrFolderPermission:[fDict objectForKey:kFolderPermission]];
        [syncFile setStrFolderbIsOwner:[fDict objectForKey:kFolderbIsOwner]];
        [syncFile setStrIsFolder:[fDict objectForKey:kIsFolder]];
        [self.arrSyncDetails addObject:syncFile];
    }
    
    [self.tableView reloadData];

}

- (void)ReloadViewBasedFromObserver{
    [self.arrSyncDetails removeAllObjects];
    [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
}

- (void)ShowDrawer{
    AppDelegate* appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDel toggleLeftDrawer:self animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return self.arrSyncDetails.count;
    if (tableView == self.tableView) {//self.searchDspController.searchResultsTableView
        return self.arrSyncDetails.count;
    }
    else{

        return self.arrSearchResult.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * reuseIdentifier = @"SyncCell";
    MGSwipeTableCell * cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    SyncFolder* syncFile;
    
    if (tableView==self.tableView) {//self.searchDspController.searchResultsTableView
        syncFile =  [self.arrSyncDetails objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [SyncFolder GetTimeStamp:syncFile.strFolderOwnerCreatedDate.length ? syncFile.strFolderOwnerCreatedDate : syncFile.strDocumentCreatedDate];
        [cell.detailTextLabel sizeToFit];
    }
    else{
        
        syncFile =  [self.arrSearchResult objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = syncFile.strFolderName.length ? syncFile.strFolderName : syncFile.strDocumentName;
    
    cell.delegate = self; //optional
    [cell.imageView setImage:[self getImageInDetail:syncFile]];
    
    if (!self.isComingFromLSFT) {
        
        //configure left buttons
        cell.leftButtons = [self leftSwipeOptionForFolder:syncFile];
        cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
        
        //configure right buttons
        cell.rightButtons = [self rightSwipeOptionForFolder:syncFile];
        cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
        
    }

//    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if ([indexPath row] == rowsAmount - 1 && !bPageLimit) {
        // This is the last cell in the table
        kpageindex +=1;
        [self GetSyncData:NO andWithSyncFolderData:self.insideSyncFolderDetails];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SyncFolder* syncDataSelected;
    
    if (tableView == self.tableView) {
       syncDataSelected = [self.arrSyncDetails objectAtIndex:indexPath.row];
    }else{
       syncDataSelected = [self.arrSearchResult objectAtIndex:indexPath.row];
    }


    int detVal = 1;
    BOOL blVal  = detVal;
//    if (blVal == [detail.strFolderbIsOwner intValue]) {
    if (blVal == [syncDataSelected.strIsFolder intValue]) {
        
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
            
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                {
                    if ([[TempStorage GetCustomKeyWithValue:tSyncCacheDetails] isKindOfClass:[NSMutableArray class]]) {
                        
                        
                        
                        
                    }else{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Cannot identify your account. Please try again when Internet is available."];
                        
                    }
                }
                    break;
                    
                default:{
                    NSArray *viewsToRemove = [self.navigationController.view subviews];
                    for (UIView *v in viewsToRemove) {
                        switch (v.tag) {
                            case 99878:
                            {
                                [v removeFromSuperview];
                            }
                                break;
                                
                            default:
                                break;
                        }
                        
                     
                    }
                    SyncViewCellTableViewController* anotherSyncDta = [[SyncViewCellTableViewController alloc]initWithSyncFolderDetails:syncDataSelected andViewDisplay:UITableViewStyleGrouped];
                    if (self.isComingFromLSFT) {
                        anotherSyncDta.isComingFromLSFT = YES;
                    }else{
                        anotherSyncDta.isComingFromLSFT = NO;
                    }
                    [self.navigationController pushViewController:anotherSyncDta animated:YES];
                    
                }
                    break;
            }
            
        }];
        
        
        
    }else{

    
        
            
            if (self.isComingFromLSFT) {
                self.selectedCellIndex = indexPath;
                UIAlertView* alertVw = [[UIAlertView alloc]initWithTitle:@"LSFT" message:@"Do you want to attach this file to LSFT?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
                [alertVw setTag:kLSFTSyncFileDownload];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [alertVw show];
                });
            }else{
                
                if ([UtilsComponent extensionIsSupported:[syncDataSelected.strDocumentExtension uppercaseString]]) {
                    
                    if (     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocsViewer object:syncDataSelected];
                        
                    }else{
                        
                        DocumentViewerController* docVw = [[DocumentViewerController alloc]initWithUrl:syncDataSelected isFullScreen:NO];
                        [self.navigationController pushViewController:docVw animated:YES];
                        
                        
                    }

                }else{
                    [[[UIAlertView alloc]initWithTitle:nil message:@"File Preview is not available for this File." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
                    
                }
                
                
                
            }
            
        
        
    }
    

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}


#pragma mark - Left Tablerow Swipe

- (NSArray *)leftSwipeOptionForFolder:(SyncFolder *)InfoDetails{
    
    
    int detVal = 1;
    BOOL blVal  = detVal;
    
    if (blVal == [InfoDetails.strIsFolder intValue]) {//
        
        return @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"MoveTrolley"] backgroundColor:[UIColor whiteColor]],
                 [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Sorting Options"] backgroundColor:[UIColor whiteColor]]];
        
    }else{
        
        return @[[MGSwipeButton buttonWithTitle:@" " icon:[UIImage imageNamed:@"MoveTrolley"] backgroundColor:[UIColor whiteColor]],
                 [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Sorting Options"] backgroundColor:[UIColor whiteColor]],
                 [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Star-1"] backgroundColor:[self CheckDataIfInFavsList:InfoDetails.strDocumentName] ? [UIColor yellowColor] : [UIColor whiteColor]]];
    }
    
    
    
  
    
//    [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Edit-2"] backgroundColor:[UIColor colorWithRed:0.576 green:0.157 blue:0.137 alpha:1]],
//    ,
//    [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Download"] backgroundColor:[UIColor colorWithRed:0.576 green:0.157 blue:0.137 alpha:1]],
//    [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Share Filled"] backgroundColor:[UIColor colorWithRed:0.576 green:0.157 blue:0.137 alpha:1]]
//    

}

- (NSArray *)rightSwipeOptionForFolder:(SyncFolder *)InfoDetails{
    
    
    int detVal = 1;
    BOOL blVal  = detVal;
    
    if (blVal == [InfoDetails.strIsFolder intValue]) {
        return @[];
    }else{
        NSString* strLSFTUserName = [TempStorage GetCustomKeyWithValue:bLSFYLoginSucess];
        
        if ([strLSFTUserName isEqualToString:@"NO"] || strLSFTUserName.length < 2) {
            return @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"AddToCompare"] backgroundColor:[UIColor whiteColor]],
                     [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cleanMetadata"] backgroundColor:[UIColor whiteColor]],
                     [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"convertToPDF"] backgroundColor:[UIColor whiteColor]]];

        }else{
            return @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"AddToCompare"] backgroundColor:[UIColor whiteColor]],
                     [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"cleanMetadata"] backgroundColor:[UIColor whiteColor]],
                     [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"convertToPDF"] backgroundColor:[UIColor whiteColor]],
                     [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"lsftbadge"] backgroundColor:[UIColor whiteColor]]];

        }
    
    }
    
//icon:[UIImage imageNamed:@"AddToCompare"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor whiteColor]
//                                                icon:[UIImage imageNamed:@"cleanMetadata"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor whiteColor]
//                                                icon:[UIImage imageNamed:@"convertToPDF"]];
    
    
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    
    self.selectedCellIndex = [self.tableView indexPathForCell:cell];
    NSLog(@"Selected IndexPath SwipeCell:%i",(int) self.selectedCellIndex.row);
    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    
    switch (direction) {
        case MGSwipeDirectionLeftToRight:
        {
            NSLog(@"Left Selected");
            
            int detVal = 1;
            BOOL blVal  = detVal;
            
            if (blVal == [syncDetSelectedIndex.strIsFolder intValue]) {
                
                switch (index) {
                    case 0:// Move
                    {
                        UIActionSheet* actOtherOptions = [[UIActionSheet alloc]initWithTitle:@"Move Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Move to root", @"Cut", [self checkifClipboardhasItem] ? @"Paste" : nil, nil];
                        [actOtherOptions setTag:kMoveActSheetTag];
                        [actOtherOptions showInView:self.view];
                    }
                        break;
                        
                    default:
                    {
                        
                        UIActionSheet* actOtherOptions = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share",@"Rename",@"Delete", nil];//@"Share",
                        [actOtherOptions setTag:kFolderOptActSheetTag];
                        [actOtherOptions showInView:self.view];
                        
                        
                    }
                        break;
                }
                
                
            }else{
                switch (index) {
                    case 0:
                    {
                        UIActionSheet* actOtherOptions = [[UIActionSheet alloc]initWithTitle:@"Move Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Move to root", @"Cut", nil];
                        [actOtherOptions setTag:kMoveActSheetTag];
                        [actOtherOptions showInView:self.view];
                    }
                        break;
                    case 1://Other options
                    {
                        UIActionSheet* actOtherOptions = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Download" ,@"Rename",@"Delete", nil];//,@"Export"
                        [actOtherOptions setTag:kFileOptActSheetTag];
                        [actOtherOptions showInView:self.view];
                    }
                        break;
                        
                    default:
                    {
//                        [self.tableView beginUpdates];
//                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedCellIndex.row inSection:0];
//                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
//                        
//                        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                        [self.tableView endUpdates];
                        [self.tableView reloadData];

                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[self CheckDataIfInFavsList:syncDetSelectedIndex.strDocumentName] ? @"Removing file to Favorite List..." : @"Adding file to Favorite List..."];
                        [self SaveDataFiletoFavorites:syncDetSelectedIndex];
                    }
                        break;
                }
            }
            
        }
            break;
            
        default:
        {
            NSLog(@"Right Selected");
            
            switch (index) {
                case 0:// Change Pro
                {
                    
                    if (self.arrCompareFile.count < 1) {
                        UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Compare Files" message:@"Please select another File to Compare" delegate:self cancelButtonTitle:@"Cancel Now" otherButtonTitles:@"Add another", nil];
                        [alertSync setTag:kCompareFilesAlrtTag];
                        [alertSync show];
                    }else if (self.arrCompareFile.count == 1){
                        [self.arrCompareFile addObject:syncDetSelectedIndex];
                        if (self.arrCompareFile.count == 2) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Comparing File..."];
                            [self CompareFile];
                        }
                    }

                }
                    break;
                case 1:// Metadact
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Cleaning Document %@ ...", syncDetSelectedIndex.strDocumentName]];
                    [self CleanFile:syncDetSelectedIndex];
                }
                    break;
                case 2:// Litera PDF
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Converting Document %@ to PDF...", syncDetSelectedIndex.strDocumentName]];
                    [self ConvertToPDF:syncDetSelectedIndex];
                }
                    break;
                default:
                {
                    UIAlertView* alertVwFLst = [[UIAlertView alloc]initWithTitle:@"" message:@"Send this file securely?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                    [alertVwFLst setTag:kLSFTAttachFile];
                    [alertVwFLst show];
                    
                }
                    break;
            }
        }
            break;
    }
    
    
    return YES;
}

- (BOOL)CheckforFileInDocsDir:(NSString *)fileName{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:foofile];
}


/**
 Image Indexing Function based from Extensions
 */


- (UIImage *)getImageInDetail:(SyncFolder *)detail{
    
    if (detail.strDocumentExtension.length>0) {
        if ([[detail.strDocumentExtension uppercaseString] isEqualToString:@".JPG"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".PNG"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".JPEG"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".BMP"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".TIFF"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".CGM"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".SVG"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".GIF"]) {
            return [UIImage imageNamed:@"Picture"];
        }else if ([[detail.strDocumentExtension uppercaseString] isEqualToString:@".TXT"]||[[detail.strDocumentExtension uppercaseString] isEqualToString:@".RTF"]){
            return [UIImage imageNamed:@"TXT"];
        }else if ([detail.strDocumentExtension  isEqualToString:@".pdf"]){
            return [UIImage imageNamed:@"PDF"];
        }else if ([detail.strDocumentExtension  isEqualToString:@".docx"]||[detail.strDocumentExtension  isEqualToString:@".doc"]){
            return [UIImage imageNamed:@"MS Word"];
        }else if ([[detail.strDocumentExtension lowercaseString] isEqualToString:@".xlsx"]||[[detail.strDocumentExtension lowercaseString] isEqualToString:@".xlsm"]||[[detail.strDocumentExtension lowercaseString] isEqualToString:@".xltx"]){
           return [UIImage imageNamed:@"MS Excel"];
        }else if ([[detail.strDocumentExtension lowercaseString] isEqualToString:@".ppt"]||[[detail.strDocumentExtension lowercaseString] isEqualToString:@".pps"]||[[detail.strDocumentExtension lowercaseString] isEqualToString:@".pptx"]){
            return [UIImage imageNamed:@"MS PowerPoint"];
        }else{
            return [UIImage imageNamed:@"Document"];
        }
    }else if (detail.strFolderbIsOwner){
//        NSLog(@"FolderIsOwner:%@",detail.strFolderbIsOwner);
        int detVal = 1;
        BOOL blVal  = detVal;
        if (blVal == [detail.strFolderbIsOwner intValue]) {
            return [UIImage imageNamed:@"newfoldericon"];
        }else{
            return [UIImage imageNamed:@"foldericonshare"];
        }
    }else{
        return [UIImage imageNamed:@"Document"];
    }
    

}

- (NSAttributedString *)detailTextAttributes: (SyncFolder *)sDetails{
    
    
    NSMutableAttributedString* detAttStr = [[NSMutableAttributedString alloc]initWithString:@"" attributes:@{}];
    //syncFile.strDocumentSize != 0 ? [NSString stringWithFormat:@"%i bytes", (int)syncFile.strDocumentSize] : @""
    return (NSAttributedString *)detAttStr;
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor whiteColor]
//                                                icon:[UIImage imageNamed:@"Share Filled"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Download"]];
    
    return rightUtilityButtons;
}

- (NSArray *)rightFolderButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                 icon:[UIImage imageNamed:@"Share Filled"]];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons:(int)IndexForItem{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
//    SyncFolder* syncFile =  [self.arrSearchResult objectAtIndex:IndexForItem];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Trash-1"]];
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Edit-2"]];
    
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"Share"]];//self InverseImage:
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Open Folder-1"]];
    
    

//    if ([syncFile.strDocumentExtension isEqualToString:@".doc"]||[syncFile.strDocumentExtension isEqualToString:@".docx"]) {
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"AddToCompare"]];
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"cleanMetadata"]];
//        [leftUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                    icon:[UIImage imageNamed:@"convertToPDF"]];
//
//    }
//    
    return leftUtilityButtons;
}

- (NSArray *)leftButtonsForDocs{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
//    SyncFolder* syncFile =  [self.arrSearchResult objectAtIndex:IndexForItem];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Trash-1"]];
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Edit-2"]];
    
    //    [leftUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
    //                                                icon:[UIImage imageNamed:@"Share"]];//self InverseImage:
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Open Folder-1"]];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Star-1"]];
    
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor whiteColor]
                                                    icon:[UIImage imageNamed:@"AddToCompare"]];
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor whiteColor]
                                                    icon:[UIImage imageNamed:@"cleanMetadata"]];
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor whiteColor]
                                                    icon:[UIImage imageNamed:@"convertToPDF"]];
        
    
    
    return leftUtilityButtons;
}

- (NSArray *)leftButtonsForPDF{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    //    SyncFolder* syncFile =  [self.arrSearchResult objectAtIndex:IndexForItem];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Trash-1"]];
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Edit-2"]];
    
    //    [leftUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
    //                                                icon:[UIImage imageNamed:@"Share"]];//self InverseImage:
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Open Folder-1"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"Star-1"]];
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"AddToCompare"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor whiteColor]
                                                icon:[UIImage imageNamed:@"cleanMetadata"]];
    
    
    
    return leftUtilityButtons;
}

- (UIImage *)InverseImage:(UIImage *)imgOrig{
    CIImage *coreImage = [CIImage imageWithCGImage:imgOrig.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return [UIImage imageWithCIImage:result scale:0.5 orientation:UIImageOrientationUp];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {


    self.selectedCellIndex = [self.tableView indexPathForCell:cell];
    NSLog(@"Selected IndexPath SwipeCell:%i",(int) self.selectedCellIndex.row);
    
    
    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    if ([syncDetSelectedIndex.strDocumentExtension  isEqualToString:@".doc"]||[syncDetSelectedIndex.strDocumentExtension isEqualToString:@".docx"]){
        switch (index) {
            case 0:{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"Are you sure you want to Delete?" delegate:self cancelButtonTitle:kCancel otherButtonTitles:kOk, nil];
                [alert setTag:kDeleteFileFolders];
                [alert show];
                
//                SyncFolder* folderSyncDets = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
//                NSLog(@"Folder Permission:%i || FolderIsOwner:%i",(int)[folderSyncDets.strFolderPermission integerValue], (int)[folderSyncDets.strFolderbIsOwner integerValue]);
//                // Delete button was pressed
//                if([folderSyncDets.strFolderPermission integerValue] == kViewModifyPermission || [folderSyncDets.strFolderbIsOwner integerValue]== 0)
//                {
//                    //                [self callDeleteFileFolderServiceWithRecords:[NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:objDoc.FolderId, kObjectId, objDoc.IsFolder, kObjectIsFolder, nil]]];
//                    
//                    NSMutableArray* arrTp = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:folderSyncDets.strDocumentId.length > 0 ? folderSyncDets.strDocumentId:folderSyncDets.strFolderId, kObjectId, folderSyncDets.strIsFolder, kObjectIsFolder, nil]];
//                    // create request object
//                    NSMutableDictionary * requestDict;
//                    requestDict = [[NSMutableDictionary alloc] init];
//                    [requestDict setValue:arrTp forKey:kDeleteObjectList];
//                    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
//                    
//                    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kDeleteFolderRequest]];
//                    
//        
//                    
//                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//                    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
//                    //    [manager setSecurityPolicy:policy];
//                    [manager POST:[NSString localizedStringWithFormat:@"%@/%@",kDefaultServerURL,kDeleteFileFolderServiceName] parameters:ParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        
//                        //                 NSMutableDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//                        
//                        NSLog(@"DeleteResponse:%@ || ClassSuccess:%@", responseObject, [[responseObject objectForKey:kSuccess] class]);
//                        
//                        //        NSLog(@"JSON: %@", responseObject);
//                        
//                        //        [[[]]];
//                        //                        kSuccess
//                        if ([responseObject objectForKey:kSuccess] ) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"File Deleted Successfully"];
//                            
//                            //                         [self GetSyncData:YES andWithSyncFolderData:folderSyncDets];
//                            if (![self.insideSyncFolderDetails.strFolderId isEqualToString:folderSyncDets.strFolderId]) {
//                                [self.arrSyncDetails removeAllObjects];
//                                kpageindex = 1;                                
//                                [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
//                            }
//                            
//                            
//                        }
//                        
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSLog(@"Error: %@", error);
//                    }];
//                    
//                    
//                    
//                }
//                
//                else
//                {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"You don't have permission to Modify this folder." delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil, nil];
//                    [alert show];
//                }
                
            }
                break;
            case 1:{
                NSLog(@"rename was pressed");
                
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Rename" message:@"Enter new Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                [alertSync setTag:kRenameFileSD];
                [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                [[alertSync textFieldAtIndex:0] setText:syncDetSelectedIndex.strFolderName.length > 1 ? syncDetSelectedIndex.strFolderName : syncDetSelectedIndex.strDocumentName];
                [alertSync show];
            }
                break;
            case 2:
            {NSLog(@"move to doc dirs was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Move to Root" message:@"Are you sure you want this file moved to Root?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertSync setTag:kMovetoRootFiles];
                [alertSync show];
            }   break;
            case 3:
            {
                // Save to Favorites
                NSLog(@"Save to Favorites");
                [self SaveAsFavorites:syncDetSelectedIndex];
            }
                break;
            case 4:{
                NSLog(@"change pro was pressed:%i", (int)self.arrCompareFile.count);
                
                if (self.arrCompareFile.count < 1) {
                    UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Compare Files" message:@"Please select another File to Compare" delegate:self cancelButtonTitle:@"Cancel Now" otherButtonTitles:@"Add another", nil];
                    [alertSync setTag:kCompareFilesAlrtTag];
                    [alertSync show];
                }else if (self.arrCompareFile.count == 1){
                    [self.arrCompareFile addObject:syncDetSelectedIndex];
                    if (self.arrCompareFile.count == 2) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Comparing File... The Comparison will appear in the Root Folder."];
                        [self CompareFile];
                    }
                }
                
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Comparing File... The Comparison will appear in the Root Folder"];

                    [self CompareFile];
                }
                
                
               
            }break;
            case 5:
            {
                NSLog(@"metadact was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Metadact" message:@"Cleaning File..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [self CleanFile:syncDetSelectedIndex];
                [alertSync show];

            }
                break;
            case 6:
            {
                NSLog(@"litera pdf was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Convert" message:@"Converting to PDF..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [self ConvertToPDF:syncDetSelectedIndex];
                [alertSync show];
            }
                break;
            default:
                break;
        }

        
        
    }else if ([syncDetSelectedIndex.strDocumentExtension isEqualToString:@".pdf"]){
    
        switch (index) {
            case 0:{

                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"Are you sure you want to Delete?" delegate:self cancelButtonTitle:kCancel otherButtonTitles:kOk, nil];
                [alert setTag:kDeleteFileFolders];
                [alert show];
                
//                
//                SyncFolder* folderSyncDets = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
//                NSLog(@"Folder Permission:%i || FolderIsOwner:%i",(int)[folderSyncDets.strFolderPermission integerValue], (int)[folderSyncDets.strFolderbIsOwner integerValue]);
//                // Delete button was pressed
//                if([folderSyncDets.strFolderPermission integerValue] == kViewModifyPermission || [folderSyncDets.strFolderbIsOwner integerValue]== 0)
//                {
//
//                    NSMutableArray* arrTp = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:folderSyncDets.strDocumentId.length > 0 ? folderSyncDets.strDocumentId:folderSyncDets.strFolderId, kObjectId, folderSyncDets.strIsFolder, kObjectIsFolder, nil]];
//                    // create request object
//                    NSMutableDictionary * requestDict;
//                    requestDict = [[NSMutableDictionary alloc] init];
//                    [requestDict setValue:arrTp forKey:kDeleteObjectList];
//                    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
//                    
//                    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kDeleteFolderRequest]];
//                    
//                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//                    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
//                    //    [manager setSecurityPolicy:policy];
//                    [manager POST:[NSString localizedStringWithFormat:@"%@/%@",kDefaultServerURL,kDeleteFileFolderServiceName] parameters:ParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        
//                        //                 NSMutableDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//                        
//                        NSLog(@"DeleteResponse:%@ || ClassSuccess:%@", responseObject, [[responseObject objectForKey:kSuccess] class]);
//                        
//                        //        NSLog(@"JSON: %@", responseObject);
//                        
//                        //        [[[]]];
//                        //                        kSuccess
//                        if ([responseObject objectForKey:kSuccess] ) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"File Deleted Successfully"];
//                            
//                            //                         [self GetSyncData:YES andWithSyncFolderData:folderSyncDets];
//                            if (![self.insideSyncFolderDetails.strFolderId isEqualToString:folderSyncDets.strFolderId]) {
//                                [self.arrSyncDetails removeAllObjects];
//                                kpageindex = 1;
//                                [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
//                            }
//                            
//                            
//                        }
//                        
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSLog(@"Error: %@", error);
//                    }];
                
                    
                    
//                }
                
//                else
//                {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"You don't have permission to Modify this folder." delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil, nil];
//                    [alert show];
//                }
                
            }
                break;
            case 1:{
                NSLog(@"rename was pressed");
                
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Rename" message:@"Enter new Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                [alertSync setTag:kRenameFileSD];
                [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                [[alertSync textFieldAtIndex:0] setText:syncDetSelectedIndex.strFolderName.length > 1 ? syncDetSelectedIndex.strFolderName : syncDetSelectedIndex.strDocumentName];
                [alertSync show];
            }
                break;
            case 2:
            {NSLog(@"move to doc dirs was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Move to Root" message:@"Are you sure you want this file moved to Root?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertSync setTag:kMovetoRootFiles];
                [alertSync show];
            }   break;
            case 3:
            {
                // Save to Favorites
                NSLog(@"Saved to Favorites");
                                [self SaveAsFavorites:syncDetSelectedIndex];
            }
                break;
            case 4:{
                NSLog(@"change pro was pressed:%i", (int)self.arrCompareFile.count);
                
                if (self.arrCompareFile.count < 1) {
                    UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Compare Files" message:@"Please select another File to Compare" delegate:self cancelButtonTitle:@"Cancel Now" otherButtonTitles:@"Add another", nil];
                    [alertSync setTag:kCompareFilesAlrtTag];
                    [alertSync show];
                }else if (self.arrCompareFile.count == 1){
                    [self.arrCompareFile addObject:syncDetSelectedIndex];
                    if (self.arrCompareFile.count == 2) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Comparing File..."];
                        [self CompareFile];
                    }
                }
                
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Comparing File..."];
                    
                    [self CompareFile];
                }
                
                
                
            }break;
            case 5:
            {
                NSLog(@"metadact was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Metadact" message:@"Cleaning File..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [self CleanFile:syncDetSelectedIndex];
                [alertSync show];
                
            }
                break;

            default:
                break;
        }

    
    }else{
        
        switch (index) {
            case 0:{
                //                NSLog(@"disable sync was pressed");
                //                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Sync" message:@"Are you sure you want to Disable Sync?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                //                [alertSync show];
                
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"Are you sure you want to Delete?" delegate:self cancelButtonTitle:kCancel otherButtonTitles:kOk, nil];
                [alert setTag:kDeleteFileFolders];
                [alert show];

            }
                break;
            case 1:{
                NSLog(@"clock button was pressed");
                
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Rename" message:@"Enter new Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                [alertSync setTag:kRenameFileSD];
                [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alertSync show];
            }
                break;
            case 2:{
                NSLog(@"cross button was pressed");
                
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Move to Root" message:@"Are you sure you want this file moved to Root?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertSync setTag:kMovetoRootFiles];
                [alertSync show];
            }
                break;
            case 3:{
                NSLog(@"list button was pressed");
                UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Move to Root" message:@"Are you sure you want this file moved to Root?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alertSync setTag:kMovetoRootFiles];
                [alertSync show];
            }
            default:
                break;
        }

        
    }

    
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
//     NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
//    self.selectedCellIndex = [self.tableView indexPathForCell:cell];
//    NSLog(@"Selected Left IndexPath SwipeCell:%i",(int) indexPath.row);
//    self.selectedCellIndex = [self.tableView indexPathForCell:cell];
//    NSLog(@"Selected IndexPath SwipeCell:%i",(int) self.selectedCellIndex.row);
//    self.syncSelectedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    
//    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    
    self.selectedCellIndex = [self.tableView indexPathForCell:cell];
    NSLog(@"Selected IndexPath SwipeCell:%i",(int) self.selectedCellIndex.row);
    
    
    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    
//    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:indexPath.row];
    
    
    int detVal = 1;
    BOOL blVal  = detVal;
    
    if (blVal == [syncDetSelectedIndex.strIsFolder intValue]) {// is a Folder
         self.syncSelectedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
        
    // Launch Share
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        ShareViewController *shareView = [storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
        shareView.syncPassedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
        NavHomeViewController* navLog = [[NavHomeViewController alloc]initWithRootViewController:shareView];
        
        [self presentViewController:navLog animated:YES completion:nil];
        
    }else{
        
        switch (index) {
            case 0:{
                
                NSLog(@"More button was pressed||||Row:%i", (int)index);
                //            SelectedIndex = (int)indexPath.row;
                self.syncSelectedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share Option" delegate:self cancelButtonTitle:@"Cancel Action" destructiveButtonTitle:nil otherButtonTitles:@"Export", nil];
                [actionSheet setTag:6657];
                [actionSheet showInView:self.view];
                
            }
                break;
            case 1:
            { // Download File to Directory
                //            SelectedIndex = (int)indexPath.row;
                [self DownloadFile:syncDetSelectedIndex];
            }
                break;
            default:
                break;
        }

        
    }
    
    
    
 }








#pragma mark - Saving Files
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"Keypath:%@", keyPath);
    if([keyPath isEqualToString:@"fractionCompleted"]){
        NSLog(@"Progress: %@", change);
    }
}


- (void)SaveInInbox:(SyncFolder *)strFolderDets{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Saving File...."];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strFolderDets.strDocumentUrl]];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/InboxT"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    
    NSString *path = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[strFolderDets.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],strFolderDets.strDocumentExtension]];
    
    
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:path];
        
        //Here is change
        return documentsDirectoryPath;
        
    }completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            NSLog(@"File downloaded to: %@", filePath);
            
            
        });
        
    }];
    
    [downloadTask resume];
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    
}


- (void)SaveAsFavorites:(SyncFolder *)strFolderDets{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Saving File in Favorites...."];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strFolderDets.strDocumentUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/MyFavs"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    
    NSString *path = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[strFolderDets.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],strFolderDets.strDocumentExtension]];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];

}



- (void)DownloadFile:(SyncFolder *)strFolderDets{
    if (!fileAttachToLSFT) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Downloading File in Progress...."];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"Attaching file to LSFT..."];
    }
    
    
    
    [DownloaderFiles DownloadFileswithData:strFolderDets andFolderDetail:self.insideSyncFolderDetails withCompletion:^(BOOL success, NSURL *filePath, NSError *error) {
        
        if (success) {

            if (fileAttachToLSFT) {

                    AppDelegate* appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [appDel.lsftFilesDownloadedFromSync addObject:filePath];
                    fileAttachToLSFT = NO;
                    
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // code here
                     [appDel CenterViewWithLSFT];
                });
 
            }else if (self.isComingFromLSFT){
                
                AppDelegate* appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                [appDel.lsftFilesDownloadedFromSync addObject:filePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // code here
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Successfully Downloaded File :%@%@ Please refresh the Screen!",strFolderDets.strDocumentName, strFolderDets.strDocumentExtension ]];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Successfully Downloaded File :%@%@ Please refresh the Screen!",strFolderDets.strDocumentName, strFolderDets.strDocumentExtension ]];
                    });
            }
            

        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Successfully Downloaded File :%@%@ Please refresh the Screen!",strFolderDets.strDocumentName, strFolderDets.strDocumentExtension ]];
            });

        }
    }];
}






#pragma MARK - API Call

/*Get Task Server Requests
 */

// Convert to PDF

- (void)ConvertToPDF:(SyncFolder *)syncData{
    
    if ([[syncData.strDocumentExtension lowercaseString]isEqualToString:@".pdf"]) {
        [[[UIAlertView alloc]initWithTitle:@"PDF" message:@"Cannot convert. This file is already in PDF Format." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        return;
    }
    
    
    // create request object
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setValue:self.insideSyncFolderDetails.strFolderId.length ? self.insideSyncFolderDetails.strFolderId : [TempStorage GetCustomKeyWithValue:kRootFolderId] forKey:kFolderId];
    [requestDict setValue:syncData.strDocumentId forKey:kId];
    [requestDict setValue:[NSString stringWithFormat:@"%@%@",syncData.strDocumentName,syncData.strDocumentExtension] forKey:kName];
    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kOwnerId];
    [requestDict setValue:[NSString stringWithFormat:@"%i",syncData.strDocumentSize] forKey:kSize];
    
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kDocument]];
    
    NSMutableDictionary *finalParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:ParamDict forKey:krequest]];
    
    //ConvertDocument
    
    [[LSyncAPIClient sharedClient]POST:[NSString stringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kConvertDocumentServiceName] parameters:finalParamDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"Response:%@", responseObject);
        if ([[responseObject objectForKey:kSuccess]boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^ {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"%@ successfully converted.",[[responseObject objectForKey:@"Result"] objectForKey:@"FileName"]]];
            });
            kpageindex = 1;
            [self.arrSyncDetails removeAllObjects];            
            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];

        }else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ResponseError:%@", error.description);
    }];
    
}


/*
 Clean File - Metadact
 */
- (void)CleanFile :(SyncFolder *)syncData{
    
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    
    
    //syncData.strFolderId
    [requestDict setValue:self.insideSyncFolderDetails.strFolderId.length ? self.insideSyncFolderDetails.strFolderId : [TempStorage GetCustomKeyWithValue:kRootFolderId] forKey:kFolderId];
    [requestDict setValue:syncData.strDocumentId forKey:kId];
    [requestDict setValue:[NSString stringWithFormat:@"%@%@",syncData.strDocumentName,syncData.strDocumentExtension] forKey:kName];
    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kOwnerId];
    [requestDict setValue:[NSString stringWithFormat:@"%i",syncData.strDocumentSize] forKey:kSize];
    
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kDocument]];
    
    NSMutableDictionary *finalParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:ParamDict forKey:krequest]];
    
    
    
    
    
    [[LSyncAPIClient sharedClient]POST:[NSString stringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kCleanDocumentServiceName] parameters:finalParamDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"Response:%@", responseObject);
        if ([[responseObject objectForKey:kSuccess] boolValue]) {
            NSDictionary* sctRsp = [responseObject valueForKey:@"Result"];
            dispatch_async(dispatch_get_main_queue(), ^ {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"%@ successfully cleaned.", [sctRsp valueForKey:@"Message"]]];
            });
            //Cleanupdocument operation is completed ,but failed to upload file on sync server.
            kpageindex = 1;
            [self.arrSyncDetails removeAllObjects];
            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
            
        }else{
            
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ResponseError:%@", error.description);
    }];
    
    
}


/*
 Compare Files
 */
- (void)CompareFile{
    NSMutableDictionary *dicParamTemp = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<2; i++) {
        
        SyncFolder *syncData =   [self.arrCompareFile objectAtIndex:i];
        
        NSMutableDictionary * requestDict;
        requestDict = [[NSMutableDictionary alloc] init];
        
        [requestDict setValue:self.insideSyncFolderDetails.strFolderId.length ? self.insideSyncFolderDetails.strFolderId : [TempStorage GetCustomKeyWithValue:kRootFolderId] forKey:kFolderId];
        [requestDict setValue:syncData.strDocumentId forKey:kId];
        [requestDict setValue:[NSString stringWithFormat:@"%@%@",syncData.strDocumentName,syncData.strDocumentExtension] forKey:kName];
        [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kOwnerId];
        [requestDict setValue:[NSString stringWithFormat:@"%i",syncData.strDocumentSize] forKey:kSize];
        
        [dicParamTemp setObject:requestDict forKey:(i==0)?@"FirstDocument":@"SecondDocument"];
        
    }
    
    NSMutableDictionary *finalParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:dicParamTemp forKey:krequest]];
    
    
    [[LSyncAPIClient sharedClient]POST:[NSString stringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kCompareDocumentServiceName] parameters:finalParamDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSLog(@"Compared Result:%@", responseObject);
        if ([responseObject objectForKey:kSuccess]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[[responseObject objectForKey:kResult] objectForKey:kMessage]];
            kpageindex = 1;
            [self.arrSyncDetails removeAllObjects];
            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];

        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error Comparing:%@", error.description);
    }];
    
    
    
    
    
}


/*
 Move To Root
 */


-(void)MovetoRoot:(SyncFolder *)syncData{
    //    FolderList *folderList = [self getCurrentFolderList];
    //    FileFolder *fileFolder = [arryDataOfTableView objectAtIndex:selectedIndexPath.row];
    //    FileFolder *parentFolder = folderList.parentFolder;
    
    if(![syncData.strFolderCanSync boolValue]&&[syncData.strIsFolder boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:[NSString stringWithFormat:@"File Can't be modified because sync is disabled on %@",syncData.strFolderName] delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
        [alert show];
    }
    
    else if(![[syncData strIsFolder] boolValue] && [[syncData strFolderPermission] integerValue] != kViewModifyPermission&&[syncData.strIsFolder boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertFileModifyPermissionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
        [alert show];
    }
    
    else
    {
        if([syncData.strFolderPermission integerValue] == kViewModifyPermission || [[syncData strFolderbIsOwner] boolValue]||![syncData.strIsFolder boolValue])
        {
            //            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            //            if(toRoot)
            //            {
            NSString *currentParentId = syncData.strFolderId;
            NSString *rootFolderId    = [TempStorage GetCustomKeyWithValue:kRootFolderId];//[AppDelegate shared].objLoginInfo.RootFolderId
            
            if([currentParentId isEqualToString:rootFolderId])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:([[syncData strIsFolder] boolValue]) ? kAlertMoveSameFolderForFolder : kAlertMoveSameFolderForFile delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                [alert show];
            }
            
            else
            {
                
                
                
                int iIsFolder = [syncData.strIsFolder intValue];
                NSString *strMoveFileFolderId;
                NSString *strIsFile;
                
                if(iIsFolder == 1)
                {
                    strIsFile = kFalse;
                    strMoveFileFolderId = syncData.strFolderId;
                }
                
                else
                {
                    strIsFile = kTrue;
                    strMoveFileFolderId = syncData.strDocumentId;
                }
                
                NSString *moveParentId = [TempStorage GetCustomKeyWithValue:kRootFolderId];//[AppDelegate shared].objLoginInfo.RootFolderId
                
                NSMutableDictionary *requestDict = [[NSMutableDictionary alloc]init];
                [requestDict setObject:strMoveFileFolderId forKey:kMoveFileFolderId];
                [requestDict setObject:moveParentId        forKey:kMoveParentId];
                [requestDict setObject:strIsFile           forKey:kMoveIsFile];
//                self.syncMoveDetailsFrom = syncData;
                NSMutableDictionary *dicFinal = [[NSMutableDictionary alloc]initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:@"moveDocumentsRequest"]];
                [self callWebServiceToMoveFileOrFolder:dicFinal forRoot:YES];
            }
        }
        
        
    }
    //    }
}


/*
 Move in Other Folders
 */

- (void)MoveInToNewFolder:(SyncFolder *)ToSyncData withCurrentFolderData:(SyncFolder *)CurrentSyncData{
  

  
    if(![CurrentSyncData.strFolderCanSync boolValue]&&[CurrentSyncData.strIsFolder boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:[NSString stringWithFormat:@"File Can't be modified because sync is disabled on %@",CurrentSyncData.strFolderName] delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
        [alert show];
    }
    
    else if(![[CurrentSyncData strIsFolder] boolValue] && [[CurrentSyncData strFolderPermission] integerValue] != kViewModifyPermission && [CurrentSyncData.strIsFolder boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertFileModifyPermissionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
        [alert show];
    }
    
    else
    {
        if([CurrentSyncData.strFolderPermission integerValue] == kViewModifyPermission || [[CurrentSyncData strFolderbIsOwner] boolValue]  || ![CurrentSyncData.strIsFolder boolValue])
        {
            int iIsFolder = [CurrentSyncData.strIsFolder intValue];
            NSString *strMoveFileFolderId;
            NSString *strIsFile;
            
            if(iIsFolder == 1)
            {
                strIsFile = kFalse;
                strMoveFileFolderId = CurrentSyncData.strFolderId;
            }
            
            else
            {
                strIsFile = kTrue;
                strMoveFileFolderId = CurrentSyncData.strDocumentId;
            }
            
            NSString *moveInParentId = self.insideSyncFolderDetails.strFolderId;
            
//            NSString *strMoveFileFolderId = CurrentSyncData.strFolderId;
            NSString *currentParentId     = self.insideSyncFolderDetails.strFolderId;
            NSString *moveParentId        = ToSyncData.strFolderId.length > 1 ? ToSyncData.strFolderId : [TempStorage GetCustomKeyWithValue:kRootFolderId]; // Current choosen Folder (not file) in which user want to move file/folder choosen during above condition..
//            NSString *strIsFile           = ToSyncData.strIsFolder ;
            
            if([currentParentId isEqualToString:moveParentId]) // User has choosen same folder to move, no need to call web-service
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:([strIsFile isEqualToString:kTrue]) ? kAlertMoveSameFolderForFile : kAlertMoveSameFolderForFolder delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                [alert show];
            }
            
            else if([strMoveFileFolderId isEqualToString:moveInParentId]) // Trying to move parent folder into his child
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertMoveParentIntoChild delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                [alert show];
            }
            
            else if([strMoveFileFolderId isEqualToString:moveParentId]) // User is trying to move Folder into that Folder itself.
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertMoveFolderInItself delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                [alert show];
            }
            
            else
            {
                // Call web-service
                
                NSMutableDictionary *requestDict = [[NSMutableDictionary alloc]init];
                [requestDict setObject:strMoveFileFolderId forKey:kMoveFileFolderId];
                [requestDict setObject:ToSyncData.strFolderId.length > 1 ? ToSyncData.strFolderId : moveParentId forKey:kMoveParentId];
                [requestDict setObject:strIsFile           forKey:kMoveIsFile];
                self.syncMoveDetailsFrom = ToSyncData;
                NSMutableDictionary *dicFinal = [[NSMutableDictionary alloc]initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:@"moveDocumentsRequest"]];
                [self callWebServiceToMoveFileOrFolder:dicFinal forRoot:ToSyncData.strFolderId.length > 1 ? NO : YES];
            }
        }
    
}
    
}

- (void)callWebServiceToMoveFileOrFolder:(NSDictionary *)dctVw forRoot:(BOOL )toRoot{
    [[LSyncAPIClient sharedClient] POST:[NSString localizedStringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kMoveFileFolderServiceName]  parameters:dctVw success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSLog(@"Response:%@", responseObject);
        
        if ([[responseObject objectForKey:kSuccess] boolValue]) {

//            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:toRoot ? @" Successfully Moved to Root." : @"Successfully Moved."]];
//            //Cleanupdocument operation is completed ,but failed to upload file on sync server.
//            kpageindex = 1;
//            [self.arrSyncDetails removeAllObjects];
//            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
            [[NSNotificationCenter defaultCenter] postNotificationName:sNeedToHideClipboard object:nil];
            
            if (!toRoot) {
                //                self.syncMovingData
                
                
                NSString* strPasteFromFolder = [TempStorage GetCustomKeyWithValue:gSaveFolderNameTemp];
                
                
                if (self.syncMoveDetailsFrom.strFolderName.length > 0) {
                    
                    UIAlertView* alertMoveBackToRoot = [[UIAlertView alloc]initWithTitle:@"Move" message:[NSString stringWithFormat:@"Successfully Moved to %@", self.syncMoveDetailsFrom.strFolderName.length > 0 ? self.syncMoveDetailsFrom.strFolderName : strPasteFromFolder ] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:[NSString stringWithFormat:@"Go to %@", self.syncMoveDetailsFrom.strFolderName.length > 0 ? self.syncMoveDetailsFrom.strFolderName : strPasteFromFolder ], nil];
                    [alertMoveBackToRoot setTag:kMovePushToFolderAlertTagiPhone];
                    [alertMoveBackToRoot show];
                    
                }else{
                    
                    
                    UIAlertView* alertMoveBackToRoot = [[UIAlertView alloc]initWithTitle:@"Move" message:[NSString stringWithFormat:@"Successfully Moved to %@. Please refresh page!", self.syncMoveDetailsFrom.strFolderName.length > 0 ? self.syncMoveDetailsFrom.strFolderName : strPasteFromFolder ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

                    [alertMoveBackToRoot show];
                    
                }
                
            }else{
                
                UIAlertView* alertMoveBackToRoot = [[UIAlertView alloc]initWithTitle:@"Move" message:[NSString stringWithFormat:toRoot ? @" Successfully Moved to Root." : @"Successfully Moved."] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to Root", nil];
                [alertMoveBackToRoot setTag:kMoveBacktoRootAlertTagiPhone];
                [alertMoveBackToRoot show];
            }
            
            
        }else{
            
        }
    
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



/*
 Get SYNC Data
 */

- (void)GetSyncData:(BOOL)withLoader andWithSyncFolderData:(SyncFolder *)folderData{
    withLoader ? [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES]: NO;
    
//    NSDictionary* dctASd = [self createRequestDictWithFolder:folderData];
//    NSLog(@"DCT GETFILEFOLDERLIST :%@", dctASd);
//    [self.arrFolderList removeAllObjects];
//    [self.tableView reloadData];
    if (self.arrFolderList.count>0) {
        [self.arrFolderList removeAllObjects];
    }
    
    NSString* strBaseUrl = [NSString localizedStringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kGetFileFolderListWebserviceName];
    
    [[LSyncAPIClient sharedClient] POST:strBaseUrl parameters:[self createRequestDictWithFolder:folderData] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
//            NSLog(@"LoginResponse:%@", responseObject);
            
        }else{
            
            //            NSDictionary* jsonResponse  = [[[NSDictionary alloc]initWithDictionary:responseObject]objectForKey:kResult];
           

            NSLog(@"respSync:%@", responseObject);
            NSMutableDictionary* dictResultFolder = [[NSMutableDictionary alloc]initWithDictionary:[responseObject objectForKey:kResult]];
            NSMutableArray* arrFolderList = [[NSMutableArray alloc]initWithArray:[dictResultFolder objectForKey:kFileFolderList]];
//            NSLog(@"respFileFolderList:%@", arrFolderList);
//            [TempStorage SaveCustomKey:tSyncCacheDetails withValue:arrFolderList];// Save to Result to Cache
            self.strTotalFiles =[NSString stringWithFormat:@"Total Files: %@ Total Folders: %@", [dictResultFolder objectForKey:@"TotalFiles"], [dictResultFolder objectForKey:@"TotalFolders"]];
//            NSLog(@"Files and Folders: %@ || %@", [dictResultFolder objectForKey:@"TotalFiles"], [dictResultFolder objectForKey:@"TotalFolders"]);
            [self.lblTotalFileCnt setText:self.strTotalFiles
             ];
            
            if (arrFolderList.count == 0) {
                bPageLimit = YES;
            }else{
                bPageLimit = NO;
            }
            
            if (kpageindex==1) {
                [TempStorage SaveCustomKey:tSyncCacheDetails withValue:arrFolderList];// Save to Result to Cache
            }
            
            for (NSDictionary* fDict in arrFolderList) {
//                NSLog(@"IsFolderOwnerClass:%@", [[fDict objectForKey:kFolderbIsOwner] class]);
                SyncFolder* syncFile = [[SyncFolder alloc]init];
                [syncFile setStrDocumentCreatedDate:[fDict objectForKey:kDocumentCreatedDate]];
                [syncFile setStrDocumentExtension:[fDict objectForKey:kDocumentExtension]];
                [syncFile setStrDocumentId:[fDict objectForKey:kDocumentId]];
                [syncFile setStrDocumentIsDeleted:[fDict objectForKey:kDocumentIsDeleted]];
                [syncFile setStrDocumentName:[fDict objectForKey:kDocumentName]];
                [syncFile setStrDocumentSize:[[fDict objectForKey:@"DocumentSize"] intValue]];
                [syncFile setStrDocumentUrl:[fDict objectForKey:@"DocumentUrl"]];
                [syncFile setStrDocumentVersion:[fDict objectForKey:kDocumentVersion]];
                [syncFile setStrFolderCanShareFurther:[fDict objectForKey:kFolderCanShareFurther]];
                [syncFile setStrFolderCanSync:[fDict objectForKey:kFolderCanSync]];
                [syncFile setStrFolderId:[fDict objectForKey:kFolderId]];
                [syncFile setStrFolderName:[fDict objectForKey:kFolderName]];
                [syncFile setStrFolderOwnerCreatedDate:[fDict objectForKey:kFolderOwnerCreatedDate]];
                [syncFile setStrFolderOwnerFirstName:[fDict objectForKey:kFolderOwnerFirstName]];
                [syncFile setStrFolderOwnerId:[fDict objectForKey:kFolderOwnerId]];
                [syncFile setStrFolderOwnerLastName:[fDict objectForKey:kFolderOwnerLastName]];
                [syncFile setStrFolderOwnerOrgId:[fDict objectForKey:kFolderOwnerOrgId]];
                [syncFile setStrFolderPermission:[fDict objectForKey:kFolderPermission]];
                [syncFile setStrFolderbIsOwner:[fDict objectForKey:kFolderbIsOwner]];
                [syncFile setStrIsFolder:[fDict objectForKey:kIsFolder]];
              
                [self.arrSyncDetails addObject:syncFile];
            }
            
            [self.tableView reloadData];

        }

    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}


#pragma mark - Create New Folder

- (void)APICreateFolder:(SyncFolder *)syncDetails andFolderName:(NSString *)strFolder{
    
    
//    NSLog(@"Endpoint Value:%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] objectAtIndex:0] mutableCopy]);
    [[LSyncAPIClient sharedClient]POST:[NSString localizedStringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] objectAtIndex:0] mutableCopy],kCreateFolderServiceName] parameters:[self dictionaryForFolderCreation:syncDetails withFolderName:strFolder] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.arrSyncDetails removeAllObjects];
        kpageindex = 1;
        [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        
    }];
    
    
}



#pragma MARK - Constructors

/*
 Dictionary for Sync File Folders
 */
-(NSMutableDictionary *)createRequestDictWithFolder:(SyncFolder *)objDoc{
//#warning It was OwnerId of Folder for key 'kUserId', now Pratik has changed to UserId of logged in user
   
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if ([objDoc.strIsFolder boolValue]) {
        NSString *userId = [TempStorage GetCustomKeyWithValue:kUserId];   // UserId of logged in user
        NSString *parentsOwnerId = [TempStorage GetCustomKeyWithValue:kUserId];
        
        
        [requestDict setValue:objDoc.strFolderId forKey:kFolderId];
        [requestDict setValue:bIsAscending forKey:kIsAscending];//ktrue
        [requestDict setValue:self.strSortBy forKey:kOrderBy];//kdtCreated
        [requestDict setValue:[NSString stringWithFormat:@"%d",kpageindex] forKey:kPageNumber];
        [requestDict setValue:[NSString stringWithFormat:@"%d",kListPageSize] forKey:kPageSize];
        [requestDict setValue:userId forKey:kUserId];
        
        int detVal = 1;
        BOOL blVal  = detVal;
        if (blVal == [objDoc.strFolderbIsOwner intValue]) {
           [requestDict setValue:parentsOwnerId forKey:kParentsOwnerId]; // Added by Pratik...
        }else{
            [requestDict setValue:objDoc.strFolderOwnerId forKey:kParentsOwnerId]; // Added by Pratik...
        }
        
        
    }else{
        NSString *userId = [TempStorage GetCustomKeyWithValue:kUserId];   // UserId of logged in user
        NSString *parentsOwnerId = [TempStorage GetCustomKeyWithValue:kUserId];               // Owner of the Folder
        
        
        [requestDict setValue:[TempStorage GetCustomKeyWithValue:kRootFolderId] forKey:kFolderId];
        [requestDict setValue:bIsAscending forKey:kIsAscending];
        [requestDict setValue:self.strSortBy forKey:kOrderBy];
        [requestDict setValue:[NSString stringWithFormat:@"%d",kpageindex] forKey:kPageNumber];
        [requestDict setValue:[NSString stringWithFormat:@"%d",kListPageSize] forKey:kPageSize];
        [requestDict setValue:userId forKey:kUserId];
        [requestDict setValue:parentsOwnerId forKey:kParentsOwnerId]; // Added by Pratik...
    }
    
    
    
   
//    NSLog(@"FolderDetails:%@", requestDict);
    
    return [NSMutableDictionary dictionaryWithObject:requestDict forKey:kgetFileFolderListRequest];
}

/*
 Dictionary for Folder Creation
 */

- (NSMutableDictionary *)dictionaryForFolderCreation: (SyncFolder *)folderSyncDetails withFolderName:(NSString *)strFolderName{
    
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kCreatorId];
    
    [requestDict setValue:strFolderName forKey:kFolderName];
    
    [requestDict setValue:folderSyncDetails.strFolderId forKey:kLinkToParentId];
    [requestDict setValue:folderSyncDetails.strFolderOwnerId forKey:kOwnerId];
    [requestDict setValue:folderSyncDetails.strFolderOwnerOrgId forKey:kOwnerOrgId];
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kcreateFolderRequest]];
    
    
    return ParamDict;
}


/*
 Rename Folder Contructor
 */
- (NSMutableDictionary*)dictForRenamingFolder :(SyncFolder*)syncDetails NewFolderName:(NSString *)strFolderName{
    // create request object
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setValue:syncDetails.strFolderId   forKey:kFolderId];
    
    [requestDict setValue:strFolderName forKey:kFolderName];
    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kRenameFolderRequest]];
    
    return ParamDict;
}

/*
 Disable SYNC
 */

- (NSMutableDictionary *)dictForDisablingSYNC :(SyncFolder*)syncDetails{
    
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    f.numberStyle = NSNumberFormatterDecimalStyle;
//    NSNumber *myNumber = [f numberFromString:syncDetails.strFolderCanSync];
    
    
    // create request object
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    //  [requestDict setValue:([objDoc getFolderCanSync]) ? @"False" : @"True" forKey:kCanSync];
    BOOL isEnabled = [syncDetails.strFolderCanSync intValue];
    NSString *strSync = isEnabled ? kfalse : ktrue;
    [requestDict setValue:strSync forKey:kCanSync];
    [requestDict setValue:syncDetails.strFolderId forKey:kFolderId];
    [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kEnableDisableSyncRequest]];
    
    
    return ParamDict;
}


#pragma MARK - Selectors

- (void)chooseUploadAction{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Add"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Cloud",@"Upload Photo",@"Create Folder", nil];
    
    //Should have send File to LSFT Option
    
    [actionSheet showInView:self.view];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
        [actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    }];
}


- (void)CreateFolderName{
    UIAlertView* alertFolderName = [[UIAlertView alloc]initWithTitle:@"Create New Folder" message:@"Folder Name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertFolderName setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertFolderName show];
}


- (void)SelectPhotoForUpload{
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)DeleteFileFolderConfirmation{
    SyncFolder* folderSyncDets = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
    NSLog(@"Folder Permission:%i || FolderIsOwner:%i",(int)[folderSyncDets.strFolderPermission integerValue], (int)[folderSyncDets.strFolderbIsOwner integerValue]);
    // Delete button was pressed
    //f4ad207f-7fe1-431c-ab29-73355cbc13d2
    if([folderSyncDets.strFolderPermission integerValue] == kViewModifyPermission || [folderSyncDets.strFolderbIsOwner integerValue]== 0)
    {
//        NSString* strFldrOiD = @"";
        
        
        NSMutableArray* arrTp = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:folderSyncDets.strDocumentId.length > 0 ? folderSyncDets.strDocumentId:folderSyncDets.strFolderId, kFileFolderId, folderSyncDets.strIsFolder, kIsFileFolder, nil]];
        // create request object
        NSMutableDictionary * requestDict;
        requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setValue:arrTp forKey:kDeleteFilesFoldersList];
        [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
        
        NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kDeleteFolderRequest]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        //    [manager setSecurityPolicy:policy];
        [manager POST:[NSString localizedStringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kDeleteFileFolderServiceName] parameters:ParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //                 NSMutableDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"DeleteResponse:%@ || ClassSuccess:%@", responseObject, [[responseObject objectForKey:kSuccess] class]);
            
            //        NSLog(@"JSON: %@", responseObject);
            
            //        [[[]]];
            //                        kSuccess
            if ([[responseObject objectForKey:kSuccess] boolValue] ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"File Deleted Successfully"];
                
                //                         [self GetSyncData:YES andWithSyncFolderData:folderSyncDets];
                if (![self.insideSyncFolderDetails.strFolderId isEqualToString:folderSyncDets.strFolderId]) {
                    [self.arrSyncDetails removeAllObjects];
                    kpageindex = 1;
                    [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                }
                
                
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:@"File Deleted Failed!"];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        
        
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"You don't have permission to Modify this folder." delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil, nil];
        [alert show];
    }

}



#pragma MARK - AlertView / Actionsheet Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    

    
    switch (alertView.tag) {
        case kMoveToOtherFoldersAlrtTag:
        {
            NSLog(@"IndexSelected:%i",(int)buttonIndex);
            switch (buttonIndex) {
                case 0:break; // Cancel Clicked
                    
                default:{
                    SyncFolder* getMovedToFolderData = [self.arrFolderList objectAtIndex:buttonIndex-1];
                    SyncFolder* getMovedFromFolderData = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    
                    
                    
                    [self MoveInToNewFolder:getMovedToFolderData withCurrentFolderData:getMovedFromFolderData];
                }
                    break;
            }
        }
            break;
        case kDisableSyncFolder:
        {
            switch (buttonIndex) {
                case 1:
                {
                    SyncFolder* syncDetSelected = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    //            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    //            f.numberStyle = NSNumberFormatterDecimalStyle;
                    //            NSNumber *myNumber = [f numberFromString:syncDetSelected.strFolderCanSync];
                    //            ([objDoc getFolderCanSync]) ? kAlertDisableSyncQuestion : kAlertEnableSyncQuestion
                    
                    BOOL isEnabled = [syncDetSelected.strFolderCanSync intValue];
                    
                    
                    [APIRequests DisableSyncFolder:[self dictForDisablingSYNC:syncDetSelected] withCompletionBlock:^(BOOL success, NSError *error) {
                        if (success) {
                            [[[UIAlertView alloc]initWithTitle:@"SYNC" message:isEnabled ? @"Successfully Disabled sync" : @"Successfully Enabled Sync" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                            kpageindex = 1;
                            [self.arrSyncDetails removeAllObjects];
                            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                        }
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case kDeleteFileFolders:{
            switch (buttonIndex) {
                case 1:
                {
                    [self DeleteFileFolderConfirmation];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case kRenameFolderSD:
        {
            switch (buttonIndex) {
                case 1:
                {
                    NSString* strRename = @"";
                    SyncFolder* syncDetSelected = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    
                   
                        
                        if ([[alertView textFieldAtIndex:0]text].length>0){
                            strRename = [[alertView textFieldAtIndex:0]text];
                            //                [APIRequests RenameFile:syncDetSelected newName:strRename withCompletionBlock:^(BOOL success, NSError *error) {
                            //                }];
                            [APIRequests RenameFolder:[self dictForRenamingFolder:syncDetSelected NewFolderName:strRename] withCompletionBlock:^(BOOL success, NSError *error) {
                                if (success) {
                                    [[[UIAlertView alloc]initWithTitle:@"Rename" message:@"Successfully Renamed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                                    [self.arrSyncDetails removeAllObjects];
                                    [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                                }
                            }];
                        }

                        
                    

                }
                    break;
                    
                default:
                    break;
            }

        }
            break;
        case kRenameFileSD:
        {
            switch (buttonIndex) {
                case 1:
                {
                    NSString* strRename = @"";
                    SyncFolder* syncDetSelected = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    if ([[alertView textFieldAtIndex:0]text].length>0){
                        strRename = [[alertView textFieldAtIndex:0]text];
                        [APIRequests RenameFile:syncDetSelected newName:strRename withCompletionBlock:^(BOOL success, NSError *error) {
                            if (success) {
                                [[[UIAlertView alloc]initWithTitle:@"Rename" message:@"Successfully Renamed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
                                kpageindex = 1;
                                [self.arrSyncDetails removeAllObjects];
                                [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                            }
                        }];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case kMovetoRootFiles:
        {
                SyncFolder* selectedSyncDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 1:
                {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:selectedSyncDetails.strDocumentUrl]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[selectedSyncDetails.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],selectedSyncDetails.strDocumentExtension]];
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
                    
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Successfully downloaded file to %@", path);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                    [operation start];
//                    [self FileDownloadMng:[paths objectAtIndex:0] withDocDets:selectedSyncDetails];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
            
        case kMovetoFavsFiles:
        {
                SyncFolder* selectedSyncDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 1:
                {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:selectedSyncDetails.strDocumentUrl]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    //
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/MyFavs"];
                    
                    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder

//                    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[selectedSyncDetails.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],selectedSyncDetails.strDocumentExtension]];
                    NSString *path = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[selectedSyncDetails.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],selectedSyncDetails.strDocumentExtension]];
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
                    
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Successfully downloaded file to %@", path);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                    [operation start];
                    //                    [self FileDownloadMng:[paths objectAtIndex:0] withDocDets:selectedSyncDetails];
                }
                    break;
                    
                default:
                    break;
            }

        }
            break;
        case kCompareFilesAlrtTag:{
                SyncFolder* selectedSyncDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 0:
                    [self.arrCompareFile removeAllObjects];
                    break;
                    
                default:{
                    if (self.arrCompareFile.count == 2) {
                        [self CompareFile];
                    }else{
                        [self.arrCompareFile addObject:selectedSyncDetails];
                        if (self.arrCompareFile.count == 2) {
                            [self CompareFile];
                        }
                    }
                }
                    break;
            }
            
        }
            break;
        case kMovePushToFolderAlertTagiPhone:
        {
            switch (buttonIndex) {
                case 1:
                {
                    
                    
                    NSString* strPasteFromFolder = [TempStorage GetCustomKeyWithValue:gSaveFolderNameTemp];
                    
                    if ([self.insideSyncFolderDetails.strFolderName isEqualToString:strPasteFromFolder]) {
                        kpageindex = 1;
                        [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
                    }else{
                    
                    SyncViewCellTableViewController* anotherSyncDta = [[SyncViewCellTableViewController alloc]initWithSyncFolderDetails:self.syncMoveDetailsFrom andViewDisplay:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:anotherSyncDta animated:YES];
                        
                    }
                }
                    break;
                    
                default:{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Please refresh you page."]];
                }
                    break;
            }
        }
            break;
        case kMoveBacktoRootAlertTagiPhone:
        {
            switch (buttonIndex) {
                case 1:
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                    break;
                    
                default:
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"Please refresh you page."]];
                }
                    break;
            }
        }
            break;
        case kLSFTSyncFileDownload:
        {
            switch (buttonIndex) {
                case 1:
                {
                    
                    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    [self DownloadFile:syncDetSelectedIndex];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kLSFTAttachFile:
        {
            switch (buttonIndex) {
                case 1:
                {
                    fileAttachToLSFT = YES;
                    SyncFolder* syncDetSelected = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
//                    MBProgressHUD* progHud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//
//                    [progHud setMode:MBProgressHUDModeIndeterminate];
//                    [progHud setLabelText:@"Attaching file to LSFT..."];
//                    [progHud show:YES];
//                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self DownloadFile:syncDetSelected];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
        {
            SyncFolder* sync = [SyncFolder new];
                if (self.insideSyncFolderDetails.strFolderId.length>0) {
                    sync = self.insideSyncFolderDetails;
                }else{
                    sync.strFolderId = [TempStorage GetCustomKeyWithValue:kRootFolderId];
                    sync.strFolderOwnerId = [TempStorage GetCustomKeyWithValue:kUserId];
                    sync.strFolderOwnerOrgId = [TempStorage GetCustomKeyWithValue:kOrganizationId];
                }
            if ([[alertView textFieldAtIndex:0]text].length>0){
                [self APICreateFolder:sync andFolderName:[[alertView textFieldAtIndex:0]text]];
            }

        }
            break;
    }
}

- (void)FileDownloadMng:(NSString*)filePath withDocDets:(SyncFolder*)syncF{
    //Configuring the session manager
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //Most URLs I come across are in string format so to convert them into an NSURL and then instantiate the actual request
    NSURL *formattedURL = [NSURL URLWithString:syncF.strDocumentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:formattedURL];
    
    //Watch the manager to see how much of the file it's downloaded
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //Convert totalBytesWritten and totalBytesExpectedToWrite into floats so that percentageCompleted doesn't get rounded to the nearest integer
        CGFloat written = totalBytesWritten;
        CGFloat total = totalBytesExpectedToWrite;
        CGFloat percentageCompleted = written/total;
        NSLog(@"Percentage:%f", percentageCompleted);
        
        //Return the completed progress so we can display it somewhere else in app
        [[MRNavigationBarProgressView progressViewForNavigationController:self.navigationController] setProgress:percentageCompleted animated:YES];
        
        //        [[MRProgressOverlayView showOverlayAddedTo:self.view animated:YES] setmode];
        //        [[MRProgressOverlayView showOverlayAddedTo:self.view animated:YES] setModeView:self.view];
        
    }];
    
    //Start the download
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //Getting the path of the document directory
        //        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL* documentsDirectoryURL = [NSURL URLWithString:filePath];
        NSURL *fullURL = [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",syncF.strDocumentName,syncF.strDocumentExtension]];
        
        //If we already have a video file saved, remove it from the phone
        //        [self removeVideoAtPath:fullURL];
        return fullURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            //If there's no error, return the completion block
            //            completionBlock(filePath);
            NSLog(@"Completed In:%@", [filePath absoluteString]);
            //    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//            NSURLRequest* request = [NSURLRequest requestWithURL:filePath cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            
//            [self.webViewer loadRequest:request];
            
            
        } else {
            //Otherwise return the error block
            //            errorBlock(error);
            //    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }
        
    }];
    
    [downloadTask resume];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (actionSheet.tag) {
            
        case kMoveActSheetTag:{
            SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 0://Move to Root
                {
                    [self MovetoRoot:syncDetSelectedIndex];
                }
                    break;
//                case 1:// Move to Other Folders
//                {
//                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Move" message:@"Please Select a Folder to Move." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//                    [view setTag:kMoveToOtherFoldersAlrtTag];
////                    NSArray *yourArray = @[@"1",@"2",@"3",@"1"];
//                    NSMutableArray *result = [NSMutableArray new];
////                    [self.arrFolderList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
////                        SyncFolder* TSync = obj;
////                        if (![result containsObject:TSync.strFolderId]) {
////                            [result addObject:obj];
////                        }
////                    }];
//
//                    
//                    
//                    
//                    for(SyncFolder* syncData in self.arrSyncDetails){//self.arrFolderList
//                        
//                        BOOL isTrueFolder = [syncData.strIsFolder boolValue];
//                        if (isTrueFolder) {
//                            [self.arrFolderList addObject:syncData];
//                            [view addButtonWithTitle:syncData.strFolderName];                            
//                        }
//                        
//                        
//                    }
//                    [view show];
//                }
//                    break;
                case 1:
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshSYNCList object:[NSString stringWithFormat:@"You copied %@ %@", [syncDetSelectedIndex.strIsFolder boolValue] ? @"Folder" : @"File",[syncDetSelectedIndex.strIsFolder boolValue] ? syncDetSelectedIndex.strFolderName : syncDetSelectedIndex.strDocumentName]];

                    });
                   
                    [self SaveDataFiletoClipboard:syncDetSelectedIndex];
   
                }
                    break;
                case 3:
                {
                    
                    
                    if ([self checkifClipboardhasItem]) {
                        NSMutableDictionary* dctClipboard = [TempStorage GetCustomKeyWithValue:@"sClipboardTempFile"];
                        BOOL isNaturalFolder = [dctClipboard objectForKey:@"IsFolder"];
//                        NSLog(@"Class Type:%@",[[dctClipboard objectForKey:@"IsFolder"] class]);
                        if (isNaturalFolder) {
                            
                            SyncFolder* getMovedToFolderData = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                            NSLog(@"Folder Name:%@", getMovedToFolderData.strFolderName);
                            
                            SyncFolder* clipboardSyncData = [[SyncFolder alloc]init];
                            clipboardSyncData.strFolderName = [dctClipboard objectForKey:@"FolderName"];
                            clipboardSyncData.strFolderId = [dctClipboard objectForKey:@"FolderId"];
                            clipboardSyncData.strFolderPermission = [dctClipboard objectForKey:@"FolderPermission"];
                            clipboardSyncData.strFolderbIsOwner = [dctClipboard objectForKey:@"FolderbIsOwner"];
                            clipboardSyncData.strIsFolder = [dctClipboard objectForKey:@"IsFolder"];
                            clipboardSyncData.strDocumentId = [dctClipboard objectForKey:@"DocumentId"];
                            clipboardSyncData.strFolderCanSync = [dctClipboard objectForKey:@"FolderCanSync"];
                            
                            [self MoveInToNewFolder:getMovedToFolderData withCurrentFolderData:clipboardSyncData];
                            
                        }else{
                            
                        }
                        
                        
                        
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case kFolderOptActSheetTag:{
//            @"Share" otherButtonTitles:@"Disable Sync",@"Rename",@"Delete", nil];
            SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 0://Share
                {
                    self.syncSelectedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    
                    // Launch Share
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//                    
//                    ShareViewController *shareView = [storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
//                    shareView.syncPassedDetails = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
//                    NavHomeViewController* navLog = [[NavHomeViewController alloc]initWithRootViewController:shareView];
//                    
                    
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"custom" bundle: nil];
                        
                        ShareOptViewController* shareOpt = [storyboard instantiateViewControllerWithIdentifier:@"ShareOptViewController"];
                        shareOpt.insideFolderSyncDetails = syncDetSelectedIndex;
                        
                        NavHomeViewController* navLog = [[NavHomeViewController alloc]initWithRootViewController:shareOpt];
      
                        navLog.modalPresentationStyle = UIModalPresentationFormSheet;
                        navLog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self presentViewController:navLog animated:YES completion:nil];
                        });
                        
                    }else{
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"custom" bundle: nil];
                        
                        ShareOptViewController* shareOpt = [storyboard instantiateViewControllerWithIdentifier:@"ShareOptViewController"];
                        shareOpt.insideFolderSyncDetails = syncDetSelectedIndex;
                        
                        NavHomeViewController* navLog = [[NavHomeViewController alloc]initWithRootViewController:shareOpt];
                        
                        [self presentViewController:navLog animated:YES completion:nil];
                    }
                    
                }
                    break;
//                case 1://Disable Sync
//                {
////                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
////                    f.numberStyle = NSNumberFormatterDecimalStyle;
////                    NSNumber *myNumber = [f numberFromString:syncDetSelectedIndex.strFolderCanSync];
////                    if([myNumber isEqualToNumber:[NSNumber numberWithBool:TRUE]])
////                    {
////
////                    }
//                    
//                    BOOL isEnabled = [syncDetSelectedIndex.strFolderCanSync intValue];
//
//                    UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"SYNC" message:isEnabled ? kAlertDisableSyncQuestion : kAlertEnableSyncQuestion delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//                    [alertSync setTag:kDisableSyncFolder];
////                    [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
//                    [alertSync show];
//                }
//                    break;
                case 1://Rename
                {
                    
                    BOOL isFOwner = [syncDetSelectedIndex.strFolderbIsOwner boolValue];
                    
                    if(![syncDetSelectedIndex strFolderCanSync])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:[NSString stringWithFormat:@"File Can't be modified because sync is disabled on %@",syncDetSelectedIndex.strFolderName] delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                        [alert show];
                    }
                    
                    else if(!isFOwner)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertFileModifyPermissionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                        [alert show];
                    }
                    
                    else{
                    
                    UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Rename" message:@"Enter new Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                    [alertSync setTag:kRenameFolderSD];
                    [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertSync textFieldAtIndex:0] setText:syncDetSelectedIndex.strFolderName.length>1 ? syncDetSelectedIndex.strFolderName : syncDetSelectedIndex.strDocumentName];
                    [alertSync show];
                        
                    }
                }
                    break;
                case 2://Delete
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"Are you sure you want to Delete?" delegate:self cancelButtonTitle:kCancel otherButtonTitles:kOk, nil];
                    [alert setTag:kDeleteFileFolders];
                    [alert show];
                }
                    break;
                default:// Cancel
                    break;
            }
            
        }
            break;
        
        case kFileOptActSheetTag:{
            
//            destructiveButtonTitle:@"Download" otherButtonTitles:@"Export",@"Rename",@"Delete", nil];
            SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
            switch (buttonIndex) {
                case 0:// Download
                {
                    [self DownloadFile:syncDetSelectedIndex];
                }
                    break;
//                case 1:// Export
//                {
//                    bForDocumentExport = YES;
//                    [self SaveInInbox:syncDetSelectedIndex];
//                }
//                    break;
                case 1:// Rename
                {
                    
                    if(![syncDetSelectedIndex strFolderCanSync])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:[NSString stringWithFormat:@"File Can't be modified because sync is disabled on %@",syncDetSelectedIndex.strFolderName] delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                        [alert show];
                    }
                    
                    else if(![syncDetSelectedIndex strFolderbIsOwner] && [[syncDetSelectedIndex strFolderPermission] integerValue] != kViewModifyPermission)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppAlertTitle message:kAlertFileModifyPermissionMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:kOk, nil];
                        [alert show];
                    }
                    
                    else{
                        
                        UIAlertView* alertSync = [[UIAlertView alloc]initWithTitle:@"Rename" message:@"Enter new Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                        [alertSync setTag:kRenameFileSD];
                        [alertSync setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [[alertSync textFieldAtIndex:0] setText:syncDetSelectedIndex.strFolderName.length > 1 ? syncDetSelectedIndex.strFolderName : syncDetSelectedIndex.strDocumentName];
                        [alertSync show];
                        
                    }
                    
                    
                   
                }
                    break;
                case 2://Delete
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppAlertTitle message:@"Are you sure you want to Delete?" delegate:self cancelButtonTitle:kCancel otherButtonTitles:kOk, nil];
                    [alert setTag:kDeleteFileFolders];
                    [alert show];
                }
                    break;
                default://Cancel
                    break;
            }
            
            
        }
            break;
            
        case 6657:
        {
            switch (buttonIndex) {
                    
                case 0:
                {
                    bForDocumentExport = YES;
//                    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:SelectedIndex];
                    
                    
                    SyncFolder* syncDetSelectedIndex = [self.arrSyncDetails objectAtIndex:self.selectedCellIndex.row];
                    
//                    BOOL isAvailableAsLocalFile = [self isFilePresentinDir:syncDetSelectedIndex.strDocumentName];
                    
                    
                    
//                    if(isAvailableAsLocalFile){
//                        
//                        
//                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"Inbox/%@%@",[syncDetSelectedIndex.strDocumentName stringByReplacingOccurrencesOfString:@" " withString:@"_"],syncDetSelectedIndex.strDocumentExtension]];
//                        
//                        [self ShowDocumentExportOption:[NSURL fileURLWithPath:path]];
//                    }else{
//                        [self DownloadFile:syncDetSelectedIndex];
                        [self SaveInInbox:syncDetSelectedIndex];
//                    }
                    

                }
                    break;
                case 2:
                {
                    
                    if ([[TempStorage GetCustomKeyWithValue:bLSFYLoginSucess]isEqualToString:@"YES"]) {
                        AppDelegate* delAPp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        
                        SyncFolder* folderDet = [self.arrSyncDetails objectAtIndex:SelectedIndex];
                        
                        LSFTCreateMessageViewController* lsftVw = [[LSFTCreateMessageViewController alloc]initWithFileUrl:folderDet.strDocumentUrl WithFileType:folderDet.strDocumentExtension andFileName:[folderDet.strDocumentName stringByAppendingString:folderDet.strDocumentExtension]];
                        
                        NavHomeViewController* naviH = [[NavHomeViewController alloc]initWithRootViewController:lsftVw];
                        [delAPp.drawerViewController setCenterViewController:naviH];
                    }else{
                        [[[UIAlertView alloc]initWithTitle:@"LSFT Login" message:@"Please login using your account in LSFT." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil]show];
                    }
                    
//                    AppDelegate* delAPp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                    
//                    
//                    LSFTCreateMessageViewController* lsftVw = [[LSFTCreateMessageViewController alloc]initWithStyle:UITableViewStyleGrouped];
//                    
//                    NavHomeViewController* naviH = [[NavHomeViewController alloc]initWithRootViewController:lsftVw];
//                    [delAPp.drawerViewController setCenterViewController:naviH];
//                    [delAPp toggleLeftDrawer:self animated:YES];

                }
                    break;
                    
                default:{
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//                    
//                    ShareViewController *shareView = [storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
//                    NavHomeViewController* navLog = [[NavHomeViewController alloc]initWithRootViewController:shareView];
//                    
//                    [self presentViewController:navLog animated:YES completion:nil];
                }
                    break;
            }
        }
            break;
            
//            @"Date Modified",@"Name A-Z",@"Name Z-A", nil];//, @"Type"

        case kSyncIphoneSort:{
            switch (buttonIndex) {
                case 0:// Date Modified
                {
                    self.strSortBy = @"ModifiedDate";
                    
                    [self refreshTable];
                }
                    break;
                case 1:// Name
                {
                    self.strSortBy = @"Name";
                    bIsAscending = @"true";
                    [self refreshTable];
                }
                    break;
//                case 2:// Size
//                {
//                    self.strSortBy = @"CreatedDate";
//                }
//                    break;
                case 2:// Type
                {
                    self.strSortBy = @"Name";
                    bIsAscending = @"false";
                    [self refreshTable];
                }
                    break;
                default:// Cancel
                    break;
            }
            
//            kpageindex = 1;
//            [self GetSyncData:YES andWithSyncFolderData:self.insideSyncFolderDetails];
        }
            break;
            
        default:
        {
            switch (buttonIndex) {
                case 2://Create Folder
                {
                    [self CreateFolderName];
                }
                    break;
                case 1:
                {
//                    [self SelectPhotoForUpload];
                    [self SelectPhotosECL];
                }
                    break;
                case 0:
                {
//                    iCloudViewController* iclVw = [[iCloudViewController alloc]initWithStyle:UITableViewStyleGrouped];
//                    
//                    NavHomeViewController* naviCloudVw = [[NavHomeViewController alloc]initWithRootViewController:iclVw];
//                    
//                    [self presentViewController:naviCloudVw animated:YES completion:nil];
                    
                   
                    
                    
                    
                    
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        UIDocumentMenuViewController *importMenu =
                        [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.png",@"public.image", @"com.adobe.pdf", @"public.plain-text", @"public.text",@"public.archive",@"public.movie",@"public.data", @"public.presentation",@"public.audio",@"com.microsoft.excel.xls",@"public.jpeg",@"com.apple.iwork.pages.pages", @"com.apple.iwork.numbers.numbers", @"com.apple.iwork.keynote.key"]
                                                                             inMode:UIDocumentPickerModeImport];
                        importMenu.delegate = self;
                        //                    importMenu.modalPresentationStyle = UIModalPresentationFormSheet;
                        //                    [self presentViewController:importMenu animated:YES completion:nil];
                        //  importMenu.delegate = self;
                        //  [self presentViewController:importMenu animated:YES completion:nil];
                        importMenu.modalPresentationStyle = UIModalPresentationPopover;
                        importMenu.popoverPresentationController.sourceView = self.view;
                        importMenu.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds),0,0);
                        //                    importMenu.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
                        //documentMenu.popoverPresentationController.sourceView = self.view;
                        //documentMenu.should have a non-nil sourceView or barButtonItem set before the presentation occurs
                        //                    [self presentViewController: importMenu animated:YES completion: ^{
                        //                        NSLog(@"DocumentPicker presented completion");
                        //                    }];
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self presentViewController:importMenu animated:YES completion:nil];
                        });
                    }else{
                        UIDocumentMenuViewController *importMenu =
                        [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.png",@"public.image", @"com.adobe.pdf", @"public.plain-text", @"public.text",@"public.archive",@"public.movie",@"public.data", @"public.presentation",@"public.audio",@"com.microsoft.excel.xls",@"public.jpeg",@"com.apple.iwork.pages.pages", @"com.apple.iwork.numbers.numbers", @"com.apple.iwork.keynote.key"]
                                                                             inMode:UIDocumentPickerModeImport];
                        importMenu.delegate = self;
                        
                        importMenu.modalPresentationStyle = UIModalPresentationFormSheet;
                        importMenu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self presentViewController:importMenu animated:YES completion:nil];
                        });
                        
                    }
                    
                }
                    break;
                default:{
                    
                }
                    break;
            }
        }
            break;
    }
    
    
}

#pragma mark - iCloud
- (NSData*)bookmarkForURL:(NSURL*)url {
    NSError* theError = nil;
    NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&theError];
    if (theError || (bookmark == nil)) {
        // Handle any errors.
        return nil;
    }
    return bookmark;
}
- (NSURL*)urlForBookmark:(NSData*)bookmark {
    BOOL bookmarkIsStale = NO;
    NSError* theError = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        // Handle any errors
        return nil;
    }
    return bookmarkURL;
}


- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu{
    
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    [documentMenu.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [documentPicker setDelegate:self];
    [self presentViewController:documentPicker animated:YES completion:nil];
}
NSString* strLenOfFileIphone;
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    NSLog(@"Selected URL:%@", url);
    
     BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSData* newData = [self bookmarkForURL:url];
        NSURL* newNsUrlRes = [self urlForBookmark:newData];
        NSLog(@"Gator:%@", [newNsUrlRes absoluteString]);
        
//        BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
        NSURL *ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSLog(@"ubiquityURL - %@",ubiquityURL);
        
        if(fileUrlAuthozied){
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
            NSError *error;
            
            [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
                
                NSData *data = [NSData dataWithContentsOfURL:newURL];
                strLenOfFileIphone = [NSString stringWithFormat:@"%@", [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]];
                NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
                //Do something with data
                [self CreateLocalFileCopy:data withFileName:[newURL lastPathComponent]];
               
                [url stopAccessingSecurityScopedResource];
               
                
            }];
            
        }else{
            //Error handling
            
            NSData *data = [NSData dataWithContentsOfURL:url];
            strLenOfFileIphone = [NSString stringWithFormat:@"%@", [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]];
            NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
            
            NSLog(@"len:%i", (int)data.length );
            
            //Do something with data
            [self CreateLocalFileCopy:data withFileName:[url lastPathComponent]];
            
        }
        
        
        
        
    });
}


- (void)CreateLocalFileCopy:(NSData *)fileData withFileName:(NSString *)strFile{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/iCloudTempFiles"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Generate the file path
        
        NSString *DocdataPath = [dataPath stringByAppendingPathComponent:strFile];
        
        // Save it into file system
        BOOL isDoneWriting = [fileData writeToFile:DocdataPath atomically:YES];
        
        if (isDoneWriting) {
            NSURL* urlForiCLoudTmp = [NSURL fileURLWithPath:DocdataPath];
            //            NSData* newDoc = [NSData dataWithContentsOfURL:[NSURL URLWithString:DocdataPath]];
            
            
            if ([urlForiCLoudTmp isFileURL]) {
                //                NSString *path = [urlForiCLoudTmp path];
                //                NSData *data = [NSData dataWithContentsOfURL:urlForiCLoudTmp];
                NSData *data = [[NSFileManager defaultManager] contentsAtPath:DocdataPath];
                NSLog(@"%@ || FilePath: %@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile], DocdataPath);
//                NSDictionary* dictFileData = [[NSDictionary alloc]initWithObjects:@[strFile, data, [DocdataPath pathExtension]] forKeys:@[@"name", @"data", @"fileType"]];
                [UploadFiles UploadFileswithObject:DocdataPath SyncFolderData:self.insideSyncFolderDetails inView:self.view withCompletion:^(BOOL success, NSError *error) {
                    
                }];
                
            }
            
        }
        
    });
    
    
    
    
}
#pragma mark - File Dir Handlers

- (void)ShowDocumentExportOption:(NSURL *)fileUrl{
    // Initialize Document Interaction Controller
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[fileUrl absoluteString]]];
    NSString *strUTI = [[fileUrl lastPathComponent] stringByDeletingPathExtension];
    
    self.documentInteractionController.UTI = strUTI;
    // Configure Document Interaction Controller
    [self.documentInteractionController setDelegate:self];
    
    // Preview PDF
    [self.documentInteractionController presentPreviewAnimated:YES];

}

- (BOOL)isFilePresentinDir:(NSString *)strName{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];

    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"Inbox/%@",[strName stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
//    NSArray *directory = [[NSFileManager defaultManager] directoryContentsAtPath: [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Inbox"]];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (exists) {
        /* file exists */
        return YES;
//        if (isDir) {
//            /* file is a directory */
//        }
    }else{
        return NO;
    }

}




- (void)dirTransfertoInbox: (NSURL *)url{

        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* inboxPath;
        if([paths count] > 0)
        {
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSError *error = nil;
           inboxPath  = [documentsDirectory stringByAppendingPathComponent:@"InboxT"];
            
        }
//
//        NSData *urlData = [NSData dataWithContentsOfURL:url];
//        if ( urlData )
//        {
//            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString  *documentsDirectory = [paths objectAtIndex:0];
//            
//            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.png"];
//            [urlData writeToFile:filePath atomically:YES];
//        }
    NSError *Error = nil;
//    if(![[NSFileManager defaultManager]fileExistsAtPath:[inboxPath stringByAppendingPathComponent:[url lastPathComponent]]])
//    {
    
    NSString* baseUrlPath = [url absoluteString];
    NSString *newUrlPath = [inboxPath stringByAppendingPathComponent:[url lastPathComponent]];
//    NSDictionary *fileDictionary = [[NSFileManager defaultManager]];
//    int fileSize = [fileDictionary fileSize];
        if([[NSFileManager defaultManager]copyItemAtPath:baseUrlPath toPath:newUrlPath error:&Error]==YES)
        {
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"copy" message:[NSString stringWithFormat:@"%@",Error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [Alert show];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:[inboxPath stringByAppendingPathComponent:[url lastPathComponent]] error:NULL];
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"Not copy" message:[NSString stringWithFormat:@"%@",Error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [Alert show];
        }
//    }
    
}



#pragma MARK - CTAssetsPickerController Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSMutableDictionary* imgDetailsArr = [[NSMutableDictionary alloc]init];
    NSMutableArray* arryT = [NSMutableArray new];
    NSMutableArray* arryImages = [NSMutableArray new];
    // assets contains PHAsset objects.
    
    for (PHAsset* assetRaw in assets) {
//        assetRaw.req
        [assetRaw requestContentEditingInputWithOptions:0
                                   completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                                       
                                       
                                       
                                       NSURL *imageURL = contentEditingInput.fullSizeImageURL;
                                       
                                       NSArray *resources = [PHAssetResource assetResourcesForAsset:assetRaw];
                                       NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
                                       NSArray *myArray = [orgFilename componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
                                       NSLog(@"Assets:%@ || FileName:%@  || Extension: %@ || FolderId:%@", imageURL, orgFilename, [myArray objectAtIndex:1], self.insideSyncFolderDetails.strFolderId);
                                       
                                       NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:kDirectoryDocuments] stringByAppendingPathComponent:kDirectoryCurrentUploadImages];
                                       
                                       BOOL isDirectory = YES;
                                       if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory])
                                       {
                                           NSError *err = nil;
                                           [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&err];
                                       }
                                       
                                       
                                       filePath = [[[NSHomeDirectory() stringByAppendingPathComponent:kDirectoryDocuments] stringByAppendingPathComponent:kDirectoryCurrentUploadImages] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",orgFilename]];
                                       
                                       if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:FALSE])
                                       {
//                                           NSError *err = nil;
                                           //            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&err];
                                           NSData *data;
                                           UIImage* imgh = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];

                                           if ([[[imageURL absoluteString] lowercaseString] isEqualToString:kPng])
                                           {
                                               data = UIImagePNGRepresentation(imgh);
                                           }
                                           else
                                           {
                                               data = UIImageJPEGRepresentation(imgh, 0.0);
                                           }
                                           if ([data writeToFile:filePath atomically:YES])
                                           {
                                               [imgDetailsArr setValue:orgFilename forKey:@"Filename"];
                                               [imgDetailsArr setValue:self.insideSyncFolderDetails.strFolderId forKey:@"FolderId"];
                                               [imgDetailsArr setValue:[@"." stringByAppendingString:[myArray objectAtIndex:1]] forKey:@"Extension"];
                                               [imgDetailsArr setValue:filePath forKey:@"imageUrl"];
                                               [imgDetailsArr setObject:imgh forKey:@"images"];
                                               [arryT addObject:imgDetailsArr];
                                               [arryImages addObject:imgh];

                                           }
                                           
                                       }else{
                                       
                                       
                                       
                                       
                                      
//                                       [imgDetailsArr addObject:[NSString stringWithFormat:@"%@,%@,%@,%@", orgFilename, self.insideSyncFolderDetails.strFolderId, [@"." stringByAppendingString:[myArray objectAtIndex:1]], [imageURL absoluteString]]];
                                       [imgDetailsArr setValue:orgFilename forKey:@"Filename"];
                                       [imgDetailsArr setValue:self.insideSyncFolderDetails.strFolderId forKey:@"FolderId"];
                                       [imgDetailsArr setValue:[@"." stringByAppendingString:[myArray objectAtIndex:1]] forKey:@"Extension"];
                                       [imgDetailsArr setValue:filePath forKey:@"imageUrl"];
                                               [arryT addObject:imgDetailsArr];
//                                               [self ComposeUploadDataFromImages:imgDetailsArr];
                                           
                                            UIImage* imgh = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
//                                           UIImage* imgh = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
//                                               [imgDetailsArr setObject:imgh forKey:@"images"];
                                           [arryImages addObject:imgh];
                                           
                                       }
                                       
                                       
                                      [self ComposeUploadDataFromImages:arryT images:arryImages];
                                   }];
        
    }
    

    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)ComposeUploadDataFromImages: (NSMutableArray *)imgArr images:(NSMutableArray *)imgOAr{
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* imgDetD in imgArr) {
        
        
        [requestDict setValue:[[imgDetD valueForKey:@"Extension"] stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:kDataFormat];
        [requestDict setValue:[imgDetD valueForKey:@"Filename"] forKey:kDocumentName];
        [requestDict setValue:[imgDetD valueForKey:@"Extension"]  forKey:kExtension];
        [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kOwnerId];
        [requestDict setValue:kPermissionValue forKey:kPermission];
        [requestDict setValue:[TempStorage GetCustomKeyWithValue:kUserId] forKey:kUserId];
        [requestDict setValue:[imgDetD valueForKey:@"FolderId"] forKey:kFolderId];
        [requestDict setValue:kVersionValue forKey:kVersion];
        
//        
        
        
        

        NSMutableArray *array = [[NSMutableArray alloc] init];
        const unsigned char *bytes;
        
//        NSString* strGPath = [imgDetD valueForKey:@"imageUrl"];
        NSError *error = nil;
        unsigned long long currentFileSize = 0;
        NSDictionary *attributes = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:[imgDetD valueForKey:@"imageUrl"] error:&error];
        
        if (!error) {
            currentFileSize = [[attributes objectForKey:NSFileSize] longLongValue];
            
            
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%llu",currentFileSize] forKey:kFileLength];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSData *dataSmallFile = [NSData dataWithContentsOfFile:[imgDetD valueForKey:@"imageUrl"]];

        if (currentFileSize < [kChunkSizeValue intValue])
        {
            NSUInteger i = 0;
            bytes = [dataSmallFile bytes];
            for (i = 0; i < currentFileSize; i++)
            {
                [array addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
            }
            [requestDict setValue:array forKey:kbtDocBody];
        }

        
//        UIImage* imgO =[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgDetD valueForKey:@"imageUrl"]]]];
        
//        [requestDict setObject:imgO forKey:@"images"];
        NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kcreateFileRequest]];
        
//        NSMutableArray* arrImgs = [[NSMutableArray alloc]init];
//        for (UIImage* imgL in imgArr) {
//            [arrImgs addObject:imgL];
//        }
        NSLog(@"Params Dict for Image Upload:%@", ParamDict);
        [APIRequests UploadImagesFromGallery:ParamDict images:imgOAr  withCompletionBlock:^(BOOL success, NSError *error) {
            
        }];
        
    }
    
    
   
    
}



#pragma mark -  ELCImageAsset Selectors

- (void)SelectPhotosECL{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
//    elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
////        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
////        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
////        elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
////        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
//
    
    elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
    
//    elcPicker.imagePickerDelegate = self;
    elcPicker.imagePickerDelegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:elcPicker animated:YES completion:nil];
    });
}


- (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    
    
    [[[UIAlertView alloc]initWithTitle:@"File Uploading..." message:@"Sit Back and Enjoy. We got this!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    NSMutableDictionary* imgDetailsArr = [[NSMutableDictionary alloc]init];
//    NSMutableArray* arryT = [NSMutableArray new];
//    NSMutableArray* arryImages = [NSMutableArray new];
    
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:kImagesArray]];
//    [self resetDefaults];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
//    int x = 98672;
    for (NSDictionary *dict in info) {
        
        
    if(!IS_IOS8) {
       
        
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
                
                NSLog(@"Images:%@", dict);
                // get the ref url
                NSURL *refURL = [dict valueForKey:UIImagePickerControllerReferenceURL];
                
                // define the block to call when we get the asset based on the url (below)
                ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
                {
                    ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
                    NSArray* arrayImgfile = [[imageRep filename] componentsSeparatedByString:@"."];

                    NSLog(@"[imageRep filename] : %@ || dict:%@", [imageRep filename], dict);

                    NSString *fileName = [arrayImgfile objectAtIndex:0];
                    NSString *strExtension = [NSString stringWithFormat:@".%@",[arrayImgfile objectAtIndex:1]];
                    NSString *folderID = self.insideSyncFolderDetails.strFolderId;
                    NSString *fileURL = [refURL absoluteString];
                    [mutArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@", fileName, folderID, strExtension, fileURL]];
                    
                    
                    [[NSUserDefaults standardUserDefaults] setValue:mutArray forKey:kImagesArray];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    if (mutArray > 0) {
                        [[UploadPhotos sharedInstance] performSelectorInBackground:@selector(startUpload) withObject:nil];
                    }
                };
                
                // get the asset library and fetch the asset based on the ref url (pass in block above)
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
                
               
                

            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
                [images addObject:image];
                

            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
        
    }else{
        
        for (PHAsset *asset in info) {
            
            
            
            if (asset.mediaType == PHAssetMediaTypeImage){
                
                NSLog(@"AssetURL:%@ || Name:%@", asset.localIdentifier, [asset valueForKey:@"filename"]);
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                
                // Download from cloud if necessary
                options.networkAccessAllowed = YES;
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //you can update progress here
                    });
                };
                NSArray* arrayImgfile = [[asset valueForKey:@"filename"] componentsSeparatedByString:@"."];
                NSString *fileName = [arrayImgfile objectAtIndex:0];
                NSString *strExtension = [NSString stringWithFormat:@".%@",[arrayImgfile objectAtIndex:1]];
                NSString *folderID = self.insideSyncFolderDetails.strFolderId;
                NSString *fileURL = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG",[asset.localIdentifier substringToIndex:36]];
                [mutArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@", fileName, folderID, strExtension, fileURL]];
                
                
                [[NSUserDefaults standardUserDefaults] setValue:mutArray forKey:kImagesArray];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (mutArray > 0) {
                    [[UploadPhotos sharedInstance] performSelectorInBackground:@selector(startUpload) withObject:nil];
                }
                
                
                
            } else {
                
            }
        }
        
        
    }
    }

//    
//    for (int iCount = 0; iCount < images.count; iCount++)
//    {
//        NSString *fileName = [[[[[[AppDelegate shared].mutArraySelectedImages objectAtIndex:iCount] valueForKey:kFileName] componentsSeparatedByString:@"."] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_" withString:@""];
//        NSString *strExtension = [NSString stringWithFormat:@".%@",[[[[[AppDelegate shared].mutArraySelectedImages objectAtIndex:iCount] valueForKey:kFileName] componentsSeparatedByString:@"."] objectAtIndex:1]];
//        NSString *folderID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentFolderID];
//        NSString *fileURL = [[[AppDelegate shared].mutArraySelectedImages objectAtIndex:iCount] valueForKey:kURL];
//        [mutArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@", fileName, folderID, strExtension, fileURL]];
//    }
    
   
    
    
}



- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Search Delegate Method

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    if ([self.searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length>0) {
//        
        [self.arrSearchResult removeAllObjects];
        [self RunSeachQuery:self.searchDspController.searchBar.text];
    
//    }else{
//        
//    }
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    [self.arrSearchResult removeAllObjects];
//        [self RunSeachQuery:self.searchDspController.searchBar.text];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
    [aSearchBar resignFirstResponder];

}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
        NSLog(@"Cleared12");    
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchDisplayController Delegate Methods
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
//{
//    [self RunSeachQuery:searchText];
//}

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
//shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//    
//    return NO;
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
        NSLog(@"Cleared");
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchDspController.searchBar afterDelay: 0.1];
    return YES;
}

- (void)RunSeachQuery:(NSString *)strSearchString{
    SyncFolder*ddet = self.insideSyncFolderDetails;
    NSMutableDictionary * requestDict;
    requestDict = [[NSMutableDictionary alloc] init];
    
    NSString *strFolderID;
    NSString *strOwnerID;
    

    
    if (!ddet.strFolderId.length>0) {
      strFolderID = [TempStorage GetCustomKeyWithValue:kRootFolderId];
        strOwnerID = [TempStorage GetCustomKeyWithValue:kUserId];
    }else{
        strFolderID = ddet.strFolderId;
        strOwnerID = ddet.strFolderOwnerId;
    }
    //775e60c7-0448-43ad-8c37-d2ea0f979646
    [requestDict setValue:strFolderID forKey:kFolderId];
    [requestDict setValue:kfalse forKey:kIsAscending];
    [requestDict setValue:kdtCreated forKey:kOrderBy];
    [requestDict setValue:[NSString stringWithFormat:@"%d",1] forKey:kPageNumber];
    [requestDict setValue:[NSString stringWithFormat:@"%d",kListPageSize] forKey:kPageSize];
    [requestDict setValue:strOwnerID forKey:kUserId];
    [requestDict setValue:strSearchString forKey:kSearchString];
    
    
    NSMutableDictionary *ParamDict =  [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithObject:requestDict forKey:kSearchFileFolderRequest]];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ParamDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
     NSString *jsonString = @"";
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
       jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",jsonString);
    }
    
    [self.arrSearchResult removeAllObjects];
    //kSearchFileFolderServiceName -> ParamDict
    [[LSyncAPIClient sharedClient]POST:[NSString localizedStringWithFormat:@"%@/Services/SyncMobileService.svc/web/%@",[[[TempStorage GetCustomKeyWithValue:kSyncEndPntSecs] mutableCopy] objectAtIndex:0],kSearchFileFolderServiceName] parameters:ParamDict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSLog(@"Search Response:%@", responseObject);
        if ([[responseObject objectForKey:kSuccess] boolValue]) {
            NSMutableDictionary* dictResultFolder = [[NSMutableDictionary alloc]initWithDictionary:[responseObject objectForKey:kResult]];
            NSMutableArray* arrFolderList = [[NSMutableArray alloc]initWithArray:[dictResultFolder objectForKey:kFileFolderList]];
            
            for (NSDictionary* fDict in arrFolderList) {
                //                NSLog(@"IsFolderOwnerClass:%@", [[fDict objectForKey:kFolderbIsOwner] class]);
                SyncFolder* syncFile = [[SyncFolder alloc]init];
                [syncFile setStrDocumentCreatedDate:[fDict objectForKey:kDocumentCreatedDate]];
                [syncFile setStrDocumentExtension:[fDict objectForKey:kDocumentExtension]];
                [syncFile setStrDocumentId:[fDict objectForKey:kDocumentId]];
                [syncFile setStrDocumentIsDeleted:[fDict objectForKey:kDocumentIsDeleted]];
                [syncFile setStrDocumentName:[fDict objectForKey:kDocumentName]];
                [syncFile setStrDocumentSize:[[fDict objectForKey:@"DocumentSize"] intValue]];
                [syncFile setStrDocumentUrl:[fDict objectForKey:@"DocumentUrl"]];
                [syncFile setStrDocumentVersion:[fDict objectForKey:kDocumentVersion]];
                [syncFile setStrFolderCanShareFurther:[fDict objectForKey:kFolderCanShareFurther]];
                [syncFile setStrFolderCanSync:[fDict objectForKey:kFolderCanSync]];
                [syncFile setStrFolderId:[fDict objectForKey:kFolderId]];
                [syncFile setStrFolderName:[fDict objectForKey:kFolderName]];
                [syncFile setStrFolderOwnerCreatedDate:[fDict objectForKey:kFolderOwnerCreatedDate]];
                [syncFile setStrFolderOwnerFirstName:[fDict objectForKey:kFolderOwnerFirstName]];
                [syncFile setStrFolderOwnerId:[fDict objectForKey:kFolderOwnerId]];
                [syncFile setStrFolderOwnerLastName:[fDict objectForKey:kFolderOwnerLastName]];
                [syncFile setStrFolderOwnerOrgId:[fDict objectForKey:kFolderOwnerOrgId]];
                [syncFile setStrFolderPermission:[fDict objectForKey:kFolderPermission]];
                [syncFile setStrFolderbIsOwner:[fDict objectForKey:kFolderbIsOwner]];
                [syncFile setStrIsFolder:[fDict objectForKey:kIsFolder]];
                [self.arrSearchResult addObject:syncFile];
            }
            
           
//            [self.tableView reloadData];
//            [self.arrSearchResult removeAllObjects];
            
            
        }else{
            
        }
                 [self.searchDspController.searchResultsTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    

}


#pragma mark -
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    //    NSInteger numToPreview = 0;
    //
    //    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    //    if (selectedIndexPath.section == 0)
    //        numToPreview = NUM_DOCS;
    //    else
    //        numToPreview = self.documentURLs.count;
    //
    //    return numToPreview;
//    return self.arrDocs.count;
    
    if (self.tableView) {//self.searchDspController.searchResultsTableView
        return self.arrSyncDetails.count;
    }
    else{
        
        return self.arrSearchResult.count;
    }
}

// returns the item that the preview controller should preview
//- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
//{
//    NSURL *fileURL = nil;
//    
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSString  *imagePath = [documentsDirectory stringByAppendingPathComponent:
//                            [NSString stringWithFormat: @"InboxT/%@", [[NSURL fileURLWithPath:self.    self.strDocsSelected] lastPathComponent]]];
//    
//    
//    
//    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
//    if (selectedIndexPath.section == 0)
//    {
//        //        fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[idx] ofType:nil]];
//    }
//    else
//    {
//        //        fileURL = [self.documentURLs objectAtIndex:idx];
//    }
//    
//    return fileURL = [NSURL fileURLWithPath:imagePath];
//}



#pragma mark - Save File Data

- (void)SaveDataFiletoFavorites:(SyncFolder*)fileData{
    NSMutableArray* arrFavs = [[NSMutableArray alloc]initWithArray:[TempStorage GetCustomKeyWithValue:tFavsArrList] copyItems:YES];
    if (![self CheckDataIfInFavsList:fileData.strDocumentName]) {

    NSMutableDictionary* dctData = [[NSMutableDictionary alloc]
                                    initWithObjects:@[fileData.strDocumentCreatedDate,
                                                      fileData.strDocumentExtension,
                                                      fileData.strDocumentId,
                                                      fileData.strDocumentName,
                                                      fileData.strDocumentUrl,
                                                      fileData.strFolderId,
                                                      fileData.strFolderOwnerId,
                                                      [NSString stringWithFormat:@"%i", (int)fileData.strDocumentSize]]
                                    forKeys:@[@"DocumentCreatedDate",
                                              @"DocumentExtension",
                                              @"DocumentId",
                                              @"DocumentName",
                                              @"DocumentUrl",
                                              @"FolderId",
                                              @"FolderOwnerOrgId",
                                              @"DocumentSize"]];
    [arrFavs addObject:dctData];
    [TempStorage SaveCustomKey:tFavsArrList withValue:arrFavs];
    
    }else{
        NSMutableArray* arrRemoved = [NSMutableArray new];
        for (NSDictionary* syncData in arrFavs) {
            if ([[syncData valueForKey:@"DocumentName"] isEqualToString:fileData.strDocumentName]) {
//                [arrFavs removeObject:syncData];
                [arrRemoved addObject:syncData];
            }
        }
        [arrFavs removeObjectsInArray:arrRemoved];
        [TempStorage SaveCustomKey:tFavsArrList withValue:arrFavs];
    }
    
}

- (SyncFolder*)GetFavoriteData:(NSString *)strDocumentID{
    
    SyncFolder* sRtG = [[SyncFolder alloc]init];
    
    return sRtG;
}

- (BOOL)CheckDataIfInFavsList:(NSString *)strDocumentName{
    NSMutableArray* arrFavs = [TempStorage GetCustomKeyWithValue:tFavsArrList];
//    NSArray *filtered = [arrFavs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(DisplayName == %@)", @"PurchaseAmount"]];
//    NSDictionary *item = [filtered objectAtIndex:0];
    
    int CountRel = 0; // Counting Hits
    
    for (NSDictionary* syncData in arrFavs) {
        if ([[syncData valueForKey:@"DocumentName"] isEqualToString:strDocumentName]) {
            CountRel =CountRel+1;
        }
    }
    
    if (CountRel>=1) {
        return YES;
    }else{
        return NO;
    }
    
}

// Save Data to Temp Clipboard

- (void)SaveDataFiletoClipboard:(SyncFolder*)fileData{
    
    
    
        NSMutableDictionary* dctData = [[NSMutableDictionary alloc]
                                        initWithObjects:@[fileData.strDocumentCreatedDate,
                                                          fileData.strDocumentExtension,
                                                          fileData.strDocumentId,
                                                          fileData.strDocumentName,
                                                          fileData.strDocumentUrl,
                                                          fileData.strFolderId,
                                                          fileData.strFolderName,
                                                          fileData.strFolderPermission,
                                                          fileData.strFolderOwnerId,
                                                          fileData.strFolderbIsOwner,
                                                          fileData.strFolderCanSync,
                                                          fileData.strIsFolder,
                                                          [NSString stringWithFormat:@"%i", (int)fileData.strDocumentSize]]
                                        forKeys:@[@"DocumentCreatedDate",
                                                  @"DocumentExtension",
                                                  @"DocumentId",
                                                  @"DocumentName",
                                                  @"DocumentUrl",
                                                  @"FolderId",
                                                  @"FolderName",
                                                  @"FolderPermission",
                                                  @"FolderbIsOwner",
                                                  @"FolderOwnerOrgId",
                                                  @"FolderCanSync",
                                                  @"IsFolder",
                                                  @"DocumentSize"]];
    
        [TempStorage SaveCustomKey:sClipboardTempFile withValue:dctData];
    
    [self AddClipboardIcon];
    
}

- (BOOL)checkifClipboardhasItem{ // Check if Clipboard has contained any data
    id getTempClipboardClass = [TempStorage GetCustomKeyWithValue:sClipboardTempFile];
    if ([getTempClipboardClass isKindOfClass:[NSDictionary class]]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - LSFT Selectors / Methods

- (void)launchLSFT{
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    
//    ZLMailComposerViewController *lsftVw = [storyboard instantiateViewControllerWithIdentifier:@"ZLMailComposerViewController"];
////    [lsftVw.view setTag:876123];
//    lsftVw.isUsedFromSYNCAttch = YES;
//    
//    [lsftVw setupNewComposer];
////    NavHomeViewController* naviH = [[NavHomeViewController alloc]initWithRootViewController:lsftVw];
////
//    UINavigationController* naviH = [[UINavigationController alloc]initWithRootViewController:lsftVw];
//    [naviH.navigationBar setBackgroundColor:[UIColor orangeColor]];
//    [naviH.navigationBar setTintColor:[UIColor orangeColor]];
//    
//    [self presentViewController:naviH animated:YES completion:nil];
//    [self.navigationController pushViewController:lsftVw animated:YES];
    
//    AppDelegate* appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    [appDel RootforHomeScreen];
//    [appDel CenterViewWithLSFT];
    
//    appDel.window setRootViewController:<#(UIViewController * _Nullable)#>
    
    
}



@end
