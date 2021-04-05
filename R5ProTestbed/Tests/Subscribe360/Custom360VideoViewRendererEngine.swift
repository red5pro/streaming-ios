//
//  Custom360VideoViewRendererEngine.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 17/06/2019.
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
import Foundation
import OpenGLES.ES3
import R5Streaming

@objc(Custom360VideoViewRendererEngine)
class Custom360VideoViewRendererEngine : NSObject {
    
    let v_shader =
        "#version 100\n" +
        "#ifdef GL_ES\n" +
        "precision mediump float;\n" +
        "#endif\n" +
        "uniform mat4 ProjectionMatrix;\n" +
        "attribute vec4 position;\n" +
        "attribute vec2 texcoord;\n" +
        "varying vec2 Texcoord;\n" +
        "void main(void) {\n" +
        "   vec2 tmp = texcoord;\n" +
        "   Texcoord = tmp;\n" +
        "   gl_Position = ProjectionMatrix * position;\n" +
        "}\n"
    
    let f_shader_biplanar =
        "#version 100\n" +
        "#ifdef GL_ES\n" +
        "precision mediump float;\n" +
        "#endif\n" +
        "varying vec2 Texcoord;\n" +
        "uniform sampler2D SamplerY;\n" +
        "uniform sampler2D SamplerUV;\n" +
        "void main(void) {\n" +
        "   vec3 yuv;\n" +
        "   vec3 rgb;\n" +
        "   yuv.x = texture2D(SamplerY, Texcoord).r - (16.0 / 255.0);\n" +
        "   yuv.yz = texture2D(SamplerUV, Texcoord).ra - vec2(128.0 / 255.0, 128.0 / 255.0);\n" +
        "   rgb = mat3( 1.164, 1.164, 1.164,\n" +
        "               0.0, -0.213, 2.112,\n" +
        "               1.793, -0.533, 0.0) * yuv;\n" +
        "   gl_FragColor = vec4(rgb, 1.0);\n" +
        "}\n"
    
    struct TextureVertex {
        var position: (GLfloat, GLfloat, GLfloat)
        var texture: (GLfloat, GLfloat)
    }

    private var indices = [GLushort]()
    private var vertices = [TextureVertex]()
    
    private var vertexArray = GLuint()
    private var vertexVBO = GLuint()
    private var indexVBO = GLuint()
    
    private var position = GLuint()
    private var texture = GLuint()
    private var modelViewProjectionMatrix = GLint()
    
    private var program = GLuint()
    private var vertShader = GLuint()
    private var fragShader = GLuint()
    
    private var samplerY = GLuint()
    private var samplerUV = GLuint()
    
    var yTexture: CVOpenGLESTexture?
    var uvTexture: CVOpenGLESTexture?
    var textureCache: CVOpenGLESTextureCache?
    
    var context: EAGLContext!
    
    init (context: EAGLContext) {
        
        super.init()
        
        self.context = context
        
        // [SHADERS]]
        self.program = glCreateProgram()
        
        let vertSource: UnsafePointer<Int8> = NSString.init(string: v_shader).utf8String!
        var vertCast: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(vertSource)
        vertShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vertShader, 1, &vertCast, nil)
        glCompileShader(vertShader)
        
        let fragSource: UnsafePointer<Int8> = NSString.init(string: f_shader_biplanar).utf8String!
        var fragCast: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(fragSource)
        fragShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fragShader, 1, &fragCast, nil)
        glCompileShader(fragShader)
        
        glAttachShader(program, vertShader)
        glAttachShader(program, fragShader)
        
        glLinkProgram(program)
        
        // cleanup
        glDetachShader(program, vertShader)
        glDetachShader(program, fragShader)
        glDeleteShader(vertShader)
        glDeleteShader(fragShader)
        
        glUseProgram(program)
        // [[SHADERS]
        
        let rows = 200
        let columns = rows / 2
        self.generate_vertices(radius: 1, rows: rows, columns: columns)
        self.generate_indices(rows: rows-1, columns: columns-1)
        
        // [VBO]]
        glGenBuffers(1, &vertexVBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexVBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<TextureVertex>.size * self.vertices.count),
                     self.vertices,
                     GLenum(GL_DYNAMIC_DRAW))
        
        // [EBO]]
        glGenBuffers(1, &indexVBO)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexVBO)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLushort>.size * self.indices.count),
                     self.indices,
                     GLenum(GL_STATIC_DRAW))
        
        // [VAO]]
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexVBO)
        position = GLuint(glGetAttribLocation(program, "position"))
        glEnableVertexAttribArray(position)
        glVertexAttribPointer(position,
                              GLint(3),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<TextureVertex>.size), nil)
        
        texture = GLuint(glGetAttribLocation(program, "texcoord"))
        glEnableVertexAttribArray(texture)
        glVertexAttribPointer(texture,
                              GLint(2),
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<TextureVertex>.size),
                              UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexVBO)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        modelViewProjectionMatrix = GLint(glGetUniformLocation(program, "ProjectionMatrix"))
        samplerY = GLuint(glGetUniformLocation(program, "SamplerY"))
        samplerUV = GLuint(glGetUniformLocation(program, "SamplerUV"))
        
        glUniform1i(GLint(samplerY), 0)
        glUniform1i(GLint(samplerUV), 1)
        
    }
    
    func de_init() {
        self.vertices.removeAll()
        self.indices.removeAll()
        
        glDeleteBuffers(1, &self.vertexVBO)
        glDeleteBuffers(1, &self.indexVBO)
        glDeleteVertexArraysOES(1, &self.vertexArray)
    }
    
    func generate_indices (rows: Int, columns: Int) {
        
        let cols = columns + 1
        
        for i in 0...rows {
            for j in 0...columns {
                
                let nextRow = i + 1
                let nextCol = j + 1
                
                indices.append(GLushort(i * cols + j));
                indices.append(GLushort(nextRow * cols + j));
                indices.append(GLushort(nextRow * cols + nextCol));
                
                indices.append(GLushort(i * cols + j));
                indices.append(GLushort(nextRow * cols + nextCol));
                indices.append(GLushort(i * cols + nextCol));
                
            }
            
        }
        
    }
    
    func generate_vertices(radius: Int, rows: Int, columns: Int) {
        
        let delta_alpha = (2 * .pi) / Float(columns)
        let delta_beta = .pi / Float(rows)
        
        for i in 0...rows {
            let beta = (Float(i) * delta_beta)
            let y = Float(radius) * cosf(beta)
            let tv = Float(i) / Float(rows)
            
            for j in 0...columns {
                let alpha = Float(Float(j) * delta_alpha)
                let x = Float(radius) * sinf(beta) * cosf(alpha)
                let z = Float(radius) * sinf(beta) * sinf(alpha)
                let tu = Float(j) / Float(columns)
                
                vertices.append(TextureVertex(position: (x, y, z),
                                              texture: (tu, tv)))
            }
        }
        
    }
    
    func updateTexture (pixelBuffer: CVPixelBuffer) {
        
        var result: CVReturn = 0
        
        if textureCache == nil {
            result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache)
            if result != kCVReturnSuccess {
                print("updateTexture: Cache Create failure: ", result)
                return
            }
        }
        
        if (yTexture != nil) {
            yTexture = nil
        }
        if (uvTexture != nil) {
            uvTexture = nil
        }
        if let textureCache = textureCache {
            CVOpenGLESTextureCacheFlush(textureCache, 0)
        }
        
        let width = GLsizei(CVPixelBufferGetWidth(pixelBuffer))
        let height = GLsizei(CVPixelBufferGetHeight(pixelBuffer))
        
        glUseProgram(program)
        
        glUniform1i(GLint(samplerY), 0)
        glUniform1i(GLint(samplerUV), 1)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                              textureCache!,
                                                              pixelBuffer,
                                                              nil,
                                                              GLenum(GL_TEXTURE_2D),
                                                              GL_LUMINANCE,
                                                              width,
                                                              height,
                                                              GLenum(GL_LUMINANCE),
                                                              GLenum(GL_UNSIGNED_BYTE),
                                                              0,
                                                              &yTexture)
        
        glBindTexture(CVOpenGLESTextureGetTarget(yTexture!), CVOpenGLESTextureGetName(yTexture!))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                              textureCache!,
                                                              pixelBuffer,
                                                              nil,
                                                              GLenum(GL_TEXTURE_2D),
                                                              GL_LUMINANCE_ALPHA,
                                                              width / 2,
                                                              height / 2,
                                                              GLenum(GL_LUMINANCE_ALPHA),
                                                              GLenum(GL_UNSIGNED_BYTE),
                                                              1,
                                                              &uvTexture)
        
        glBindTexture(CVOpenGLESTextureGetTarget(uvTexture!), CVOpenGLESTextureGetName(uvTexture!))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        
    }
    
    func render (projectionMatrix: GLKMatrix4, modelViewMatrix: GLKMatrix4) {
        
        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        glUseProgram(program)

        var matrix : GLKMatrix4 = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        withUnsafePointer(to: &matrix) {ptrMatrix in
            ptrMatrix.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
                glUniformMatrix4fv(modelViewProjectionMatrix, 1, GLboolean(GL_FALSE), ptrGLfloat)
            }
        }
        
        glUniform1i(GLint(samplerY), 0)
        glUniform1i(GLint(samplerUV), 1)
        
        if let yTexture = yTexture,
            let uvTexture = uvTexture {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture))
            
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(CVOpenGLESTextureGetTarget(uvTexture), CVOpenGLESTextureGetName(uvTexture))
        }
        
        glBindVertexArrayOES(vertexArray)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_SHORT), nil)
        glBindVertexArrayOES(0)
        
    }
    
}
