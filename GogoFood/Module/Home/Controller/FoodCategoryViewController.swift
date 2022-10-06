//
//  FoodCategoryViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 05/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class FoodCategoryViewController: BaseTableViewController<ProductData>,UITextFieldDelegate {

    
     @IBOutlet weak var slider: RangeSeekSlider!
     @IBOutlet weak var btn_high: UIButton!
     @IBOutlet weak var btn_low: UIButton!
     @IBOutlet weak var filter_Vw: UIView!
    @IBOutlet weak var lbl_noRecord: UILabel!

    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_sort: UILabel!
    @IBOutlet weak var btn_apply: UIButton!
    
    @IBOutlet var recordNotFound : UILabel!
    @IBOutlet weak var img_search: UIImageView!

    var category: CategoryData! = nil
    var restaurant: RestaurantProfileData!
    var lastVCObj : String!
    
    private let repo = HomeRepository()
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var searchBa: SearchBar!
    var filterValues : (sort:String,min:CGFloat,max:CGFloat)?

    override func viewDidLoad() {
        nib = [TableViewCell.foodDetailTableViewCell.rawValue,TableViewCell.homeFooter.rawValue,TableViewCell.searchItemRestaurantCell.rawValue]
        slider.delegate = self
        localization()
        filterValues = ("",slider.minValue,slider.maxValue)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        getData { (sucees) in
        }
        speeechSerach()
    }
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBa.searchView.delegate = self
    }
    func localization() {
        lbl_noRecord.text  = "There is no item matching your search yet!".localized()
        lbl_sort.text  = "Sort".localized()
        btn_low.setTitle("Low".localized(), for: .normal)
        btn_high.setTitle("High".localized(), for: .normal)
        lbl_price.text = "Price".localized()
        btn_apply.setTitle("Apply Filter".localized(), for: .normal)
    }
    
    func speeechSerach(){
        self.searchBa.speechBtn.resultHandler = {
            self.searchBa.searchView.text = $1?.bestTranscription.formattedString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                var  param = [String:Any]()
                if self.lastVCObj == "cat"{
                     param = ["keyword": self.searchBa.searchView.text ?? "",
                              "category_id":self.category.id.description]
                }else  if self.lastVCObj == "cat"{
                     param = ["keyword": self.searchBa.searchView.text ?? ""]
                }else{
                     param = ["keyword": self.searchBa.searchView.text ?? ""]
                }
                if self.searchBa.searchView.text != ""{
                    self.repo.searchDishAPI(param) { (item) in
                        self.allItems = item.searchItem
                        self.currentItems = self.allItems
                        if self.allItems.count == 0 && self.currentItems.count == 0{
                            self.img_search.isHidden = false
                            self.lbl_noRecord.isHidden = false
                        }else{
                            self.img_search.isHidden = true
                            self.lbl_noRecord.isHidden = true
                        }
                        self.tableView.reloadData()
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          designFooter()
      }
    @objc private func refreshWeatherData(_ sender: Any) {
        getData(true){ (sucees) in
            self.refreshControl.endRefreshing()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
    }
    
    @objc override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
        self.tableView.reloadData()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
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
        
        
        var  param = [String:Any]()
        let searckText = self.searchBa.searchView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if self.lastVCObj == "cat"{
            param = ["keyword": searckText,
                     "category_id":self.category.id.description,
                     "sort_by":filterValues?.sort ?? "",
                     "max_price":filterValues?.max ?? 0.0,
                     "min_price":filterValues?.min ?? 0.0]
        }else  if self.lastVCObj == "cat"{
            param = ["keyword": searckText,
                     "sort_by":filterValues?.sort ?? "",
                    "max_price":filterValues?.max ?? 0.0,
                    "min_price":filterValues?.min ?? 0.0]
        }else{
            param = ["keyword": searckText,
                     "sort_by":filterValues?.sort ?? "",
                     "max_price":filterValues?.max ?? 0.0,
                     "min_price":filterValues?.min ?? 0.0]
        }
        
        self.filter_Vw.alpha = 0.0
        self.repo.searchDishAPI(param) { (item) in
            
            self.allItems = item.searchItem
            self.currentItems = self.allItems
            if self.allItems.count == 0 && self.currentItems.count == 0{
                self.img_search.isHidden = false
                self.lbl_noRecord.isHidden = false
            }else{
                self.img_search.isHidden = true
                self.lbl_noRecord.isHidden = true
            }
            self.tableView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == currentItems.count{
            return 0
        }else{
            return 290
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none

        if indexPath.row == currentItems.count{
//            if CurrentSession.getI().localData.cart.cartItems.count != 0{
//                    let footer = tableView.dequeueReusableCell(withIdentifier: nib[1]) as! HomeFooterTableViewCell
//                    footer.selectionStyle = .none
//                    footer.totalAmount()
//                    footer.tapOnButton = {
//                        self.tapOnCartButton()
//                    }
//
//                    return footer
//            }else{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            //}
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: nib[2]) as! SearchItemRestaurantCell
                       cell.data = self.currentItems[indexPath.row]
                       cell.tapOnCommentButton = { product,index in
                           if product.is_commentable == "yes"{
                               let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                            vc.hidesBottomBarWhenPushed = true

                               vc.producrtID = product
                               self.navigationController?.pushViewController(vc, animated: true)
                           }
                       }
                       cell.tapOnShareButton = { product,index in
                           self.generateShareProductLink(url: product.dish_images.last ?? "", productName: product.name ?? "", productID: product.id, restuarentID: product.restaurant_id?.id ?? 0)
                       }
                       cell.tapOnSelect = { product,index in
                           self.showProduct(product: product)
                       }
            
            
            
//            let c = super.tableView(tableView, cellForRowAt: indexPath) as! FoodDetailTableViewCell
            
//            DispatchQueue.main.async {
//                c.initView(withData: self.currentItems[indexPath.row])
//            }
            
//            c.tapOnLikeButton = {
//                print("tapOnLikeButton")
//                self.repo.postDishLike(self.currentItems[indexPath.row].id.toString()) { (data) in
//                    if c.likeBtn.isSelected{
//                        self.currentItems[indexPath.row].isLike = "no"
//                        self.currentItems[indexPath.row].totalLikes = self.currentItems[indexPath.row].totalLikes - 1
//                    }else{
//                        self.currentItems[indexPath.row].isLike = "yes"
//                        self.currentItems[indexPath.row].totalLikes = self.currentItems[indexPath.row].totalLikes + 1
//                    }
//                    c.likeBtn.isSelected = !c.likeBtn.isSelected
//                    c.likeCount.text = String(format: "%i ", self.currentItems[indexPath.row].totalLikes)
//                }
//            }
//
//            c.tapOnFavButton = {
//                print("tapOnFavButton")
//                self.repo.postDishFavourite(self.currentItems[indexPath.row].id.toString()) { (data) in
//                    if c.favBtn.isSelected{
//                        self.currentItems[indexPath.row].isFavourites = "no"
//                    }else{
//                        self.currentItems[indexPath.row].isFavourites = "yes"
//                    }
//                    c.favBtn.isSelected = !c.favBtn.isSelected
//                }
//            }
//
//            c.tapOnCommentButton = {
//                print("tapOnCommentButton")
//                if self.currentItems[indexPath.row].is_commentable == "yes"{
//                    let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
//                    vc.producrtID = self.currentItems[indexPath.row]
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            c.tapOnShareButton = {
//                self.generateShareProductLink(url: self.currentItems[indexPath.row].dish_images.last ?? "", productName: self.currentItems[indexPath.row].name ?? "", productID: self.currentItems[indexPath.row].id ?? 0, restuarentID: self.currentItems[indexPath.row].restaurant_id?.id ?? 0)
//            }
            return cell
        }
        
    }
    private func showProduct(product: ProductData) {
        showDetailOf(product: product, vc: self)
    }
    @IBAction func openCart(_ sender: Any) {

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
//        searchText  = textField.text?.trimmingCharacters(in: .whitespaces) as? String ?? ""
           print(searchText)
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
               if searchText == "" {
                    return
//                  guard self.currentItems != nil else { return }
//                  self.currentItems.removeAll()
//                   self.tableView.reloadData()
//                   self.allItems = []
               }else{
                let param = ["keyword": self.searchBa.searchView.text?.trimmingCharacters(in: .whitespaces) ?? ""]
                self.repo.searchDishAPI(param) { (item) in
                    self.allItems = item.searchItem
                    self.currentItems = self.allItems
                    if self.allItems.count == 0 && self.currentItems.count == 0{
                        self.img_search.isHidden = false
                        self.lbl_noRecord.isHidden = false
                    }else{
                        self.img_search.isHidden = true
                        self.lbl_noRecord.isHidden = true
                    }
                    self.tableView.reloadData()
                    self.tableView.reloadData()
                    self.tableView.reloadData()
                }
               }
           })
       }
       
       func textFieldShouldClear(_ textField: UITextField) -> Bool {
           updateFooter()
           return true
       }
       
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
}
extension FoodCategoryViewController{
    func getData(_ isRefresh:Bool = false,_ success:@escaping(Bool) -> Void)  {
        var tmpObj = GGSkeletonView()
        if isRefresh == false{
            tmpObj = tmpObj.createFoodCategorySkeletonView(viewObj: self.view) as! GGSkeletonView
        }
        
        if self.lastVCObj == "cat"{
            self.createNavigationLeftButton(NavigationTitleString.foodCategory.localized().uppercased())
            repo.getProductOf(categoryId: category.id.description, of: 0, limit: 10, page: 1) { (item) in
                self.allItems = item.products
                self.currentItems = self.allItems
                if self.allItems.count == 0 && self.currentItems.count == 0{
                    self.img_search.isHidden = false
                    self.lbl_noRecord.isHidden = false
                }else{
                    self.img_search.isHidden = true
                    self.lbl_noRecord.isHidden = true
                }
                self.tableView.reloadData()
                if isRefresh == false{
                    
                    tmpObj.stopFoodCategorySkeletonView(viewObj: tmpObj)
                }
                success(true)
            }
        }else if self.lastVCObj == "rec"{
            self.createNavigationLeftButton(NavigationTitleString.recommended.localized())
            repo.getAllRecommendedItem() { (item) in
                self.allItems = item.productsRec
                self.currentItems = self.allItems
                if self.allItems.count == 0 && self.currentItems.count == 0{
                    self.img_search.isHidden = false
                    self.lbl_noRecord.isHidden = false
                }else{
                    self.img_search.isHidden = true
                    self.lbl_noRecord.isHidden = true
                }
                self.tableView.reloadData()
                if isRefresh == false{
                    tmpObj.stopFoodCategorySkeletonView(viewObj: tmpObj)
                }
                success(true)
            }
        }else if self.lastVCObj == "topOrder"{
            self.createNavigationLeftButton(NavigationTitleString.topOrder.localized())
            repo.getAllToopOrder() { (item) in
                self.allItems = item.productsRec
                self.currentItems = self.allItems
                if self.allItems.count == 0 && self.currentItems.count == 0{
                    self.img_search.isHidden = false
                    self.lbl_noRecord.isHidden = false
                }else{
                    self.img_search.isHidden = true
                    self.lbl_noRecord.isHidden = true
                }
                self.tableView.reloadData()
                if isRefresh == false{
                    tmpObj.stopFoodCategorySkeletonView(viewObj: tmpObj)
                }
                success(true)
            }
        }
    }
}
// MARK: - RangeSeekSliderDelegate

extension FoodCategoryViewController: RangeSeekSliderDelegate {

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
