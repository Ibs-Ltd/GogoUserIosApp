//
//  SearchViewController.swift
//  GogoFood
//
//  Created by MAC on 19/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import SpeechRecognizerButton

class SearchViewController: BaseTableViewController<HomeData>, UITextFieldDelegate {
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_sort: UILabel!
    @IBOutlet weak var btn_apply: UIButton!

    @IBOutlet weak var lbl_noRecord: UILabel!
    @IBOutlet weak var img_search: UIImageView!
    @IBOutlet weak var slider: RangeSeekSlider!
    @IBOutlet weak var btn_high: UIButton!
    @IBOutlet weak var btn_low: UIButton!
    @IBOutlet weak var filter_Vw: UIView!
    @IBOutlet weak var searchBa: SearchBar!
    private let repo = HomeRepository()
    var dishesArray: [ProductData] = []
    var resturent: [RestaurantProfileData] = []
    var filterValues : (sort:String,min:CGFloat,max:CGFloat)?
    override func viewDidLoad() {
        slider.delegate = self
        filterValues = ("",slider.minValue,slider.maxValue)
        nib = [TableViewCell.listItemTableViewCell.rawValue,
               TableViewCell.recommendation.rawValue,
               TableViewCell.homeFooter.rawValue,TableViewCell.restrauntCollectionTableViewCell.rawValue,
               TableViewCell.searchItemRestaurantCell.rawValue,TableViewCell.restaurantSearchItemTableViewCell.rawValue,

]
        super.viewDidLoad()
        localization()
        createNavigationLeftButton(NavigationTitleString.search.localized())
        self.searchBa.speechBtn.resultHandler = {
            self.searchBa.searchView.text = $1?.bestTranscription.formattedString
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let param = ["keyword": self.searchBa.searchView.text ?? ""]
                if self.searchBa.searchView.text != ""{
                    self.repo.searchDishAPI(param) { (data) in
                        self.dishesArray = data.searchItem
                        self.resturent =  data.resaturant
                        
                        if self.dishesArray.count == 0 &&  self.resturent.count == 0 {
                            self.img_search.isHidden = false
                            self.lbl_noRecord.isHidden = false
                        }else{
                            self.img_search.isHidden = true
                            self.lbl_noRecord.isHidden = true
                        }                        
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func localization() {
        lbl_noRecord.text  = "There is no item matching your search yet!".localized()
        lbl_sort.text  = "Sort".localized()
        btn_low.setTitle("Low".localized(), for: .normal)
        btn_high.setTitle("High".localized(), for: .normal)
        lbl_price.text = "Price".localized()
        btn_apply.setTitle("Apply Filter".localized(), for: .normal)
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.img_search.isHidden = true
        self.lbl_noRecord.isHidden = true
        designFooter()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBa.searchView.delegate = self
        self.searchBa.searchView.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
            updateFooter()
    }
    deinit {
           NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
      }
    @objc override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
        self.tableView.reloadData()
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
        let param = ["keyword": self.searchBa.searchView.text ?? "",
                     "sort_by":filterValues?.sort ?? "",
                     "max_price":filterValues?.max ?? 0.0,
                     "min_price":filterValues?.min ?? 0.0] as [String : Any]
        self.filter_Vw.alpha = 0.0
        self.repo.searchDishAPI(param) { (data) in
            self.resturent = []
            self.dishesArray = data.searchItem
            self.resturent =  data.resaturant
            if self.dishesArray.count == 0 &&  self.resturent.count == 0 {
                self.img_search.isHidden = false
                self.lbl_noRecord.isHidden = false
            }else{
                self.img_search.isHidden = true
                self.lbl_noRecord.isHidden = true
            }
            self.tableView.reloadData()
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
            if searchText == ""{
               guard self.dishesArray != nil else { return }
               self.dishesArray.removeAll()
                self.resturent = []
                self.tableView.reloadData()
                
            }else{
                let param = ["keyword": self.searchBa.searchView.text ?? ""]
                self.repo.searchDishAPI(param) { (data) in
                    self.resturent = []
                    self.dishesArray = data.searchItem
                    self.resturent =  data.resaturant
                    if self.dishesArray.count == 0 &&  self.resturent.count == 0 {
                        self.img_search.isHidden = false
                        self.lbl_noRecord.isHidden = false
                    }else{
                        self.img_search.isHidden = true
                        self.lbl_noRecord.isHidden = true
                    }
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.dishesArray != nil{
            self.dishesArray.removeAll()
            self.resturent = []
            self.img_search.isHidden = false
            self.tableView.reloadData()
        }
        updateFooter()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw =  UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let lbl = UILabel.init(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 30))
        vw.backgroundColor = .white
        if section == 0 {
            lbl.text = self.resturent.count > 0 ?  "Restaurant".localized() : ""
        }else{
            lbl.text = self.dishesArray.count > 0 ?  "Dishes".localized() : ""
        }
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        vw.addSubview(lbl)
        return vw
    }
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return self.resturent.count > 0 ? 40.0 : 0.0
        }else{
           return self.dishesArray.count > 0 ? 40.0 : 0.0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return CGFloat(290 * self.resturent.count)
        }else{
            let count = (Double(self.dishesArray.count)/2)
            if count > 0 {
                return 290
            }else{
                return 0
            }
        }
        
//        return  indexPath.section == 1 ? 100 : 180
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            if self.resturent.count > 0{
                return 1
            }else{
                return 0
            }
        }else{
            return self.dishesArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nib[5]) as! RestaurantSearchItemTableViewCell
            cell.data = self.resturent
            cell.selectionStyle =  .none
            cell.onTapSingleResraunt = { (Obj) in
                let vc: StoreInformationViewController = self.getViewController(.storeInformation, on: .home)
                vc.hidesBottomBarWhenPushed = true
                let data = StoreInfomationData()
                data.restaurant = Obj
                vc.data = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nib[4]) as! SearchItemRestaurantCell
            cell.data = self.dishesArray[indexPath.row]
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
            cell.tapOnSelect = { product,index in
                self.showProduct(product: product)
            }
            
            if let _ = data{
                cell.tapOnSelect = { product,index in
                    self.showProduct(product: product)
                }
                cell.selectProduct = { item in
                    showDetailOf(product: item, vc: self)
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
                
                cell.onTapAll = {
                    let vc: FoodCategoryViewController = self.getViewController(.foodCategory, on: .home)
                    vc.lastVCObj = "topOrder"
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            return cell
        }
    }
    private func showProduct(product: ProductData) {
        showDetailOf(product: product, vc: self)
    }
}

// MARK: - RangeSeekSliderDelegate

extension SearchViewController: RangeSeekSliderDelegate {

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
