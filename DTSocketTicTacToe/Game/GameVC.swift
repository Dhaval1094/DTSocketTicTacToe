//
//  GameVC.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 15/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    
    //MARK: - IBOutlets
   
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblConnectedToPort: UILabel!
    @IBOutlet weak var lblPlayerSign: UILabel!
    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var switchLogConsole: UISwitch!
    
    //MARK: - Variables
    
    var arrPosiibilities = [[Int]]()
    var socket: GCDAsyncSocket?
    var isHost = false
    var lastTurn = "x"
    var arrCross = [Int]()
    var arrZero = [Int]()
    let imgZero = UIImage(named:"zero")!
    let imgCross = UIImage(named:"cross")!
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = logConsole
        arrPosiibilities = [[0,1,2],[0,3,6],[3,4,5],[1,4,7],[6,7,8],[2,5,8],[0,4,8],[2,4,6]]
        setupGame()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Other Methods
    
    func setupGame()  {
        lblPlayerSign.text = isHost ? Constants.GAME.playerx : Constants.GAME.playerZero
        lblGameStatus.text = Constants.GAME.xsTurn
        lblConnectedToPort.text = isHost ? "Host connected to port \(String(describing: socket?.connectedPort))" : "Join connected to port \(String(describing: socket?.connectedPort))"
    }
    
    func setCellWith(tag: Int, isIncoming: Bool) {
        let aCell = collectionview.visibleCells.filter {
            return $0.tag == tag
        }.first
        if let cell = aCell as? TicCollectionViewCell {
            cell.isTapped = true
            if isIncoming {
                isHost ? setCellWith(cell: cell, image: imgZero, turn: "0") : setCellWith(cell: cell, image: imgCross, turn: "x")
            } else {
                isHost ? setCellWith(cell: cell, image: imgCross, turn: "x") : setCellWith(cell: cell, image: imgZero, turn: "0")
            }
            checkWin()
        }
    }
    
    func setCellWith(cell: TicCollectionViewCell, image: UIImage,turn: String) {
        cell.imgView.image = image
        turn == "x" ? arrCross.append(cell.tag) : arrZero.append(cell.tag)
        lastTurn = turn
    }
   
    func reset() {
        arrCross.removeAll()
        arrZero.removeAll()
        let cells = collectionview.visibleCells  as! [TicCollectionViewCell]
        for cell in cells {
            cell.isTapped = false
        }
        collectionview.reloadData()
        setupGame()
    }

    func showAlert(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.dismiss(animated: true, completion: {
                self.reset()
            })
        }
    }
    
    //MARK : - Button Actions
    
    @IBAction func swichValueChange(_ sender: UISwitch) {
        if sender.isOn {
            self.textView.isHidden = false
            self.lblConnectedToPort.isHidden = false
        } else {
            self.textView.isHidden = true
            self.lblConnectedToPort.isHidden = true
        }
    }
}

extension GameVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! TicCollectionViewCell
        Cell.imgView.image = nil
        Cell.tag = indexPath.item
        return Cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currCell = collectionView.cellForItem(at: indexPath) as! TicCollectionViewCell
        if currCell.isTapped {
            return
        }
        let visibleCells = collectionView.visibleCells as! [TicCollectionViewCell]
        let arrSelectedCells = visibleCells.filter {
            return $0.isTapped
        }
        //First ever turn
        if arrSelectedCells.first == nil {
            //No any cell selected
            if isHost {
                lastTurn = "x"
                lblGameStatus.text = Constants.GAME.zerosTurn
                self.sendValue(str: "Host # \(indexPath.item)")
                setCellWith(tag: indexPath.item, isIncoming: false)
                return
            } else {
                //self.sendValue(str: "Join # \(indexPath.item)")
                return
            }
        }
        if isHost {
            if lastTurn == "x" {
                return
            }
        } else {
            if lastTurn == "0" {
                return
            }
        }
        if arrSelectedCells.count % 2 == 0 {
            //Even
            // 'X' tapped
            lblGameStatus.text = Constants.GAME.zerosTurn
            self.sendValue(str: "Host # \(indexPath.item)")
            setCellWith(tag: indexPath.item, isIncoming: false)
        } else {
            //Odd
            // '0' tapped
            lblGameStatus.text = Constants.GAME.xsTurn
            self.sendValue(str: "Join # \(indexPath.item)")
            setCellWith(tag: indexPath.item, isIncoming: false)
        }
        
    }
    
    func checkWin() {
        
        //For all grides filled
        let cells = collectionview.visibleCells as! [TicCollectionViewCell]
        let unTappedCells = cells.filter{ !$0.isTapped }
        if unTappedCells.count == 0 {
            //Game tie
            self.showAlert(title: Constants.GAME.tied)
            return
        }
        
        //For cross
        for obj in arrPosiibilities {
            let findList = obj
            let listSet = Set(arrCross)
            let findListSet = Set(findList)
            let allElemsContained = findListSet.isSubset(of: listSet)
            if allElemsContained {
                //Winner X
                self.showAlert(title: Constants.GAME.xWin)
                return
            }
        }
        
        //For Zero
        for obj in arrPosiibilities {
            let findList = obj
            let listSet = Set(arrZero)
            let findListSet = Set(findList)
            let allElemsContained = findListSet.isSubset(of: listSet)
            if allElemsContained {
                //Winner 0
                self.showAlert(title: Constants.GAME.zeroWin)
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let square = collectionView.frame.size.width / 3.4
        return CGSize.init(width: square, height: square)
    }
    
}

//MARK : - Manage Send data with socket

extension GameVC {
    
    func sendValue(str: String) {
        let size = UInt(MemoryLayout<UInt64>.size)
        let data = Data(str.utf8)
        socket?.write(data, withTimeout: 30.0, tag: isHost ? 2 : 3)
        socket?.readData(toLength: size, withTimeout: 30.0, tag:  isHost ? 2 : 3)
    }
    
    func incomingActionWith(str: String) {
        var number: Int? {
            guard let strNum = str.components(separatedBy: "#").last?.trimmingCharacters(in: .whitespaces) else { return nil }
            return Int(strNum)
        }
        let num = number
        if isHost {
            if str.contains("Join #") && num != nil {
                lblGameStatus.text = Constants.GAME.xsTurn
                print("Join make X on grid no. \(num!)")
                textView.addTextToConsole(text: "Join make X on grid no. \(num!)")
                setCellWith(tag: num!, isIncoming: true)
            }
        } else {
            if str.contains("Host #") && num != nil {
                lblGameStatus.text = Constants.GAME.zerosTurn
                print("Host make 0 on grid no. \(num!)")
                textView.addTextToConsole(text: "Host make 0 on grid no. \(num!)")
                setCellWith(tag: num!, isIncoming: true)
            }
        }
    }
}


class TicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var isTapped = false
    
}

