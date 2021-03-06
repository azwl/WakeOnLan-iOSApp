//
//  BootViewController.swift
//  WakeOnLan
//
//  Created by Owner on 2015/12/15.
//  Copyright © 2015年 Yuta Aizawa. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class BootViewController: UIViewController, AsyncUdpSocketDelegate, GCDAsyncUdpSocketDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func bootBtn(_ sender: AnyObject) {
        
        if targetDataArray.count > 0 {
            for i in 0 ..< targetDataArray.count {
                
                let target = targetDataArray[i]
                if target["flag"] as! Bool == true {
                
                    var ip: String = ""
                    var port: UInt16 = 0
                    var mac: [UInt8] = [0]
                    var broadcast: Bool = true
                    
                    if target["ip"] as? String != nil {
                        ip = target["ip"] as! String
                    }
                    if target["port"] as? String != nil {
                        port = stringToUInt16(target["port"] as! String)
                    }
                    if target["mac"] as? String != nil {
                        mac = self.textToMac(target["mac"] as! String)
                    }
                    if target["broadcast"] as? Bool != nil {
                        broadcast = target["broadcast"] as! Bool
                    }
                    
                    sendPacket(ip, port: port, mac: mac, broadcast: broadcast)
                    print("\(target["title"]!): Send  ip:\(ip) port:\(port) mac:\(mac) broadcast:\(broadcast)")
                } else {
                    print("\(target["title"]!): No Send")
                }
            }
            
        } else {
            showAlert("Error", message: "You must input Target of SettingsTab.")
        }
    }
    
    func sendPacket(_ ip: String, port: UInt16, mac: [UInt8], broadcast: Bool){

        let socket: GCDAsyncUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main )
        
        //Create packet data
        var data: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        
        for _ in 0..<16{
            data += mac
        }
        
        let packet = Data(bytes: UnsafePointer<UInt8>(data), count: data.count)
        
        //Send
        try! socket.enableBroadcast(broadcast)
        socket.send(packet, toHost: ip, port: port, withTimeout: 1, tag: 0)
    }
    
    func showAlert(_ title: String?, message: String?) {
        
        let alertController = UIAlertController(title: title, message: (message ?? ""), preferredStyle: .alert)
        let dafaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dafaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //StringToInt
    func stringToUInt16(_ text: String) -> UInt16 {
        
        let int: Int = Int(text)!
        let uint16: UInt16 = UInt16(int)
        
        return uint16
    }
    
    //String -> UInt8 MacAddress
    func textToMac(_ text: String) -> [UInt8] {
        
        var array: [String] = []
        var returnArray: [UInt8] = []
        
        if let _ = text.range(of: ":") {
            array = text.components(separatedBy: ":")
        }
        else if let _ = text.range(of: "-") {
            array = text.components(separatedBy: "-")
        }
        else if let _ = text.range(of: ",") {
            array = text.components(separatedBy: ",")
        }
        else {
            array = ["FF", "FF", "FF", "FF", "FF", "FF"]
        }
        
        for i in 0 ..< array.count {
            returnArray.append(stringToHex(array[i]))
        }
        
        return returnArray
    }
    func stringToHex(_ str: String) -> UInt8 {
        
        var hex: UInt32 = 0x0;
        let scanner: Scanner = Scanner(string: str)
        scanner.scanHexInt32(&hex)
        
        let uInt8Hex: UInt8 = UInt8(hex)
        
        return uInt8Hex
    }
    
}
