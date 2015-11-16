//
//  StreamImageExample.m
//  Red5ProStreaming
//
//  Created by Andy Zupko on 11/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

#import "StreamImageExample.h"

@interface StreamImageExample ()

@end

@implementation StreamImageExample

-(void)viewDidAppear:(BOOL)animated{
   
    
    //setup the publish routine
    self.subscribe = [self getNewStream:SUBSCRIBE];

    
    //setup our R5VideoViewController to display the stream content
    [self setupDefaultR5ViewController];
    
    //attach the R5VideoViewController to our publishing stream
    [self.r5View attachStream:self.subscribe];
    
    //start subscribing!!
    [self.subscribe play:[self getStreamName:SUBSCRIBE] ];
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(self.subscribe != nil){
        
        //Get a UI Image with the current frame
        UIImage *img = [self.subscribe getStreamImage];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        [self.view addSubview:imgView];
        
        
        
        //Release the image from the view after 4 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [imgView removeFromSuperview];
            
           
        });
        
       
    }
}


@end
