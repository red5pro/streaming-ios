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
@end

@implementation TwoWayVideoChatExample



-(void)viewDidAppear:(BOOL)animated{
    
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGRect rect = self.tableView.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    rect.origin.y = topBarOffset;
    rect.size.height = rect.size.height + (topBarOffset * -1);
    
    self.tableView.bounds = rect;
    
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

    R5VideoViewController *rvc = [self getNewViewController:self.view.frame];
    [rvc attachStream: self.subscribe];
    
    [self.view addSubview:rvc.view];
    
    //bring publish to the front
    [self.view bringSubviewToFront:self.r5View.view];
    
    [self.subscribe play:streamname];
    
}


-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg{
    
    if(stream == self.publish){
        
        if(statusCode == r5_status_start_streaming){
           
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getStreams:) userInfo:nil repeats:NO];

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
        
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getStreams:) userInfo:nil repeats:NO];
    }
    
    

}


@end
