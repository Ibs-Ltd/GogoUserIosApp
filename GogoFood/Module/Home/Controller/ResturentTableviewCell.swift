//
//  ResturentTableviewCell.swift
//  User
//
//  Created by ItsDp on 17/07/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class ResturentTableviewCell:UITableViewCell  {

    @IBOutlet weak var colVw_resturent: UICollectionView!
    var resturent: [RestaurantProfileData] = []
    var onSelectTag: ((_ index: Int) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "RestrauntCollectionViewCell", bundle:nil)
        colVw_resturent.register(nibName, forCellWithReuseIdentifier: "RestrauntCollectionViewCell")
        colVw_resturent.delegate =  self
        colVw_resturent.dataSource = self
        // Initialization code
    }
    func reload()  {
        self.colVw_resturent.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
}

extension  ResturentTableviewCell:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  resturent.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestrauntCollectionViewCell", for: indexPath) as! RestrauntCollectionViewCell
        cell.initView(withData: self.resturent[indexPath.row])
       // cell.numberOfOrder.isHidden = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onSelectTag((indexPath.row))
    }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          let width = (collectionView.frame.width / 2) 
        return CGSize(width: width * 1.5, height: width)
      }
      
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }
    
}

class RestuarentCollcetionCell: UICollectionViewCell {
    
}
