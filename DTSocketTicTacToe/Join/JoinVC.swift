//
//  JoinVC.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

class JoinVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    
    private var joinPresenter = JoinPresenter(joinService: JoinService())
    var services: [NetService]?
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        joinPresenter.setDelegate(delegate: self)
        joinPresenter.startBrowsing()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: - Setup UI
    
    func fnDefaultSetup() {
        
    }
    
    //MARK: - Button Actions
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.joinPresenter.stopBrowsing()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Other Methods
    
    func pushToGameView(objSock: GCDAsyncSocket) {
        guard let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as? GameVC else { return }
        gameVC.isHost = false
        gameVC.socket = objSock
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    //MARK: - Webservices
    
}

extension JoinVC: JoinPresenterDelegate {
    
    func netServiceBrowser(status: String) {
        textView.addTextToConsole(text: status)
    }
    
    func socket(status: String, socket: GCDAsyncSocket) {
        textView.addTextToConsole(text: status)
        if status.contains(Constants.NETSERVICE.hostSoc) {
            self.pushToGameView(objSock: socket)
        }
    }
    
    func netService(status: String) {
        textView.addTextToConsole(text: status)
    }
    
    func reloadConnections(services: [NetService]) {
        self.services = services
        tableView.reloadData()
    }
    
    func incomingValue(str: String) {
        let iVC = self.navigationController?.viewControllers.filter {
            return $0 is GameVC
            }.first
        guard let gameVc = iVC as? GameVC else {
            return
        }
        gameVc.incomingActionWith(str: str)
    }
    
}

extension JoinVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoiningTableViewCell") as! JoiningTableViewCell
        let service = self.services?[indexPath.row]
        cell.textLabel?.text = service?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let service = self.services?[indexPath.row] {
            joinPresenter.serviceSelected(service: service)
        }
    }
    
}
