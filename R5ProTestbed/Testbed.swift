//
//  Testbed.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
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
