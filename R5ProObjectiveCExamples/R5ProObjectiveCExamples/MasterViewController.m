//
//  MasterViewController.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/5/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Testbed.h"
#import <AVFoundation/AVFoundation.h>

@interface MasterViewController ()

@property NSMutableArray *objects;
@property BOOL isBlockOnAccessGrant;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isBlockOnAccessGrant = NO;
    
    [Testbed sharedInstance];
    [Testbed dictionary];
    NSLog(@"%@", [Testbed testAtIndex:0].description);
    
    // Do any additional setup after loading the view, typically from a nib.
     
    self.splitViewController.preferredPrimaryColumnWidthFraction = 0.2;
    self.view.autoresizesSubviews = true;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.navigationController.delegate = self;
    
    UISplitViewController *split = self.splitViewController;
    if( split != nil ) {
        NSArray *controllers = split.viewControllers;
        self.detailViewController = (DetailViewController *)((UINavigationController *)[controllers objectAtIndex:controllers.count-1]).topViewController;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(appMovedToBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    if( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined ){
        self.isBlockOnAccessGrant = YES;
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
            self.isBlockOnAccessGrant = NO;
        }];
    }
    
}

-(void) appMovedToBackground {
    
    if( _isBlockOnAccessGrant ){
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isBlockOnAccessGrant = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *object = [Testbed testAtIndex:(int)indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[Testbed sections];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Testbed rowsInSection];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString* description = [Testbed testAtIndex:(int)indexPath.row][@"name"];
    cell.textLabel.text = description;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
