//
//  Testbed.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
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

class Testbed: NSObject {

    static let sharedInstance = Testbed()
    static var dictionary : NSMutableDictionary?
    static var tests : Array<NSMutableDictionary>?
    static var parameters : NSMutableDictionary?
    static var localParameters : NSMutableDictionary?
    
    override init() {
        super.init()
        
        loadTests()
        
        NSLog(Testbed.dictionary!.description)
       
    }
    
    
    static func sections()->Int{
        return 1
    }
    
    static func rowsInSection()->Int{

        return (Testbed.tests?.count)!
    }
    
    static func testAtIndex(index : Int)-> NSDictionary?{
     
        return tests![index]
    }
    
    
    static func setHost(ip : String){
        Testbed.parameters?.setValue(ip, forKey: "host")
    }
    
    static func setServerPort(port : String) {
        Testbed.parameters?.setValue(port, forKey: "server_port")
    }
    
    static func setStreamName(name : String){
        Testbed.parameters?.setValue(name, forKey: "stream1")
    }
    
    static func setStream1Name(name : String){
        Testbed.parameters?.setValue(name, forKey: "stream1")
    }
    
    static func setStream2Name(name : String){
        Testbed.parameters?.setValue(name, forKey: "stream2")
    }
    
    static func setDebug(on : Bool){
        Testbed.parameters?.setValue(on, forKey: "debug_view")
    }
    
    static func setVideo(on : Bool){
        Testbed.parameters?.setValue(on, forKey: "video_on")
    }
    
    static func setAudio(on : Bool){
        Testbed.parameters?.setValue(on, forKey: "audio_on")
    }
    

    static func setHWAccel(on : Bool) {
        Testbed.parameters?.setValue(on, forKey: "hwaccel_on")
    }
    static func setRecord(on: Bool) {
        Testbed.parameters?.setValue(on, forKey: "record_on")
    }

    static func setRecordAppend(on: Bool) {
        Testbed.parameters?.setValue(on, forKey: "append_on")
    }
    
    static func setLocalOverrides(params : NSMutableDictionary?){
        Testbed.localParameters = params
    }
    
    static func setLicenseKey(value: String) {
        Testbed.parameters?.setValue(value, forKey: "license_key");
    }
    
    static func getParameter(param : String)->AnyObject?{
        
        if(Testbed.localParameters != nil){
            if(Testbed.localParameters?[param] != nil){
                return Testbed.localParameters?[param] as AnyObject?
            }
        }
        
        return Testbed.parameters?[param] as AnyObject?
    }

    
    func loadTests(){
        
        let path = Bundle.main.path(forResource: "tests", ofType: "plist")
        
        Testbed.dictionary = NSMutableDictionary(contentsOfFile: path!)//readDictionaryFromFile(path!)
        Testbed.tests = Array<NSMutableDictionary>()
        
        for (_, myValue) in (Testbed.dictionary!.value(forKey: "Tests") as? NSDictionary)! {
            Testbed.tests?.append(myValue as! NSMutableDictionary)
                
        }
        
        
        Testbed.tests!.sort(by: {(dic1 : NSMutableDictionary, dic2 : NSMutableDictionary)->Bool in
            
            if(dic1["name"] as! String == "Home"){
                return true
            }else if(dic2["name"] as! String == "Home"){
                return false
            }
            
            return dic2["name"] as! String > dic1["name"] as! String
            
            })
        
        Testbed.parameters = Testbed.dictionary!.value(forKey: "GlobalProperties") as? NSMutableDictionary
        
        
    }
    


}
