//
//  R5VideoViewRenderer.h
//  R5Streaming
//
//  Created by Todd Anderson on 17/04/2019.
//  Copyright © 2019 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "R5Stream.h"

@protocol R5VideoViewRendererDelegate;

/**
 *  @brief The base default Renderer for R5VideoView of Red5Pro. By default, it utilizes OpenGL to render the target stream view instance (GLKView).
 */
@interface R5VideoViewRenderer : NSObject

@property id<R5VideoViewRendererDelegate> rendererDelegate;

/**
 * Accessor for the managed GLKView instance.
 *
 * @return GLKView
 */
- (GLKView *)getGLView;

/**
 * Initializer with target GLKView instance.
 *
 * @param GLKView
 */
- (id)initWithGLView:(GLKView *)glView;

/**
 * Attaches and monitors the target stream to render.
 *
 * @param R5Stream
 */
- (void)attachStream:(R5Stream *)stream;

/**
 * Request to begin rendering when stream is available.
 */
- (void)start;

/**
 * Request to stop rendering cycle.
 */
- (void)stop;

/**
 * Request to handle any display updates to the underlying GLKView instance.
 * Override this method in your custom renderer(s) to handle specific routines.
 */
- (void)onDrawFrame:(int)rotation andScaleMode:(r5_scale_mode)scaleMode;

@end

@protocol R5VideoViewRendererDelegate <NSObject, GLKViewDelegate>

@end
