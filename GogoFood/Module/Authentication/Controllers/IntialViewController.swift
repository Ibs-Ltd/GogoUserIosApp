//
//  IntialViewController.swift
//  GogoFood
//
//  Created by MAC on 28/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import Foundation

class IntialViewController: BaseViewController<BaseData>, BottomPopupDelegate {

    @IBOutlet weak var loader: UIImageView?
    private let repo = MapRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      definesPresentationContext = true
        #if User
        print("I am user")
        #elseif Restaurant
        print("I am a Restaurant")
        #endif
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.rotateLayerInfinite()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.setScreenAsPerUser()
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.setScreenAsPerUser()
//        }
//        self.repo.checkServiceAvailableAPI { (checkValue) in
//            if checkValue{
//                print(checkValue)
//                print("Yes")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                    self.setScreenAsPerUser()
//                }
//            }else{
//                print("No")
//
//                let sb = UIStoryboard(name: "Authentication", bundle: nil)
//                guard  let popupVC = sb.instantiateViewController(withIdentifier: Controller.initServiceNotExistViewController.rawValue) as? ServiceNotExistViewController else {return}
//                popupVC.height = self.view.frame.height
//                popupVC.topCornerRadius = 20
//                popupVC.presentDuration = 0.33
//                popupVC.dismissDuration = 0.33
//                popupVC.popupDelegate = self
//                popupVC.shouldDismissInteractivelty = false
//                popupVC.previousObj = self
//                self.present(popupVC, animated: true, completion: nil)
//            }
//        }
    }

    func bottomPopupDidDismiss() {
        print("bottomPopupWillDismiss")
    }
    
    func showLoginScreen() {
        self.performSegue(withIdentifier: "start", sender: self)
    }
    
    
    func setScreenAsPerUser() {
        let firstTime = UserDefaults.standard.value(forKey: "firstTime") as? String ?? "no"
        if firstTime == "no"{
            let sb = UIStoryboard(name: "Authentication", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: Controller.initLanguage.rawValue)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }else{
            if let user = CurrentSession.getI().localData.profile {
                if (user.userStatus ?? .exsisting) == .exsisting {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: Controller.userTab.rawValue)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }else{
                    showLoginScreen()
                }
            }else{
                showLoginScreen()
            }
        }
    }

    func rotateLayerInfinite() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 2 // or however long you want ...
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        loader?.layer.add(rotation, forKey: "rotationAnimation")
    }
    
}

