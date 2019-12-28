//
//  Extensions.swift
//  MultiplayerGame Demo
//
//  Created by Dhaval Trivedi on 15/12/19.
//  Copyright © 2019 Dhaval Trivedi. All rights reserved.
//

import UIKit

extension UITextView {
    
    func addTextToConsole(text: String) {
        logConsole = logConsole + "\n \n" + text
        self.text = logConsole
        let btm = NSMakeRange(self.text.lengthOfBytes(using: String.Encoding.utf8), 0)
        self.scrollRangeToVisible(btm)
    }
    
}

