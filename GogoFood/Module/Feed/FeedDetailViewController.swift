//
//  FeedDetailViewController.swift
//  Restaurant
//
//  Created by MAC on 22/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class FeedDetailViewController: BaseTableViewController<BaseData>,UIGestureRecognizerDelegate{

    @IBOutlet weak var commentTxt: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    private let repo = OrderRepository()
   
    var isEditComment : Bool!
    var editedCommentStr : String!
    var commentListArray : [CommentList]!
    var producrtID : ProductData!
    
    var comments = [CommentList]()
    //Notification redirect
    
    var noti: (dishID:Int,isFromNoti:Bool) = (0,false)

    override func viewDidLoad() {
        nib = [TableViewCell.foodDetailTableViewCell.rawValue,
               TableViewCell.commentTableViewCell.rawValue,TableViewCell.restuarentComment.rawValue]
        
        super.viewDidLoad()
        
        self.isEditComment = false
        setNavigationTitleTextColor(NavigationTitleString.comment)
        //addCartButton()
        self.createNavigationLeftButton("Write Comment".localized())
        self.tableView.tableFooterView = UIView()
        ServerImageFetcher.i.loadProfileImageIn(userImage, url: CurrentSession.getI().localData.profile.profile_picture ?? "")
        self.callCommentListAPI()
        setupLongPressGesture()
        // Do any additional setup after loading the view.
    }
    //MARK:: View will Appear
    

    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)

          NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: Notification.Name.dishCommnets, object: nil)
      }
      @objc func notificationReceived(_ notification: Notification) {
          callCommentListAPI()
      }
    
    @objc override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
        self.tableView.reloadData()
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    //MARK:: Longpress Gesture
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                if indexPath.row % 2 == 0{
                    let confirmationAlert = UIAlertController(title: "", message: "Choose your option!", preferredStyle: .actionSheet)
                    confirmationAlert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
                        print("Edit")
                        self.editedCommentStr = (self.comments[indexPath.row].cid?.toString())!
                        self.isEditComment = true
                        self.commentTxt.text = self.comments[indexPath.row].userComment
                        self.commentTxt.becomeFirstResponder()
                    }))
                    confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        print("Delete")
                        self.repo.deleteCommentList((self.comments[indexPath.row].cid?.toString())!) { (data) in
                            self.callCommentListAPI()
                        }
                    }))
                    confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(confirmationAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func callCommentListAPI() {
        
        let dishID = noti.isFromNoti == true ? noti.dishID.toString() : self.producrtID.id.toString()
        
        repo.GetItemCommentList(dishID) { (data) in
            self.noti.isFromNoti = false
            self.commentListArray = data.commentList
            self.comments = []
            for (_,value) in self.commentListArray.enumerated(){
                    
                    self.comments.append(value)
                    self.comments.append(value)
            }
            self.producrtID = data.productData
            self.tableView.reloadData()
            print(data)
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        if self.commentTxt.text == ""{
            self.showError("Please write your comment!")
        }else{
            if self.isEditComment{
                repo.editCommentList(self.editedCommentStr, commentStr: self.commentTxt.text!) { (data) in
                    self.commentTxt.text = ""
                    self.callCommentListAPI()
                    self.isEditComment = false
                }
                
            }else{
                repo.addCommentList(self.producrtID.id.toString(), restID: (self.producrtID.restaurant_id?.id.toString())!, commentStr: self.commentTxt.text!) { (data) in
                    self.commentTxt.text = ""
                    self.callCommentListAPI()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if noti.isFromNoti{
            return 0
        }else{
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.comments.count == nil{
                return 0
            }
            return self.comments.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if  indexPath.row % 2 == 1 {
                if self.comments[indexPath.row].restaurant_comment == nil{
                    return 0
                }else{
                    return UITableView.automaticDimension
                }
                
            }else{
                return UITableView.automaticDimension
            }
        }
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        if indexPath.section == 1 {
            if  indexPath.row % 2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: nib[2]) as! RestuarentComment
                cell.selectionStyle = .none
                cell.restuarentnameLbl.text = self.comments[indexPath.row].restaurant_id2?.name?.capitalized
                cell.restuarentCommentLbl.text = self.comments[indexPath.row].restaurant_comment ?? ""
                ServerImageFetcher.i.loadProfileImageIn(cell.restuarentImage, url: self.comments[indexPath.row].restaurant_id2?.profile_picture ?? "")
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: nib[1]) as! CommentTableViewCell
                cell.selectionStyle = .none
                ServerImageFetcher.i.loadProfileImageIn(cell.userImage, url: self.comments[indexPath.row].userId?.profilePicture ?? "")
                cell.usernameLbl.text = self.comments[indexPath.row].userId?.name
                cell.commentLbl.text = self.comments[indexPath.row].userComment
                let currentUserID = CurrentSession.getI().localData.profile.name ?? ""
                
                if currentUserID == self.comments[indexPath.row].userId?.name{
                    cell.btn_more.isHidden = false
                }else{
                    cell.btn_more.isHidden = true
                }
                
                
                cell.tapOnMoreButton = {
                    let confirmationAlert = UIAlertController(title: "", message: "Choose your option!", preferredStyle: .actionSheet)
                    confirmationAlert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
                        print("Edit")
                        self.editedCommentStr = (self.comments[indexPath.row].cid?.toString())!
                        self.isEditComment = true
                        self.commentTxt.text = self.comments[indexPath.row].userComment
                        self.commentTxt.becomeFirstResponder()
                    }))
                    confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        print("Delete")
                        self.repo.deleteCommentList((self.comments[indexPath.row].cid?.toString())!) { (data) in
                            self.callCommentListAPI()
                        }
                    }))
                    confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(confirmationAlert, animated: true, completion: nil)
                }
                return cell
            }
        }else{
        let c =  tableView.dequeueReusableCell(withIdentifier: nib[0], for: indexPath) as! FoodDetailTableViewCell
        c.initView(withData: self.producrtID)
        c.likeView.isHidden = true
        return c
        }
    }
}



struct CommentsModal {
    var name :String!
    var image:String!
    var comment:String!
    var isUser = true
    
    init(name:String,image:String,comment:String,isUser:Bool) {
        self.name = name
        self.image = image
        self.comment = comment
        self.isUser = isUser
    }
}

//Protocal that copyable class should conform
protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}
//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
