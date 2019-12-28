//
//  HostPresenter.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

protocol HostPresenterDelegate: NSObjectProtocol {
    func netService(status: String)
    func socket(status: String, socket: GCDAsyncSocket)
    func incomingValue(str: String)
}

class HostPresenter: NSObject {

    private var hostService = HostService()
    weak private var delegate: HostPresenterDelegate?
    
    init(hostService: HostService) {
        self.hostService = hostService
    }
    
    func setDelegate(delegate: HostPresenterDelegate) {
        self.delegate = delegate
    }
    
    func startBroadcast() {
        hostService.startBroadcast(netServiceBlock: { (isConnected, netServiceStatus) in
            if isConnected {
                self.delegate?.netService(status: netServiceStatus ?? "NetSrvice Connected.")
            } else {
                self.delegate?.netService(status: netServiceStatus ?? "NetService Failed to connect.")
            }
        }, socketBlock: { (socketStatus, objSocket) in
            self.delegate?.socket(status: socketStatus, socket: objSocket)
        }) { (incomingVal) in
            self.delegate?.incomingValue(str: incomingVal)
        }
    }
    
    func removeSocket() {
        hostService.removeSocket()
    }
}
