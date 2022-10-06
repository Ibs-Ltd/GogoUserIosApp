//
//  SearchItemRestaurantCell.swift
//  User
//
//  Created by Keo Ratanak on 9/6/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class SearchItemRestaurantCell:UITableViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var nib: String!
    var selectProduct: ((_ data: ProductData) -> Void)!
    var onTapAll:  (()-> Void)!
    private let repo = HomeRepository()
    var tapOnCommentButton: ((_ tag: ProductData, _ index: Int) -> Void)?
    var tapOnSelect: ((_ tag: ProductData, _ index: Int) -> Void)?
    var tapOnShareButton: ((_ tag: ProductData, _ index: Int) -> Void)!
    var tapOnFavButton: ((_ tag: ProductData, _ index: Int) -> Void)?

    var data:ProductData?{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    override func awakeFromNib() {
        nib = CollectionViewCell.foodCollectionViewCell.rawValue
        collectionView.dataSource = self
        collectionView.delegate = self
        registerNib()
        super.awakeFromNib()
        // Initialization code
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
            return 1
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: nib, for: indexPath) as! FoodCollectionViewCell
        cell.initViewWith(data ?? ProductData())
        
        //Like Managment
        cell.tapOnLikeButton = {
            self.repo.postDishLike(self.data?.id.toString() ?? "") { (data) in
                if cell.likeBtn.isSelected{
                    self.data?.isLike = "no"
                    self.data?.totalLikes -= 1
                }else{
                    self.data?.isLike = "yes"
                    self.data?.totalLikes += 1
                }
                cell.likeBtn.isSelected = !cell.likeBtn.isSelected
                cell.likes.text = "\(self.data?.totalLikes ?? 0)"
            }
            print("Like Button Clicked")
        }
        //        //Favorite Managment
        cell.tapOnFavButton = {
            self.repo.postDishFavourite(self.data?.id.toString() ?? "") { (data) in
                if cell.favBtn.isSelected{
                    self.data?.isFavourites = "no"
                }else{
                    self.data?.isFavourites = "yes"
                }
                cell.favBtn.isSelected = !cell.favBtn.isSelected
                self.tapOnFavButton?(self.data ?? ProductData(),0)
            }
            print("Comment Button Clicked")
        }
        cell.tapOnCommentButton = {
            self.tapOnCommentButton?(self.data ?? ProductData(),0)
        }
        cell.tapOnShareButton = {
            self.tapOnShareButton(self.data ?? ProductData(),indexPath.row)
        }
        cell.tapOndidSelect = {
            self.tapOnSelect?(self.data ?? ProductData(),0)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //self.tapOnSelect?(self.data ?? ProductData(),0)
    }
    
    @IBAction private func showAllButtonClicked(_ sender: UIButton) {
        onTapAll()
    }
    
}

