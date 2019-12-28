//
//  HomeVC.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 14/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

var logConsole = ""

class HomeVC: UIViewController {
    
    //MARK: - IBOutlets
    
    //MARK: - Variables
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        logConsole = ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: - Setup UI
    
    func fnDefaultSetup() {
        
    }
    
    //MARK: - Button Actions
    
    @IBAction func btnJoinClicked(_ sender: Any) {
        let joinVC = self.storyboard?.instantiateViewController(withIdentifier: "JoinVC") as! JoinVC
        self.navigationController?.pushViewController(joinVC, animated: true)
    }
    
    @IBAction func btnHostClicked(_ sender: Any) {
        let hostVC = self.storyboard?.instantiateViewController(withIdentifier: "HostVC") as! HostVC
        self.navigationController?.pushViewController(hostVC, animated: true)
    }
    
    //MARK: - Other Methods
    
    //MARK: - Webservices
    
}
