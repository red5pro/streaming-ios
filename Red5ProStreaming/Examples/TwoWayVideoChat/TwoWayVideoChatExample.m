//
//  TwoWayVideoChatExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/18/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "TwoWayVideoChatExample.h"

@interface TwoWayVideoChatExample ()<UITableViewDataSource, UITableViewDelegate>
@property NSArray *streams;
@property UITableView *tableView;
@property NSTimer *timer;
@property R5VideoViewController *subscribeR5View;
@property UIView *profileView;
@end

@implementation TwoWayVideoChatExample




-(void)viewDidAppear:(BOOL)animated{
    
    
    //add a table view to display list of streams
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGRect rect = self.tableView.frame;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    
    rect.origin.y = topBarOffset ;
    rect.size.height = rect.size.height - (topBarOffset);
    
    self.tableView.frame = rect;
    
    [self.view addSubview:self.tableView];
    
    //setup the publish routine
    self.publish = [self getNewStream:PUBLISH];
    [self setupDefaultR5ViewController];
    
    self.r5View.view.frame = CGRectMake(self.view.frame.size.width-90, self.view.frame.size.height-150, 80, 140);
    
    [self.r5View attachStream:self.publish];
    //set this class to handle RPC response
    self.publish.client = self;
    
    [self.publish publish:[self getStreamName:PUBLISH] type:R5RecordTypeLive];


}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.streams != nil){
        
        return self.streams.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"streamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streamCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.streams objectAtIndex:indexPath.item];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *streamname = [self.streams objectAtIndex:indexPath.item];
    
    self.subscribe = [self getNewStream:SUBSCRIBE];
    self.subscribe.client = self;

    R5VideoViewController *rvc = [self getNewViewController:self.view.frame];
    [rvc attachStream: self.subscribe];
    
    [self.view addSubview:rvc.view];
    
    //bring publish to the front
    [self.view bringSubviewToFront:self.r5View.view];
    
    [self.subscribe play:streamname];
    
    self.subscribeR5View = rvc;
    
    [self addProfileOverlay];
    
    
}

-(void)addProfileOverlay{
    
    self.profileView = [[UIView alloc] initWithFrame:self.view.frame];
    self.profileView.backgroundColor = [UIColor blackColor];
    
    UIImage *vid_icon = [UIImage imageNamed:@"video_icon"];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:vid_icon];
    
    CGRect frame = self.profileView.frame;
    frame.size.height *= 0.5;
    frame.size.width *= 0.5;
    frame.origin.x = (self.profileView.frame.size.width-frame.size.width)*0.5;
    frame.origin.y = (self.profileView.frame.size.height-frame.size.height)*0.5;
    
    imgView.frame = frame;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.profileView addSubview:imgView];
    self.profileView.hidden = YES;
    
    [self.subscribeR5View.view addSubview:self.profileView];
    
}


-(void)onR5PublishStateNotification:(NSString*)value{
   
    NSArray *pairs = [value componentsSeparatedByString:@";"];
   
    for(int i=0;i<pairs.count;i++){
       
        NSArray *keyvalue = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
        
        if(keyvalue.count > 1){

            NSString *key = [keyvalue objectAtIndex:0];
            NSString *val = [keyvalue objectAtIndex:1];
            
            //show or hide profile overlay if "streamingMode" contains "Video"
            if([key isEqualToString:@"streamingMode"]){
               
                if([val rangeOfString:@"Video"].location == NSNotFound){
                    
                    self.profileView.hidden = NO;
                    [self.subscribeR5View.view bringSubviewToFront:self.profileView];
                    
                }else{
                    
                    self.profileView.hidden = YES;
                }
            }
            
        }
    }

    
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    if(stream == self.publish){
        
        if(statusCode == r5_status_start_streaming){
           
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getStreams:) userInfo:nil repeats:NO];

        }
    }
}

-(void)getStreams:(NSTimer*)timer{
    
    //call out to get our new stream
    [self.publish.connection call:@"streams.getLiveStreams" withReturn:@"onGetLiveStreams"  withParam:nil];
    
}

-(void)onGetLiveStreams:(NSString *)streams{
    
    NSError *e = nil;
   self.streams = [NSJSONSerialization JSONObjectWithData: [streams dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];
    
    //set this as our table data source
    
    [self.tableView reloadData];
    
    
    if(self.subscribe == nil){
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getStreams:) userInfo:nil repeats:NO];
    }
    

}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}


@end
