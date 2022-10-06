//
//  Restuarent_TableViewcellTableViewCell.swift
//  User
//
//  Created by ItsDp on 20/08/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class Restuarent_TableViewCell: UITableViewCell {

    @IBOutlet weak var colVw_resturent: UICollectionView!
    var resturent: [RestaurantProfileData] = []
    var onSelectTag: ((_ index: Int) -> Void)!
    private var product: [ProductData] = []
    private let repo = HomeRepository()

    var tapOnCommentButton: ((_ tag: ProductData, _ index: Int) -> Void)!
    var tapOnShareButton: ((_ tag: ProductData, _ index: Int) -> Void)!

    var tapOnDidSelect: ((_ tag: ProductData, _ index: Int) -> Void)!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "Restuarent_CollectionCell", bundle:nil)
        colVw_resturent.register(nibName, forCellWithReuseIdentifier: "Restuarent_CollectionCell")
        colVw_resturent.delegate =  self
        colVw_resturent.dataSource = self
        // Initialization code
    }
    func initWithData(_ withData:[ProductData])  {
        self.product = withData
        self.colVw_resturent.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
    }
}

extension Restuarent_TableViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "Restuarent_CollectionCell", for: indexPath) as! Restuarent_CollectionCell
        c.initView(withData: product[indexPath.row])
        c.tapOnLikeButton = {
            self.repo.postDishLike(self.product[indexPath.row].id.toString()) { (data) in
                if c.likeBtn.isSelected{
                    self.product[indexPath.row].isLike = "no"
                    self.product[indexPath.row].totalLikes = self.product[indexPath.row].totalLikes - 1
                }else{
                    self.product[indexPath.row].isLike = "yes"
                    self.product[indexPath.row].totalLikes = self.product[indexPath.row].totalLikes + 1
                }
                c.likeBtn.isSelected = !c.likeBtn.isSelected
                c.likeCount.text = "\(self.product[indexPath.row].totalLikes ?? 0)"
            }
        }
        
        c.tapOnFavButton = {
            self.repo.postDishFavourite(self.product[indexPath.row].id.toString()) { (data) in
                if c.favBtn.isSelected{
                    self.product[indexPath.row].isFavourites = "no"
                }else{
                    self.product[indexPath.row].isFavourites = "yes"
                }
                c.favBtn.isSelected = !c.favBtn.isSelected
            }
        }
        
        c.tapOnCommentButton = {
            
            self.tapOnCommentButton(self.product[indexPath.row],indexPath.row)
            
//            if self.product[indexPath.row].is_commentable == "yes"{
////                let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
////                vc.producrtID = self.product[indexPath.row]
////                self.navigationController?.pushViewController(vc, animated: true)
//            }
        }
        
                c.tapOnShareButton = {
                    
                    self.tapOnShareButton(self.product[indexPath.row],indexPath.row)
                    
        //            if self.product[indexPath.row].is_commentable == "yes"{
        ////                let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
        ////                vc.producrtID = self.product[indexPath.row]
        ////                self.navigationController?.pushViewController(vc, animated: true)
        //            }
                }
        
        return c
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tapOnDidSelect(product[indexPath.row],indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width - padding
//        if checkDevice() == .small{
//            // Small Device
//            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 + 80)
//        }
        return CGSize(width: collectionViewSize/2, height: 246)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
