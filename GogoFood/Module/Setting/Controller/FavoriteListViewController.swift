//
//  FavoriteListViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 14/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import SocketIO
import Localize_Swift

class FavoriteListViewController: BaseTableViewController<StoreInfomationData>, UITextFieldDelegate{
    @IBOutlet weak var btn_high: UIButton!
    
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_sort: UILabel!
    @IBOutlet weak var btn_low: UIButton!
    @IBOutlet weak var empty_img: UIImageView!
    @IBOutlet weak var restroInfoView: UIView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var searchBa: SearchBar!
    @IBOutlet weak var norecordLBl: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mealTypes: UILabel!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var totalSold: UILabel!
    @IBOutlet weak var openingInfoView: UIView!
    
    @IBOutlet weak var btn_apply: UIButton!
    
    @IBOutlet weak var slider: RangeSeekSlider!
    @IBOutlet weak var filter_Vw: UIView!
    var filterValues : (sort:String,min:CGFloat,max:CGFloat)?
    private let repo = HomeRepository()
    private var searchArray : [ProductDataForFavorites] = []
    private var product: [ProductDataForFavorites] = []
    private var productOriginal: [ProductDataForFavorites] = []
    var checkSearchValue : Bool = true
    private var selectedTag: UInt!
    var searchOn = false
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        nib = [TableViewCell.foodDetailTableViewCell.rawValue,               TableViewCell.homeFooter.rawValue,TableViewCell.searchItemRestaurantCell.rawValue]
        super.viewDidLoad()
        empty_img.isHidden = true
        localization()
        slider.delegate = self
        filterValues = ("",slider.minValue,slider.maxValue)
        setRestaurantInfo()
        
        if Localize.currentLanguage() == "en"{
            self.setNavigationTitleTextColor("FAVOURITE FOOD")
        }else{
            self.setNavigationTitleTextColor("FAVOURITE FOOD".localized())
        }
        
        //createNavigationLeftButton(NavigationTitleString.favouritefood.localized())
        //addCartButton()
       // callFavListAPI()
        searchBa.searchView.placeholder = "What do you want to eat?".localized()
        self.searchBa.searchView.delegate = self
        
        self.searchBa.speechBtn.resultHandler = {
            self.searchBa.searchView.text = $1?.bestTranscription.formattedString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                print(self.searchBa.searchView.text ?? "")
                self.searchOn = true
                var searchText  = self.searchBa.searchView.text ?? ""
                if  searchText == ""{
                    searchText = ""
                    self.searchOn = false
                    return
                }
                self.searchArray = self.product.filter({(($0.favoritesDic?.name ?? "").localizedCaseInsensitiveContains(searchText))})
                self.tableView.reloadData()
            })
        }
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    @objc private func refreshWeatherData(_ sender: Any) {
        refreshdata()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designFooter()
    }
    func localization() {
        norecordLBl.text   = "There is no favorite item yet!".localized()
        lbl_sort.text  = "Sort".localized()
        btn_low.setTitle("Low".localized(), for: .normal)
        btn_high.setTitle("High".localized(), for: .normal)
        lbl_price.text = "Price".localized()
        btn_apply.setTitle("Apply Filter".localized(), for: .normal)
    }
    
    

    deinit {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
       }
     @objc override func onChangeCartItem(notification: Notification) {
         super.onChangeCartItem(notification: notification)
         updateFooter()
         self.tableView.reloadData()
     }
    
    
    
    func callFavListAPI() {
        
        var tmpObj = GGSkeletonView()
        tmpObj = tmpObj.createFoodCategorySkeletonView(viewObj: self.view) as! GGSkeletonView
        repo.getFavoriteList("") { (data) in
            self.productOriginal = data.favorites ?? []
            self.product = data.favorites ?? []
            self.product =  self.product.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) > ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})

            self.tableView.reloadData()
            if self.product.count == 0{
                self.norecordLBl.isHidden = false
                self.empty_img.isHidden =  false
            }else{
                self.norecordLBl.isHidden = true
                self.empty_img.isHidden =  true
            }
            tmpObj.stopHomeSkeletonView(viewObj: tmpObj)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBa.searchView.text = nil
        self.searchOn = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
        callFavListAPI()
    }

 

    // MARK: - UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        self.searchOn = true
        var searchText  = textField.text! + string
        if string == "" && searchText.count == 1{
            searchText = ""
            self.searchOn = false
        }
        self.searchArray = self.product.filter({(($0.favoritesDic?.name ?? "").localizedCaseInsensitiveContains(searchText))})
        self.tableView.reloadData()
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.searchArray.count > 0{
            self.searchArray.removeAll()
            self.searchOn = false
            self.tableView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setRestaurantInfo() {
        if let profile = self.data?.restaurant {
            ServerImageFetcher.i.loadProfileImageIn(restaurantImageView, url: profile.profile_picture ?? "")
            name.text = profile.name
            cookingTime.setTitle(profile.getCookingTime(), for: .normal)
            totalSold.text = profile.getTotalSold()
            mealTypes.text = profile.description
        }
    }
    
    @IBAction func onActionSort(_ sender: UIButton) {
        
        if sender == self.btn_low{
            btn_low.setImage(#imageLiteral(resourceName: "select"), for: .normal)
            btn_high.setImage(#imageLiteral(resourceName: "Ellipse 35"), for: .normal)
            filterValues?.sort = "low"
        }else{
            btn_high.setImage(#imageLiteral(resourceName: "select"), for: .normal)
            btn_low.setImage(#imageLiteral(resourceName: "Ellipse 35"), for: .normal)
            filterValues?.sort = "high"
        }
    }
    @IBAction func onclickFilter(_ sender: Any) {
        self.filter_Vw.alpha = 1.0
    }
    @IBAction func onHideFilter(_ sender: Any) {
       self.filter_Vw.alpha = 0.0
    }
    @IBAction func onApplyFilter(_ sender: Any) {
        
         var object : [ProductDataForFavorites] = []

        
        
        if searchOn{
            if filterValues?.sort == "low"{
                self.searchArray =  self.searchArray.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) < ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})
            }else{
                self.searchArray =  self.searchArray.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) > ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})
            }
        }else{
            if filterValues?.sort == "low"{
                object =  self.productOriginal.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) < ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})
            }else{
                object =  self.productOriginal.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) > ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})
            }
            
            let minValues = object.filter({($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) >= Double(filterValues?.min ?? 0.0)})
            let maxValues = minValues.filter({($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) <= Double(filterValues?.max ?? 0.0)})
            self.product = maxValues
            
        }
        
        
        
        self.tableView.reloadData()
        self.filter_Vw.alpha = 0.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if let d = self.data?.categories {
                return d.isEmpty ? CGFloat.zero : 60
            }
        }
        return CGFloat.zero
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.searchOn == true ? searchArray.count : product.count
        return  section == 0 ? count : 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func getProduct(categoryId: String, restaurent: Int) {

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
              let data = self.searchOn == true ? searchArray[indexPath.row] : product[indexPath.row]
            if let data  = data.favoritesDic {
                showDetailOf(product: data, vc: self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 290 : 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        if indexPath.section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nib[2]) as! SearchItemRestaurantCell
            
            if searchOn{
                cell.data = searchArray[indexPath.row].favoritesDic!
            }else{
                cell.data = product[indexPath.row].favoritesDic!
            }
            
            cell.tapOnCommentButton = { product,index in
                if product.is_commentable == "yes"{
                    let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                    vc.producrtID = product
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            cell.tapOnShareButton = { product,index in
                self.generateShareProductLink(url: product.dish_images.last ?? "", productName: product.name ?? "", productID: product.id, restuarentID: product.restaurant_id?.id ?? 0)
            }
            cell.tapOnFavButton = { product,index in
                self.refreshdata()
            }
            cell.tapOnSelect = { product,index in
                if product.restaurant_id?.storeStaus == "closed"{
                    self.oneButtonAlertController(msgStr: "This item is not available at the moment", naviObj: self)
                }else{
                    self.showProduct(product: product)
                }
            }
            
            
            
            
            //            let c = tableView.dequeueReusableCell(withIdentifier: nib[0]) as! FoodDetailTableViewCell
            //
            
            
            
            //            c.tapOnLikeButton = {
            //                self.repo.postDishLike(self.product[indexPath.row].favoritesDic!.id.toString()) { (data) in
            //                    if c.likeBtn.isSelected{
            //                        self.product[indexPath.row].favoritesDic!.isLike = "no"
            //                        self.product[indexPath.row].favoritesDic!.totalLikes = self.product[indexPath.row].favoritesDic!.totalLikes - 1
            //                    }else{
            //                        self.product[indexPath.row].favoritesDic!.isLike = "yes"
            //                        self.product[indexPath.row].favoritesDic!.totalLikes = self.product[indexPath.row].favoritesDic!.totalLikes + 1
            //                    }
            //                    c.likeBtn.isSelected = !c.likeBtn.isSelected
            //                    c.likeCount.text =  "\(self.product[indexPath.row].favoritesDic!.totalLikes ?? 0)"
            //                }
            //            }
            //            c.tapOnFavButton = {
            //                self.repo.postDishFavourite(self.product[indexPath.row].favoritesDic!.id.toString()) { (data) in
            //                    self.product.remove(at: indexPath.row)
            //                    self.tableView.reloadData()
            //                }
            //            }
            //            c.tapOnCommentButton = {
            //                if self.product[indexPath.row].favoritesDic!.is_commentable == "yes"{
            //                    let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
            //                    vc.producrtID = self.product[indexPath.row].favoritesDic
            //                    self.navigationController?.pushViewController(vc, animated: true)
            //                }
            //            }
            //            c.tapOnShareButton = {
            //
            //
            //                self.generateShareProductLink(url: self.product[indexPath.row].favoritesDic?.dish_images.last ?? "", productName: self.product[indexPath.row].favoritesDic?.name ?? "", productID: self.product[indexPath.row].favoritesDic?.id ?? 0, restuarentID: self.product[indexPath.row].favoritesDic?.restaurant_id?.id ?? 0)
            //            }
            
            return cell
        }else{
            if CurrentSession.getI().localData.cart.cartItems.count != 0{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    private func showProduct(product: ProductData) {
        showDetailOf(product: product, vc: self)
    }
    
}
// MARK: - RangeSeekSliderDelegate

extension FavoriteListViewController: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        filterValues?.min = minValue
        filterValues?.max = maxValue
    }

    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
extension FavoriteListViewController{
    func refreshdata()  {
        repo.getFavoriteList("") { (data) in
            self.searchOn = false
            self.searchBa.searchView.text = nil
            self.refreshControl.endRefreshing()
            self.productOriginal = data.favorites ?? []
            self.product = data.favorites ?? []
            self.product =  self.product.sorted(by: { ($0.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0) > ($1.favoritesDic?.getFinalPriceAfterAddUpValue() ?? 0.0)})
            
            self.tableView.reloadData()
            if self.product.count == 0{
                self.norecordLBl.isHidden = false
                self.empty_img.isHidden =  false
            }else{
                self.norecordLBl.isHidden = true
                self.empty_img.isHidden =  true
            }
        }
    }
}
