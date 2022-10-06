//
//  FoodCollectionTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 16/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class FoodCollectionTableViewCell: BaseCollectionViewInTableViewCell<ProductData> {

    @IBOutlet weak var btn_all: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    var selectProduct: ((_ data: ProductData) -> Void)!
    var onTapAll:  (()-> Void)!
    private let repo = HomeRepository()
    var tapOnCommentButton: ((_ tag: ProductData, _ index: Int) -> Void)!
    var tapOnShareButton: ((_ tag: ProductData, _ index: Int) -> Void)!
    var tapOnDidSelect: ((_ tag: ProductData, _ index: Int) -> Void)!

    override func awakeFromNib() {
        nib = CollectionViewCell.foodCollectionViewCell.rawValue
        super.awakeFromNib()
        btn_all.setTitle("All".localized(), for: .normal)
        // Initialization code
    }
    
    override func initView(withData: [ProductData]) {
        super.initView(withData: withData)
        self.collectionView.reloadData()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = super.collectionView(collectionView, cellForItemAt: indexPath) as! FoodCollectionViewCell
        c.initViewWith(self.data?[indexPath.row] ?? ProductData())
        
        
        
        
        //Like Managment
        c.tapOnLikeButton = {
            self.repo.postDishLike(self.data?[indexPath.row].id.toString() ?? "") { (data) in
                if c.likeBtn.isSelected{
                    self.data?[indexPath.row].isLike = "no"
                    self.data?[indexPath.row].totalLikes = (self.data?[indexPath.row].totalLikes ?? 0) - 1

                }else{
                    self.data?[indexPath.row].isLike = "yes"
                    self.data?[indexPath.row].totalLikes = (self.data?[indexPath.row].totalLikes ?? 0) + 1
                }
                c.likeBtn.isSelected = !c.likeBtn.isSelected
                c.likes.text = "\(self.data?[indexPath.row].totalLikes ?? 0)"
            }
            print("Like Button Clicked")
        }
        //        //Favorite Managment
        c.tapOnFavButton = {
            self.repo.postDishFavourite(self.data?[indexPath.row].id.toString() ?? "") { (data) in
                if c.favBtn.isSelected{
                    self.data?[indexPath.row].isFavourites = "no"
                }else{
                    self.data?[indexPath.row].isFavourites = "yes"
                }
                c.favBtn.isSelected = !c.favBtn.isSelected
            }
            print("Comment Button Clicked")
        }
        c.tapOnCommentButton = {
            self.tapOnCommentButton(self.data?[indexPath.row] ?? ProductData(),indexPath.row)
        }
        c.tapOnShareButton = {
            self.tapOnShareButton(self.data?[indexPath.row] ?? ProductData(),indexPath.row)
        }
        c.tapOndidSelect = {
           self.selectProduct(self.data?[indexPath.row] ?? ProductData())
        }
        
        return c
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.height
        return CGSize(width: width + 40, height: width)
    }
    
    
    
    
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // self.selectProduct(self.data?[indexPath.row] ?? ProductData())
    }
    
    @IBAction private func showAllButtonClicked(_ sender: UIButton) {
        onTapAll()
    }
    
}
