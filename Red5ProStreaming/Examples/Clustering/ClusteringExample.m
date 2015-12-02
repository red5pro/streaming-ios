//
//  SubscribeExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 6/17/15.
//  Copyright (c) 2015 Infrared5. All rights reserved.
//

#import "ClusteringExample.h"

@interface ClusteringExample ()

@end

@implementation ClusteringExample

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //  Add an informational label
    CGRect frame = self.view.frame;
    CGRect labelFrame = CGRectMake(10.0, frame.size.height - 30.0, frame.size.width - 20.0, 20.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"Fetching..."];
    [self.view addSubview:label];
    
    //  Get our connection settings
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    //  Get the URL from which we will retrieve our connection IP
    NSString *domain = [dict objectForKey:@"domain"];
    NSString *urlAsString = [NSString stringWithFormat:@"http://%@:5080/cluster", domain];
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    //  Connect to the URL above, retrieve the connection IP
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   //   Handle any errors
                                   [label setText:@"There was an error!"];
                                   [label setNeedsLayout];
                                   [label setNeedsDisplay];
                                   NSLog(@"%@", error);
                                   return;
                               }
                               
                               //   Convert our response to a usable NSString
                               NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               
                               //   The string above is formatted like 99.98.97.96:1234, but we won't need the port portion
                               NSString *ip = [dataAsString substringToIndex:[dataAsString rangeOfString:@":"].location];
                               NSLog(@"Retrieved %@ from %@, of which the usable IP is %@", dataAsString, urlAsString, ip);
                               
                               //   UI updates must be asynchronous
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //   Showcase the IP we received, for testing purposes
                                   [label setText:ip];
                               });
                               
                               //   Setup a configuration object for our connection
                               R5Configuration *config = [[R5Configuration alloc] init];
                               config.host = ip;
                               config.contextName = [dict objectForKey:@"context"];
                               config.port = [(NSNumber *)[dict objectForKey:@"port"] intValue];
                               config.protocol = 1;
                               
                               //   How long to stream the buffer before beginning playback
                               config.buffer_time = 1;
                               
                               //   Create a new connection using the configuration above
                               R5Connection *connection = [[R5Connection alloc] initWithConfig: config];
                               
                               //   Another UI update, so it's got to be asynchronous
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //   Create our new stream that will utilize that connection
                                   self.subscribe  = [[R5Stream alloc] initWithConnection:connection];
                                   
                                   //   Setup our listener to handle events from this stream
                                   self.subscribe.delegate = self;
                                   
                                   //   Setup our R5VideoViewController to display the stream content
                                   [self setupDefaultR5ViewController];
                                   
                                   //   Attach the R5VideoViewController to our publishing stream
                                   [self.r5View attachStream:self.subscribe];
                                   
                                   //   Start subscribing!!
                                   [self.subscribe play:[self getStreamName:SUBSCRIBE]];
                               });
                           }];
}

/**
 *  Handle self.subscribe.delegate callbacks
 *
 *  @param stream     stream making callback
 *  @param statusCode code of message
 *  @param msg        addtional context
 */
-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg {
    //pass to super to present toast
    [super onR5StreamStatus:stream withStatus:statusCode withMessage:msg];
}

@end
