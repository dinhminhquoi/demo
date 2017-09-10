//
//  SyncViewCellTableViewController.h
//  LiteraSync
//
//  Created by Tony Shark on 22/10/2015.
//  Copyright © 2015 Litera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncFolder.h"



@interface SyncViewCellTableViewController : UITableViewController

- (id) initWithSyncFolderDetails: (SyncFolder *)syncDets andViewDisplay: (UITableViewStyle)style;
//@property (nonatomic, strong) void (^onDismiss)(NSString *valuePassedOn);

@property (assign, readwrite) BOOL isComingFromLSFT;



@end
