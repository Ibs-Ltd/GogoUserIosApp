//
//  ServiceNotExistViewController.swift
//  User
//
//  Created by Apple on 05/05/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class ServiceNotExistViewController: BottomPopupViewController {

    @IBOutlet weak var lbl_desc: UILabel!
    @IBOutlet weak var lbl_We: UILabel!
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    var previousObj : IntialViewController!
    var previousObj1 : VerificationViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_We.text = "We're Sorry".localized()
        lbl_desc.text = "The our service is not available in your region!".localized()

        // Do any additional setup after loading the view.
    }
    

    override var popupHeight: CGFloat { return height ?? CGFloat(300) }
    
    override var popupShouldDismissInteractivelty: Bool { return shouldDismissInteractivelty ?? true }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
