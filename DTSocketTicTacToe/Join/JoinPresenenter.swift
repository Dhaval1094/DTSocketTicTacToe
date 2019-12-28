//
//  JoinPresenenter.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

protocol JoinPresenterDelegate: NSObjectProtocol {
    func netServiceBrowser(status: String)
    func socket(status: String, socket: GCDAsyncSocket)
    func netService(status: String)
    func reloadConnections(services: [NetService])
    func incomingValue(str: String)
}

class JoinPresenter: NSObject {
    
    private var joinService = JoinService()
    weak private var delegate: JoinPresenterDelegate?
    
    
    init(joinService: JoinService) {
        self.joinService = joinService
    }
    
    func setDelegate(delegate: JoinPresenterDelegate) {
        self.delegate = delegate
    }
    
    func startBrowsing() {

        joinService.startBrowsing(netServiceBlock: { (netServiceStatus) in
            self.delegate?.netService(status: netServiceStatus)
        }, netServiceBrowserBlock: { (netServiceBrowserStatus) in
            self.delegate?.netServiceBrowser(status: netServiceBrowserStatus)
        }, socketStatusBlock: { (socketStatus, objSocket) in
            self.delegate?.socket(status: socketStatus, socket: objSocket)
        }, reloadConnectionsBlock: { (netservices) in
            //Reload TableView With Bounjor Services
            self.delegate?.reloadConnections(services: netservices)
        }) { (incomingValue) in
            self.delegate?.incomingValue(str: incomingValue)
        }
        
    }
    
    func serviceSelected(service: NetService) {
        joinService.serviceSelected(service: service)
    }
    
    func stopBrowsing() {
        joinService.stopBrowsing()
    }
    
}
