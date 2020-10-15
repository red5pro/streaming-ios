//
//  Custom360VideoViewRenderer.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 12/06/2019.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
//
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code")
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying
//  code  constitutes your acceptance of the following license terms and conditions.
//
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation
//  files (collectively, the "Software") without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
//
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import R5Streaming

@objc(Custom360VideoViewRenderer)
class Custom360VideoViewRenderer : R5VideoViewRenderer {

    var stream : R5Stream?
    var engine : Custom360VideoViewRendererEngine?
    var camera : Custom360VideoViewCamera?
    
    var isRenderering = false
    
    override init!(glView: GLKView!) {
        
        super.init(glView: glView)
        self.engine = Custom360VideoViewRendererEngine(context: glView.context)
        
    }
    
    deinit {
        if let engine = self.engine {
            engine.de_init()
        }
    }
    
    func addGestures (view: UIView, camera: Custom360VideoViewCamera) {
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: camera, action: #selector(Custom360VideoViewCamera.handleTap(recognizer:)))
        let pan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: camera, action: #selector(Custom360VideoViewCamera.handlePanGesture(fromSender:)))
        let pinch : UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: camera, action: #selector(Custom360VideoViewCamera.handlePinchGesture(recognizer:)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(pinch)
        
    }
    
    override func attach(_ stream: R5Stream!) {
        super.attach(stream)
        self.stream = stream
    }
    
    override func start() {
        super.start()
        if let view : GLKView = self.getGLView() {
            self.camera = Custom360VideoViewCamera(view: view)
            addGestures(view: view, camera: self.camera!)
        }
    }
    
    override func onDrawFrame(_ rotation: Int32, andScale scaleMode: r5_scale_mode) {
        
        super.onDrawFrame(rotation, andScale: scaleMode)
        
        if let glkView = self.getGLView() {
            
            if (self.stream != nil && !isRenderering) {
                
                var projectionMatrix : GLKMatrix4?
                var modelViewMatrix : GLKMatrix4?
                
                if let camera = camera {
                    projectionMatrix = camera.projection;
                    modelViewMatrix = camera.modelView;
                } else {
                    let aspect = Float(glkView.bounds.size.width / glkView.bounds.size.height)
                    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0)
                    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 0)
                    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix!, GLKMathDegreesToRadians(0), 0, 0, 1)
                }
                
                isRenderering = true
                if let pb = self.stream?.getPixelBuffer() {
                    
                    let buffer = pb.takeUnretainedValue()
                    self.engine?.updateTexture(pixelBuffer: buffer)
                    self.engine?.render(projectionMatrix: projectionMatrix!, modelViewMatrix: modelViewMatrix!)
                    
                }
                isRenderering = false;
                
            }
        }
    }
    
}
