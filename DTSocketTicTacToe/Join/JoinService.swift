//
//  JoinService.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

class JoinService: NSObject {
    
    var services = [NetService]()
    var joinSocket = GCDAsyncSocket()
    var serviceBrowser = NetServiceBrowser()
    var isConnected = false
    
    typealias NetServiceCompletionBlock = (String) -> Void
    typealias NetServiceBrowserCompletionBlock = (String) -> Void
    typealias SocketStatusCompletionBlock = (String, GCDAsyncSocket) -> Void
    typealias ReloadConnectionsBlock = ([NetService]) -> Void
    typealias InComingValueCompletionBlock = (String) -> Void
    
    
    var netServiceCompletionBlock: NetServiceCompletionBlock!
    var netServiceBrowserCompletionBlock: NetServiceBrowserCompletionBlock!
    var socketStatusCompletionBlock: SocketStatusCompletionBlock!
    var reloadConnectionsBlock: ReloadConnectionsBlock!
    var inComingValueCompletionBlock: InComingValueCompletionBlock!
    
    /*****
     serviceBrowser, is of type NSNetServiceBrowser and will search the network for network services that are of interest to us.
     *****/
    
    func startBrowsing(netServiceBlock:  @escaping (String) -> Void, netServiceBrowserBlock: @escaping (String) -> Void, socketStatusBlock: @escaping (String, GCDAsyncSocket) -> Void, reloadConnectionsBlock: @escaping ([NetService]) -> Void, incominngValueBlock:
         @escaping (String) -> Void) {
        self.netServiceCompletionBlock = netServiceBrowserBlock
        self.netServiceBrowserCompletionBlock = netServiceBrowserBlock
        self.socketStatusCompletionBlock = socketStatusBlock
        self.reloadConnectionsBlock = reloadConnectionsBlock
        self.inComingValueCompletionBlock = incominngValueBlock
        self.services.removeAll()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.searchForServices(ofType: Constants.NETSERVICE.type, inDomain: Constants.NETSERVICE.domain)
    }
    
    func serviceSelected(service: NetService) {
        service.delegate = self
        service.resolve(withTimeout: 30.0)
    }
    
}

//MARK: - Netservice Browser Delegate
extension JoinService: NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        netServiceBrowserCompletionBlock("Net service browser Did find service: \(service)")
        print("more incoming ", moreComing , " service ", service)
        self.services.append(service)
        if !moreComing {
            //let arr: NSArray = services as NSArray
           // arr.sortedArray(using: [NSSortDescriptor.init(key: "name", ascending: true)])
            //Reload tableview
            reloadConnectionsBlock(self.services)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        netServiceBrowserCompletionBlock("Net service browser Did remove service: \(service)")
        self.services = services.filter {
            return service != $0
        }
        if !moreComing {
            //Reload tableview
            reloadConnectionsBlock(self.services)
        }
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        netServiceBrowserCompletionBlock("Net service browser did stop search.")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        netServiceBrowserCompletionBlock("Net service browser failed to search with error: \(errorDict)")
    }
    
    func stopBrowsing() {
        netServiceBrowserCompletionBlock("Net service browser stopped browsing.")
        serviceBrowser.stop()
        serviceBrowser.delegate = nil
        self.serviceBrowser = NetServiceBrowser()
    }
}

//MARK: - NetService Delegate
extension JoinService: NetServiceDelegate {
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if connect(with: sender) {
            self.netServiceCompletionBlock("Did Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        } else {
            self.netServiceCompletionBlock("Unable to Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        }
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        self.netServiceCompletionBlock("NetService : \(sender) failed to resolve with info: \(errorDict).")
    }
    
    func connect(with service: NetService?) -> Bool {
        var isConnected = false
        
        // Copy Service Addresses
        let addresses = service?.addresses

        if !joinSocket.isConnected {
            // Initialize Socket
            joinSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
            // Connect
            while !isConnected && addresses?.count != nil {
                let address = addresses?[0]
                if address != nil {
                    
                    if let _ = try? joinSocket.connect(toAddress: address!) {
                        isConnected = true
                        print("Socket connected.")
                    } else {
                        print("Unable to connect to address.")
                    }
                }
            }
        } else {
            isConnected = joinSocket.isConnected
        }
        self.netServiceCompletionBlock("NetService : \(String(describing: service)) connected.")
        return isConnected
    }
    
}

//MARK: - GCDAsyncSocket Delegate
extension JoinService: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //print("Socket Did Connect to Host: \(host), Port: \(port)")
      //  socket = sock
        socketStatusCompletionBlock("Socket Did Connect to Host: \(host), Port: \(port)", sock)
        sendValue(str: Constants.NETSERVICE.joinSoc)
    }
    
    func sendValue(str: String) {
        // Start Reading
        let data = Data(str.utf8)
        joinSocket.write(data, withTimeout: -1.0, tag: 3)
        joinSocket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: 3)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if err != nil {
          //  print("Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err!.localizedDescription).")
            socketStatusCompletionBlock("Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err!.localizedDescription).", sock)
            joinSocket.delegate = nil
            joinSocket = GCDAsyncSocket()
        } else {
            socketStatusCompletionBlock("socketDidDisconnect with sock: \(sock)", sock)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let str = String(decoding: data, as: UTF8.self)
        let astr = "Join did read \(str) with host port: \(sock.connectedPort)"
        print(astr)
        socketStatusCompletionBlock(astr, sock)
       // socketStatusCompletionBlock("DATA X Join Read : \(str), aTag: \(tag)",sock)
        inComingValueCompletionBlock(str)
       // socketStatusCompletionBlock(Constants.NETSERVICE.socketConnected,sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        let astr = "Join did write data to host port: \(sock.connectedPort)"
        print(astr)
        socketStatusCompletionBlock(astr,sock)
    }
    
}

