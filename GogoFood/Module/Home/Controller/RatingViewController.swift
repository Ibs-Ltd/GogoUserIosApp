//
//  RatingViewController.swift
//  User
//
//  Created by Apple on 30/04/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import SBCardPopup
import Cosmos



//MARK::Delegatemethod for Rating
protocol RatingDelegate:class {
    func onSuccessfullRating()
}

class RatingViewController: BaseViewController<BaseData>, SBCardPopupContent {

    @IBOutlet var cosmosView : CosmosView!
    private let repo = MapRepository()
    weak var popupViewController: SBCardPopupViewController?
    
    var producrtID : ProductData!
    let allowsTapToDismissPopupCard = true
    let allowsSwipeToDismissPopupCard = true
    
    static func create(productObj : ProductData) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        viewController.producrtID = productObj
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipButtonPressed(sender: UIButton){
        self.repo.skipRateWallet(self.producrtID.id.toString()) { (data) in
            print(data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.popupViewController?.close()
            })
        }
    }

    @IBAction func sendButtonPressed(sender: UIButton){
        self.repo.singleDishRateWallet(self.producrtID.id.toString(), ratingStr: Int(self.cosmosView!.rating)) { (data) in
            print(data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.popupViewController?.close()
                NotificationCenter.default.post(name: NSNotification.Name("ratingSuccess"), object: nil)

            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
