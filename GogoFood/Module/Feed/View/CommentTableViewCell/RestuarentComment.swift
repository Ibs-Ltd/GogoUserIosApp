//
//  RestuarentComment.swift
//  User
//
//  Created by ItsDp on 19/07/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class RestuarentComment: UITableViewCell {

    @IBOutlet var restuarentImage : UIImageView!
    @IBOutlet var restuarentnameLbl : UILabel!
    @IBOutlet var restuarentCommentLbl : UILabel!
    var tapOnMoreButton: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreBtnClickded(_ sender: UIButton) {
        tapOnMoreButton()
    }
    
}
