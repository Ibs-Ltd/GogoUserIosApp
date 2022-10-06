//
//  RestrauntCollectionTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 16/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class RestrauntCollectionTableViewCell: BaseCollectionViewInTableViewCell<RestaurantProfileData> {

    @IBOutlet weak var btn_all: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    var hideInfoView = false
    var onTapAll:  (()-> Void)!
    var onTapSingleResraunt:  ((_ indexObj : RestaurantProfileData)-> Void)!

    override func awakeFromNib() {
        nib = CollectionViewCell.restrauntCollectionViewCell.rawValue
        super.awakeFromNib()
        lbl_title.text = "ALL RESTAURANT".localized()
        btn_all.setTitle("All".localized(), for: .normal)
        // Initialization code
    }

    
    override func initView(withData: [RestaurantProfileData]) {
        super.initView(withData: withData)
        self.collectionView.reloadData()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.isScrollEnabled = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    @IBAction private func showAllRestaurants(_ sender: UIButton) {
        onTapAll()
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapSingleResraunt(self.data![indexPath.row])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = super.collectionView(collectionView, cellForItemAt: indexPath) as! RestrauntCollectionViewCell
//        c.orderLabelOutlet.isHidden = hideInfoView
//        if hideInfoView {
//            c.infoViewHeight.constant = 0
//        }
        if let items = self.data {
              c.initView(withData: items[indexPath.row])
        }
        return c
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 280)
    }
}
