//
//  LoginTextField.swift
//  Snappy
//
//  Created by Steven on 3/10/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {

    override func awakeFromNib() {
        let boneColor = UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        self.borderStyle = .RoundedRect
        self.clearButtonMode = .WhileEditing
        self.textColor = boneColor
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        self.layer.borderColor = boneColor.CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 8.0
        self.attributedPlaceholder = NSAttributedString(string: "\(self.placeholder!)", attributes: [NSForegroundColorAttributeName: boneColor])
    }
    
}
