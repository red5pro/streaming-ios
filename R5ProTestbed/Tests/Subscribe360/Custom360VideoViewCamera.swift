//
//  Custom360VideoViewCamera.swift
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

@objc(Custom360VideoViewCamera)
class Custom360VideoViewCamera : NSObject {
    
    let fov : Float = 65.0
    var scale : Float = 1.0
    var currentScale : Float = 1.0
    var currentTranslation: CGPoint = CGPoint.init(x: 0, y: 0)
    
    var yaw : Float = 0.0
    var pitch : Float = 0.0
    var aspect : Float = 0.0
    var fovRadians : Float = 0.0
    var nearZ : Float = 0.0
    var farZ : Float = 0.0
    
    var projection : GLKMatrix4?
    var modelView : GLKMatrix4?
    
    init (view: GLKView) {
        
        super.init()
        
        let aspect = Float(view.bounds.size.width / view.bounds.size.height)
        self.updateProjection(fov: GLKMathDegreesToRadians(fov), aspect: aspect, nearz: 0.1, farz: 100.0)
        
        self.modelView = GLKMatrix4Identity
        self.modelView = GLKMatrix4MakeTranslation(0, 0, 0)
        self.modelView = GLKMatrix4Rotate(self.modelView!, GLKMathDegreesToRadians(0), 0, 0, 1)
        
        self.updateModelView(pitch: 0, yaw: 0)
        
    }
    
    func updateProjection (fov: Float, aspect: Float, nearz: Float, farz: Float) {
        
        self.aspect = aspect
        self.fovRadians = fov
        self.nearZ = nearz
        self.farZ = farz
        
        self.projection = GLKMatrix4MakePerspective(self.fovRadians, self.aspect, self.nearZ, self.farZ)
        
    }
    
    func updateModelView (pitch: Float, yaw: Float) {
        
        self.pitch = pitch
        self.yaw = yaw
        
        let cosPitch = cosf(self.pitch)
        let sinPitch = sinf(self.pitch)
        let cosYaw = cosf(self.yaw)
        let sinYaw = sinf(self.yaw)
        
        let xAxis = GLKVector3Make(cosYaw, 0, -sinYaw)
        let yAxis = GLKVector3Make(sinYaw * sinPitch, cosPitch, cosYaw * sinPitch)
        let zAxis = GLKVector3Make(sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw)
        
        self.modelView = GLKMatrix4Make(
                                        xAxis.x, yAxis.x, zAxis.x, 0,
                                        xAxis.y, yAxis.y, zAxis.y, 0,
                                        xAxis.z, yAxis.z, zAxis.z, 0,
                                        0, 0, 0, 1)
        
    }
    
    @objc func handleTap (recognizer: UITapGestureRecognizer) {
        
        scale = 1.0
        currentScale = 1.0
        self.updateModelView(pitch: 0.0, yaw: 0.0)
        self.updateProjection(fov: GLKMathDegreesToRadians(fov), aspect: self.aspect, nearz: self.nearZ, farz: self.farZ)
    }
    
    @objc func handlePanGesture (fromSender: UIPanGestureRecognizer) {
        
        if (fromSender.state == UIGestureRecognizer.State.began) {
            currentTranslation = CGPoint.init(x: 0, y: 0)
        }
        
        let translation = fromSender.translation(in: fromSender.view)
        let inputX = Float(translation.x - currentTranslation.x)
        let inputY = Float(translation.y - currentTranslation.y)
        let dh = self.yaw + inputX * 0.005
        let dv = self.pitch + inputY * 0.005
        
        self.updateModelView(pitch: Float(dv), yaw: Float(dh))
        currentTranslation = translation
        
    }
    
    @objc func handlePinchGesture (recognizer: UIPinchGestureRecognizer) {
        
        if (recognizer.state == UIGestureRecognizer.State.began) {
            currentScale = 1.0
        }
        
        let pinchScale = Float(recognizer.scale)
        let inputZ = pinchScale - currentScale
        var valueZ = scale - inputZ
        
        if(valueZ < 0.5) {
            valueZ = 0.5
        }
        if(valueZ > 2.5) {
            valueZ = 2.5
        }
        
        scale = valueZ
        currentScale = pinchScale
        
        self.updateProjection(fov: GLKMathDegreesToRadians(Float(fov * scale)), aspect: self.aspect, nearz: self.nearZ, farz: self.farZ)
        
    }
}
