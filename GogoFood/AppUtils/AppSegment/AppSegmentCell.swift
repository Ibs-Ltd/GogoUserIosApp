//
//  AppSegmentCell.swift
//  User
//
//  Created by Keo Ratanak on 9/4/20.
//  Copyright © 2020 GWS. All rights reserved.
//

class AppSegmentCell:UICollectionViewCell{
    private let labelFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = labelFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let borderView:UIView = {
        let borderView = UIView()
        borderView.backgroundColor = AppConstant.primaryColor
        borderView.layer.cornerRadius = 2
        borderView.translatesAutoresizingMaskIntoConstraints = false
        return borderView
    }()
    private var item:CategoryData?{
        didSet{
           configure()
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension AppSegmentCell{
    private  func setConstraints(){
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: topAnchor,constant: 46),
            borderView.leftAnchor.constraint(equalTo: leftAnchor),
            borderView.rightAnchor.constraint(equalTo: rightAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    func setItem(_ item:CategoryData?){
        self.item = item
    }
    
    private func configure(){
        guard let item = item else{
            return
        }
        titleLabel.text = item.cat_name?.uppercased()
        borderView.isHidden = !item.isSelected
    }
}
