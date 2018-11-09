//
//  SubscribeReconnectAPITest.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 12/7/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeReconnectAPITest)
class SubscribeReconnectAPITest: BaseTest, NSURLConnectionDelegate {

    var finished = false

    func findStreams() {
        let domain = Testbed.getParameter(param: "host") as! String
        let app = Testbed.getParameter(param: "context") as! String
        let urlPath = "http://" + domain + ":5080" + "/" + app + "/streams.jsp"
        let streamName = Testbed.getParameter(param: "stream1") as! String

        var request = URLRequest(url: URL(string: urlPath)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared

        NSLog("Requesting stream list...")

        session.dataTask(with: request) {data, response, err in

            if err == nil {
//                let resut = data as String
                do {

                    NSLog("Stream list received...")
                    //   Convert our response to a usable NSString
                    let list = try JSONSerialization.jsonObject(with: data!) as! Array<Dictionary<String, String>>;

                    var exists: Bool = false;
                    for dict:Dictionary<String, String> in list {
                        if(dict["name"] == streamName){
                            exists = true;
                            break;
                        }
                    }

                    DispatchQueue.main.async {
                        if (exists) {
                            NSLog("Publisher exists, let's try connecting...")
                            self.Subscribe(streamName)
                        }
                        else {
                            NSLog("Publisher does not exist.")
                            self.reconnect()
                        }
                    }

                }
                catch let error as NSError {
                    NSLog(error.localizedFailureReason!)
                }
            }
            else {
                NSLog(err!.localizedDescription)
            }

        }.resume()

    }

    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.finished {
                return
            }
            self.findStreams()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        self.finished = false
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDefaultR5VideoViewController()
        findStreams()
    }

    func Subscribe(_ name: String) {

        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;

        currentView?.attach(subscribeStream)

        self.subscribeStream!.play(name)

    }

    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {

        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

        if(statusCode == Int32(r5_status_connection_error.rawValue)){

            //we can assume it failed here!
            NSLog("Connection error")
            self.reconnect()

        }
        else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {

            // publisher stopped broadcast. let's resume autoconnect logic.
            let view = currentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if(self.subscribeStream != nil) {
                    view?.attach(nil)
                    self.subscribeStream?.delegate = nil;
                    self.subscribeStream!.stop()
                }
                self.reconnect()
            }
        }

    }

    func onMetaData(data : String){

    }
}
