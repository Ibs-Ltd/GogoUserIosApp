//
//  TagTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 16/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class TagTableViewCell: BaseTableViewCell<CategoryData>, TTGTextTagCollectionViewDelegate {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var tagViewOutlet: TTGTextTagCollectionView!
    @IBOutlet weak var titleTextHeightConstraint: NSLayoutConstraint!
    var textConfig: TTGTextTagConfig!
    var select: UInt! = 0
    var tags: [CategoryData]! = []
    var canAddAll = false
    var onSelectTag: ((_ tag: CategoryData, _ index: UInt) -> Void)!
    var needSelected:Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initData() {
        createTextConfig()
        tagViewOutlet.showsHorizontalScrollIndicator = false
        tagViewOutlet.scrollDirection = .horizontal
        tagViewOutlet.delegate = self
        var categoryname = tags.compactMap({$0.cat_name ?? ""})
        if self.canAddAll {
            categoryname.insert("All", at: 0)
            tagViewOutlet.addTags(categoryname, with: textConfig)
        if let _ = select {
                tagViewOutlet.setTagAt(select, selected: true)
            }else{
                tagViewOutlet.setTagAt(0, selected: true)
            }
        }else{
             tagViewOutlet.addTags(categoryname, with: textConfig)
        }
        
        
        
        
        
        //tagViewOutlet.reload()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func createTextConfig() {
        self.textConfig = TTGTextTagConfig()
        textConfig.textColor = .gray
        textConfig.backgroundColor = .white
        textConfig.minWidth = 80
        textConfig.exactHeight = 30
        textConfig.selectedBorderColor = .lightGray
        textConfig.selectedBackgroundColor = .white
        textConfig.selectedTextColor = .gray
        textConfig.borderColor = .lightGray
        textConfig.cornerRadius = 15
        textConfig.selectedCornerRadius = 15
        textConfig.shadowColor = .clear
        textConfig.borderWidth = 1
        textConfig.textFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        if let _ = select {
            tagViewOutlet.setTagAt(select, selected: false)
        }
        self.select = index
        if index != 0 {
            onSelectTag((tags?[Int(index - 1)])!, index)
        }else{
            onSelectTag((tags?[Int(index)])!, index)
        }
        
    }
    
}
