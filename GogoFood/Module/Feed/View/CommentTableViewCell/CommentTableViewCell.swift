//
//  CommentTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var btn_more: UIButton!
    @IBOutlet var userImage : UIImageView!
    @IBOutlet var usernameLbl : UILabel!
    @IBOutlet var commentLbl : UILabel!
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
