//
//  GGSkeletonView.swift
//  User
//
//  Created by Apple on 05/06/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class GGSkeletonView: UIView {

    @IBOutlet weak var homeViewObj : UIView!
    @IBOutlet weak var allRestViewObj : UIView!
    @IBOutlet weak var storeInfoViewObj : UIView!
    @IBOutlet weak var foodDetailViewObj : UIView!
    @IBOutlet weak var foodCatViewObj : UIView!
    @IBOutlet weak var historyViewObj : UIView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GGSkeletonView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    // Home View
    func createHomeSkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.homeViewObj.showAnimatedGradientSkeleton()
        skeltonViewObj.homeViewObj.isHidden = false
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopHomeSkeletonView(viewObj : GGSkeletonView) {
        viewObj.homeViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    
    // All Resturant View
    func createResSkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.allRestViewObj.isHidden = false
        skeltonViewObj.allRestViewObj.showAnimatedGradientSkeleton()
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopResSkeletonView(viewObj : GGSkeletonView) {
        viewObj.allRestViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    
    // Store Information View
    func createStoreInfoSkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.storeInfoViewObj.isHidden = false
        skeltonViewObj.storeInfoViewObj.showAnimatedGradientSkeleton()
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopStoreInfoSkeletonView(viewObj : GGSkeletonView) {
        viewObj.storeInfoViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    
    // Food Details View
    func createFoodDetailSkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.foodDetailViewObj.isHidden = false
        skeltonViewObj.foodDetailViewObj.showAnimatedGradientSkeleton()
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopFoodDetailSkeletonView(viewObj : GGSkeletonView) {
        viewObj.foodDetailViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    
    // Food Category View
    func createFoodCategorySkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.foodCatViewObj.isHidden = false
        skeltonViewObj.foodCatViewObj.showAnimatedGradientSkeleton()
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopFoodCategorySkeletonView(viewObj : GGSkeletonView) {
        viewObj.foodCatViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    
    // Food Category View
    func createHistorySkeletonView(viewObj : UIView) -> UIView {
        let skeltonViewxib = Bundle.main.loadNibNamed("GGSkeletonView", owner: self, options: nil)
        let skeltonViewObj = skeltonViewxib?.first as! GGSkeletonView
        skeltonViewObj.frame = viewObj.bounds
        skeltonViewObj.historyViewObj.isHidden = false
        skeltonViewObj.historyViewObj.showAnimatedGradientSkeleton()
        viewObj.addSubview(skeltonViewObj)
        return skeltonViewObj
    }
    
    func stopHistorySkeletonView(viewObj : GGSkeletonView) {
        viewObj.historyViewObj.hideSkeleton()
        viewObj.removeFromSuperview()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
