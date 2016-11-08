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
    
    static func setLocalOverrides(params : NSMutableDictionary?){
        Testbed.localParameters = params
    }
    
    static func getParameter(param : String)->AnyObject?{
        
        if(Testbed.localParameters != nil){
            if(Testbed.localParameters?[param] != nil){
                return Testbed.localParameters?[param]
            }
        }
        
        return Testbed.parameters?[param]
    }

    
    func loadTests(){
        
        let path = NSBundle.mainBundle().pathForResource("tests", ofType: "plist")
        
        Testbed.dictionary = NSMutableDictionary(contentsOfFile: path!)//readDictionaryFromFile(path!)
        Testbed.tests = Array<NSMutableDictionary>()
        
        for (_, myValue) in (Testbed.dictionary!.valueForKey("Tests") as? NSDictionary)! {
            Testbed.tests?.append(myValue as! NSMutableDictionary)
                
        }
        
        
        Testbed.tests!.sortInPlace({(dic1 : NSMutableDictionary, dic2 : NSMutableDictionary)->Bool in
            
            if(dic1["name"] as! String == "Home"){
                return true
            }else if(dic2["name"] as! String == "Home"){
                return false
            }
            
            return dic2["name"] as! String > dic1["name"] as! String
            
            })
        
        Testbed.parameters = Testbed.dictionary!.valueForKey("GlobalProperties") as? NSMutableDictionary
        
        
    }
    


}
