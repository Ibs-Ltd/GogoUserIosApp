//
//  AppSegmentView.swift
//  User
//
//  Created by Keo Ratanak on 9/4/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class AppSegmentView: UICollectionViewController {
    private let reuseIdentifier = "AppSegmentCell"
    private let labelFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    var onClickedItemCallback:((_ item:CategoryData)->())?
    var isFirstLoaded = false
    private let mainLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    private var items:[CategoryData] = []{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    init(){
        super.init(collectionViewLayout: mainLayout)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        // Register cell classes
        self.collectionView?.register(AppSegmentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    // MARK: CollectionView Datasource
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AppSegmentCell
        let item =  items[indexPath.row]
        cell.setItem(item)
        return cell
    }
    // MARK: CollectionView Delegate
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let cloneItems = items
        cloneItems.forEach({$0.isSelected = false})
        if let index = cloneItems.firstIndex(where: {$0.id == item.id}){
            cloneItems[index].isSelected = true
        }
        items = cloneItems
        self.onClickedItemCallback?(item)
    }
    
    func setItems(_ items:[CategoryData]){
        if items.count > 0 && !isFirstLoaded{
            isFirstLoaded = true
            self.items = items
            let newElement: CategoryData = CategoryData.init(JSON: ["cat_name":"All","_id":"all"])!
            newElement.isSelected = true
            self.items.insert(newElement, at: 0)
        }
    }

}

extension AppSegmentView:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightItem:CGFloat = 50
        let item = items[indexPath.row]
        let widthItem = item.cat_name?.uppercased().width(withConstraintedHeight: heightItem, font: labelFont)
        return CGSize(width: widthItem ?? 0, height: heightItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

public extension String{
    func width(withConstraintedHeight height:CGFloat,font:UIFont)->CGFloat{
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font], context: nil)
        return ceil(boundingBox.width)
    }
}

