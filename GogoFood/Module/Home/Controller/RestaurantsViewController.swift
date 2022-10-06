//
//  RestaurantsViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 11/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import SpeechRecognizerButton

class RestaurantsViewController: BaseCollectionViewController<RestaurantProfileData>, UITextFieldDelegate {

    @IBOutlet weak var lbl_notfound: UILabel!
    @IBOutlet weak var img_notfound: UIImageView!
    @IBOutlet weak var searchBa: SearchBar!
    var hasShowTopRestuarants = false // To show the top restaurants
    var showRestaurantsFromCart = false //Send the list of restaurants of cart
    private let repo = HomeRepository()
    
    private var searchArray : [RestaurantProfileData]!
    var searchOn : Bool!
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        lbl_notfound.text  = "There is no item matching your search yet!".localized()
        self.collectionView!.alwaysBounceVertical = true
        collectionView.contentInset.bottom = 50
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)

        
        //nib = CollectionViewCell.RestrauntCollectionViewCell.rawValue
        nib = CollectionViewCell.restrauntCollectionViewCell.rawValue
        super.viewDidLoad()
        getData { (yes) in
        }
        self.searchBa.searchView.delegate = self
        self.searchBa.speechBtn.resultHandler = {
            self.searchBa.searchView.text = $1?.bestTranscription.formattedString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let param = ["keyword": self.searchBa.searchView.text ?? ""]
                print(param)
                if self.searchBa.searchView.text != ""{
                    self.repo.searchDishAPI(param) { (data) in
                        self.allItems = data.resaturant
                        self.currentItems = self.allItems
                        if self.currentItems.count == 0 {
                            self.img_notfound.isHidden = false
                            self.lbl_notfound.isHidden = false
                        }else{
                            self.img_notfound.isHidden = true
                            self.lbl_notfound.isHidden = true
                        }
                        self.collectionView.reloadData()
                    }
                }
            })
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designFooter()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
    }
    @objc override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
    }
    
    
    @objc private func refreshWeatherData(_ sender: Any) {

        getData(true) { (yes) in
            if yes{
                self.refreshControl.endRefreshing()
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(self.getHintsFromTextField),
            object: textField)
        self.perform(
            #selector(self.getHintsFromTextField),
            with: textField,
            afterDelay: 1.0)
        return true
    }
    @objc func getHintsFromTextField(textField: UITextField) {
        print("Hints for textField: \(textField)")
        var searchText = String()
        searchText  = textField.text!
        print(searchText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
                let param = ["keyword": self.searchBa.searchView.text ?? ""]
            self.repo.searchDishAPI(param) { (data) in
                self.allItems = data.resaturant
                self.currentItems = self.allItems
                if self.currentItems.count == 0 {
                    self.img_notfound.isHidden = false
                    self.lbl_notfound.isHidden = false
                }else{
                    self.img_notfound.isHidden = true
                    self.lbl_notfound.isHidden = true
                }
                self.collectionView.reloadData()
            }
        })
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        getData(true) { (yes) in
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setCartRestaurants() {
        let unique = Array(Set(self.allItems))
        self.allItems.removeAll()
        self.allItems = unique
        self.currentItems = unique
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchOn{
            return self.searchArray.count
        }else{
            return self.currentItems.count
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if self.currentItems[indexPath.row].storeStaus == "open"{
            let vc: StoreInformationViewController = self.getViewController(.storeInformation, on: .home)
            let data = StoreInfomationData()
            if self.searchOn{
                data.restaurant = self.searchArray[indexPath.row]
            }else{
                data.restaurant = self.currentItems[indexPath.row]
            }
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
//        }else{
//            self.oneButtonAlertController(msgStr: "Sorry we are closed now!", naviObj: self)
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nib, for: indexPath) as! RestrauntCollectionViewCell
        if self.searchOn{
            cell.initView(withData: self.searchArray[indexPath.row])
        }else{
            cell.initView(withData: self.currentItems[indexPath.row])
        }
        
      //  cell.numberOfOrder.isHidden = true
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 290 + 20)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension RestaurantsViewController{
    func getData(_ isRefresh:Bool = false,_ success:@escaping(Bool) -> Void)  {
    self.searchOn = false
    self.searchBa.searchView.delegate = self
        self.createNavigationLeftButton(NavigationTitleString.allRestaurant.localized())
    if showRestaurantsFromCart{
        setCartRestaurants()
    }else{
        var tmpObj = GGSkeletonView()
        if isRefresh == false{
        tmpObj = tmpObj.createResSkeletonView(viewObj: self.view) as! GGSkeletonView
        }
        repo.getallResturants(top: hasShowTopRestuarants) { (data) in
            success(true)
            self.allItems = data.resturants
            self.currentItems = self.allItems
            self.collectionView.reloadData()
            if isRefresh == false{
            tmpObj.stopResSkeletonView(viewObj: tmpObj)
            }
            success(true)
        }
    }
    
//    self.searchBa.speechBtn.resultHandler = {
//        self.searchBa.searchView.text = $1?.bestTranscription.formattedString
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            if self.searchBa.searchView.text != ""{
//                self.searchOn = true
//                self.searchArray = self.currentItems.filter({(($0.name!).localizedCaseInsensitiveContains(self.searchBa.searchView.text!))})
//            }else{
//                self.searchOn = false
//            }
//            self.collectionView.reloadData()
//        })
//    }
    }
}
