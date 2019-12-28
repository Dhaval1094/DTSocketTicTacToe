//
//  HostService.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

class HostService: NSObject {

    var service = NetService()
    var hostSocket = GCDAsyncSocket()
    
    typealias NetServiceCompletionBlock = (Bool, String?) -> Void
    typealias SocketStatusCompletionBlock = (String, GCDAsyncSocket) -> Void
    typealias InComingValueCompletionBlock = (String) -> Void
    
    var netServiceCompletionBlock: NetServiceCompletionBlock!
    var socketStatusCompletionBlock: SocketStatusCompletionBlock!
    var inComingValueCompletionBlock: InComingValueCompletionBlock!
    
    /****
     The service property represents the network service that we will be publishing using Bonjour.
     The socket property is of type GCDAsyncSocket and provides an interface for interacting with the socket that we will be using to listen for incoming connections.
     ****/
    
    func startBroadcast(netServiceBlock: @escaping ((Bool,String?) -> Void), socketBlock: @escaping ((String, GCDAsyncSocket) -> Void) , incominngValueBlock:
        @escaping (String) -> Void) {
        netServiceCompletionBlock = netServiceBlock
        socketStatusCompletionBlock = socketBlock
        inComingValueCompletionBlock = incominngValueBlock
        // Initialize GCDAsyncSocket
        hostSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        // Start Listening for Incoming Connections
        if let _ = try? hostSocket.accept(onPort: Constants.NETSERVICE.host_port) {
            // Initialize Service
            service = NetService(domain: "local.", type: Constants.NETSERVICE.type, name: Constants.NETSERVICE.name, port: Int32(hostSocket.localPort))
            // Configure Service
            service.delegate = self
            // Publish Service
            service.publish()
        } else {
            netServiceCompletionBlock(false, "Unable to create socket.")
        }
    }
    
    
    func removeSocket() {
        hostSocket.delegate = nil
        hostSocket = GCDAsyncSocket()
    }
    
}

//MARK: - NetService Delegate
extension HostService: NetServiceDelegate {
    
    func netServiceDidPublish(_ sender: NetService) {
       // print("Bonjour Service Published: domain'\(service.domain)' type'\(service.type)' name'\(service.name)' port'\(service.port)'")
        netServiceCompletionBlock(true, "Bonjour Service Published: domain'\(service.domain)' type'\(service.type)' name'\(service.name)' port'\(service.port)'")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
       // print("Failed to Publish Service: domain'\(service.domain)' type'\(service.type)' name'\(service.name)' port'\(service.port)' error: \(errorDict)")
        netServiceCompletionBlock(false, "Failed to Publish Service: domain'\(service.domain)' type'\(service.type)' name'\(service.name)' port'\(service.port)' error: \(errorDict)")
    }
    
}

//MARK: - GCDAsyncSocket Delegate
extension HostService: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
      //  print("Accepted New Socket from \(String(describing: newSocket.connectedHost)):\(newSocket.connectedPort)")
        hostSocket = newSocket
        hostSocket.delegate = self
        hostSocket.delegateQueue = .main
        socketStatusCompletionBlock("Accepted New Socket from \(String(describing: newSocket.connectedHost)):\(newSocket.connectedPort)", sock)
        // Read Data from Socket
        //newSocket.readData(toLength: UInt(sizeof(__uint64_t.self)), withTimeout: -1.0, tag: 0)
        sendValue(str: Constants.NETSERVICE.hostSoc)
    }
    
    func sendValue(str: String) {
        let size = UInt(MemoryLayout<UInt64>.size)
        let data = Data(str.utf8)
        hostSocket.write(data, withTimeout: -1.0, tag: 2)
        hostSocket.readData(toLength: size, withTimeout: -1.0, tag: 2)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let str = String(decoding: data, as: UTF8.self)
      //  print("DATA X Read HOST :", str, " aTag: \(tag), connected port : \(sock.connectedPort)")
        let astr = "Host did read \(str) with join port: \(sock.connectedPort)"
         socketStatusCompletionBlock(astr, sock)
        print(astr)
       // socketStatusCompletionBlock("DATA X Host Read : \(str), aTag: \(tag)", sock)
        inComingValueCompletionBlock(str)
        //if str ==
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        let astr = "Host did write data on join port: \(sock.connectedPort)"
        print(astr)
        socketStatusCompletionBlock(astr,sock)
        //socketStatusCompletionBlock("DATA X Host Write : socket \(sock) , aTag: \(tag)",sock)
      //  socketStatusCompletionBlock(Constants.NETSERVICE.socketConnected, sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("\(sock) didConnectToHost \(host) ")
        socketStatusCompletionBlock("\(sock) didConnectToHost \(host) ", sock)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if (hostSocket == sock) {
            socketStatusCompletionBlock("Socket with port: \(sock.connectedPort) disconnected with error: \(err?.localizedDescription ?? "NULL")", sock)
            removeSocket()
        }
    }
    
}

