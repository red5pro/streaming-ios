//
//  R5MetalVideoViewController.h
//  R5Streaming
//
//  Created by David Heimann on 1/10/19.
//  Copyright © 2019 Infrared5. All rights reserved.
//

#import "R5Stream.h"
#import <UIKit/UIKit.h>

/**
 *  @brief The VideoView for all R5Streaming. This version isn't reliant on OpenGL for rendering.  When publishing, it will contain the camera view.  While subscribing it will render all incoming stream data.  Streams will be cropped to fit the aspect ratio of the view.
 */
@interface R5MetalVideoViewController : UIViewController


/**
 *  Desired FPS to render the video at.  FPS lower than the streaming FPS will result in dropped frames.
 */
@property int preferredFPS;

/**
 *  Set a stream to render using this View
 *
 *  @param videoStream Stream to render
 */
-(void) attachStream:(R5Stream *)videoStream;

/**
 *  Reset the GLES context and setup rendering loop
 */
-(void) resetContext;

/**
 *  Show the publish camera preview.  You can use this to show the preview before the Stream is publishing.
 *
 *  @param visible Set the visibility
 */
-(void) showPreview:(BOOL)visible;

/**
 *  Overlay the view with a log of textual debugging information.
 *
 *  @param debug Set the visibility of the debug panel
 */
-(void) showDebugInfo:(BOOL)debug;

/**
 *  Set the view render frame
 *
 *  @param frame Set the frame
 */
-(void)setFrame:(CGRect) frame;

-(void)pauseRender;
-(void)resumeRender;

/**
 * Scaling mode of the rendering view for subscribing streams
 */
@property (nonatomic)  r5_scale_mode scaleMode;

@end
