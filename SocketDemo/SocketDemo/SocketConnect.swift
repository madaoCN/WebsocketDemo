//
//  SocketConnect.swift
//  SocketDemo
//
//  Created by 梁宪松 on 2019/9/12.
//  Copyright © 2019 madao. All rights reserved.
//

import UIKit

typealias Block = (_ obj: Any?) -> (Void)

class SocketConnect: NSObject {

    private var socket: SRWebSocket?
    
    var didOpenBlock: Block?
    var didCloseBlock: Block?
    var receiveTextBlock: Block?
    
    var url: String? {
        
        willSet {
            self.open()
        }
    }
    
    func open() {

        self.close()
        
        guard let socketURLStr = self.url else {
            return
        }

        guard let socketURL = URL.init(string: socketURLStr) else {
            return
        }
        
        self.socket = SRWebSocket.init(url: socketURL)
        guard let ws = socket else {
            return
        }
        
        ws.delegate = self
        ws.open()
    }
    
    func close() {
        
        guard let ws = socket else {
            return
        }
        
        ws.close(withCode: 100, reason: "manual close")
        self.socket?.delegate = nil
        self.socket = nil
    }
}


// MARK: - send Action
extension SocketConnect {
    
    func send(_ dict: Dictionary<String, Any>?) {
        
        guard self.socket?.readyState == SRReadyState.OPEN else {
            return
        }
        
        guard let jsonDict = dict else {
            return
        }
        
        guard JSONSerialization.isValidJSONObject(jsonDict) == true else {
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        
        let dataStr = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
        
        self.socket?.send(dataStr)
    }
}


// MARK: - SRWebSocketDelegate
extension SocketConnect:  SRWebSocketDelegate{
    
    func readMessage(_ message: String?) {
        
        guard let msg = message else {
            return
        }
        
        guard let data = msg.data(using: String.Encoding.utf8) else {
            return
        }
        
        let obj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        self.receiveTextBlock?(obj)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        
        // receive messag
        self.readMessage(message as? String)
    }
 
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        
        self.didOpenBlock?(nil)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
        self.didCloseBlock?(reason)
    }
}
