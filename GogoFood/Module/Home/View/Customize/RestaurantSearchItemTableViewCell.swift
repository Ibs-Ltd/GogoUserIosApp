//
//  RestaurantSearchItemTableViewCell.swift
//  User
//
//  Created by Keo Ratanak on 9/7/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class RestaurantSearchItemTableViewCell: UITableViewCell ,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    var nib: String!
    @IBOutlet weak var collectionView: UICollectionView!
    var onTapSingleResraunt:  ((_ indexObj : RestaurantProfileData)-> Void)?
    
    var data:[RestaurantProfileData]?{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        nib = CollectionViewCell.restrauntCollectionViewCell.rawValue
        collectionView.dataSource = self
        collectionView.delegate = self
        registerNib()
    }
    
    func registerNib() {
         collectionView.register(UINib(nibName: nib, bundle: nil), forCellWithReuseIdentifier: nib)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = data{
            return self.data?.count ?? 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
         let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: nib, for: indexPath) as! RestrauntCollectionViewCell
        cell.initView(withData: self.data?[indexPath.row] ?? RestaurantProfileData())
    //        c.orderLabelOutlet.isHidden = hideInfoView
    //        if hideInfoView {
    //            c.infoViewHeight.constant = 0
    //        }
        return cell
    }
        

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 275)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapSingleResraunt?(self.data?[indexPath.row] ?? RestaurantProfileData())
    }
    
}
