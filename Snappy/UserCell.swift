//
//  UserCellTableViewCell.swift
//  Snappy
//
//  Created by Steven on 3/10/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
