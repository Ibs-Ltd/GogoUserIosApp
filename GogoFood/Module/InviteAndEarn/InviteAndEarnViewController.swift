//
//  InviteAndEarnViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 17/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import MessageUI
import Branch

class InviteAndEarnViewController: BaseViewController<BaseData>, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var socialMediaLbl: UILabel!
    
    @IBOutlet weak var inviteDetailBtn: UIBarButtonItem!
    @IBOutlet weak var smsBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var inviteByQRLbl: UILabel!
    @IBOutlet weak var viaSMSLbl: UILabel!
    @IBOutlet weak var qr_Imga: UIImageView!
    @IBOutlet var codeLblSocial : UILabel!
    @IBOutlet var codeLblSMS : UILabel!
    var shareLink = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeLblSocial.text = CurrentSession.getI().localData.profile.referal_code ?? "N/A"
        self.codeLblSMS.text = CurrentSession.getI().localData.profile.referal_code ?? "N/A"
        setNavigationTitleTextColor(NavigationTitleString.inviteAndEarn.localized())
        generateLink { (link) in
            self.shareLink = link
            self.qr_Imga.image = self.generateQRCode(from: link)
        }
        socialMediaLbl.text = "Invite Friend via social media".localized()
        inviteDetailBtn.title = "Invite Detail".localized()
        viaSMSLbl.text = "Invite Friend via SMSs".localized()
        inviteByQRLbl.text = "Invite with QR Code".localized()
        shareBtn.setTitle("SHARE".localized(), for: .normal)
        smsBtn.setTitle("sms".localized().capitalized, for: .normal)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designFooter()
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
       }
     @objc override func onChangeCartItem(notification: Notification) {
         super.onChangeCartItem(notification: notification)
         updateFooter()
     }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
          updateFooter()
      }
    
    
    
    @IBAction func showInviteDetail(_ sender: UIBarButtonItem) {
        let vc: InviteDetailViewController = self.getViewController(.inviteDetail, on: .inviteAndEarn)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func shareOnSocialMedia(_ sender: UIButton) {
        let items = [self.shareLink] as [Any]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        navigationController?.present(controller, animated: true) {() -> Void in }
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    
    @IBAction func shareOnSMS(_ sender: UIButton) {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = self.shareLink
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    func generateLink(completion:@escaping (String) -> ()) {
        let buo = BranchUniversalObject(canonicalIdentifier: "GoGo Food")
        buo.title = "Gogo Food"
        buo.contentDescription = "Food Delivery Expert"
        buo.publiclyIndex = false
        buo.locallyIndex = false
        let userLP: BranchLinkProperties =  BranchLinkProperties()
        userLP.addControlParam("referalcode", withValue: CurrentSession.getI().localData.profile.referal_code ?? "")
        userLP.addControlParam("refer_code", withValue: CurrentSession.getI().localData.profile.referal_code ?? "")
        userLP.addControlParam("referCode", withValue: CurrentSession.getI().localData.profile.referal_code ?? "")

        buo.getShortUrl(with: userLP) { (userURL, userError) in
            if userError == nil {
                completion(userURL ?? "")
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
