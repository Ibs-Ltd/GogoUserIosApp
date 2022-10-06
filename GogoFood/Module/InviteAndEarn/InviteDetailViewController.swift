//
//  InviteeDetailViewController.swift
//  GogoFood
//
//  Created by MAC on 30/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import SBCardPopup

class InviteDetailViewController: BaseTableViewController<BaseData> {
    @IBOutlet weak var lbl_totalInvite: UILabel!
    @IBOutlet weak var lbl_totalEarn: UILabel!
    
    @IBOutlet weak var lbl_current: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var enviteLbl: UILabel!
    @IBOutlet weak var earnLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    private let repo = MapRepository()
    
    var currentUser : CurrentUser!
    var levelListArray : [LevelList]!
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_totalInvite.text = "Total Invitee".localized()
        lbl_totalEarn.text = "Total Earn".localized()
        lbl_current.text = "Current balance".localized()

        self.tableView.tableFooterView = UIView()
        createNavigationLeftButton(NavigationTitleString.inviteDetail.localized())
        ServerImageFetcher.i.loadProfileImageIn(profileImage, url: CurrentSession.getI().localData.profile.profile_picture ?? "")
        
        let rightBtn = UIBarButtonItem(image: UIImage(named: "share"), style: .plain, target: self, action: #selector(onClickMethod))
        self.navigationItem.rightBarButtonItem = rightBtn
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)

        self.callRefferListAPI()
        
    }
    @objc private func refreshWeatherData(_ sender: Any) {
        callRefferListAPI()
    }
    
    func callRefferListAPI(){
        self.repo.referalDetailsListAPI() { (data) in
            print(data)
            self.levelListArray = data.levelList
            self.currentUser = data.currentUser
            self.tableView.reloadData()
            self.enviteLbl.text = data.currentUser?.totalInvited?.toString()
            self.earnLbl.text = String(format: "$ %.2f", (data.currentUser?.totalIncome)!)
            self.balanceLbl.text = String(format: "$ %.2f", (data.currentUser?.userDetail!.referalIncome)!+(data.currentUser?.userDetail!.rewards)!)
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func onClickMethod() {
        let popupContent = AddAmountViewController.create(vcOBj:self)
        let cardPopup = SBCardPopupViewController(contentViewController: popupContent)
        cardPopup.show(onViewController: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.levelListArray != nil{
            return self.levelListArray.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notiCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LevelListTableViewCell
        notiCell.levelLbl.text = "\("Level".localized()) \n" + (self.levelListArray[indexPath.row].level?.toString())!
        notiCell.invitedLbl.text = "\("Invited".localized()) : " + (self.levelListArray[indexPath.row].invited?.toString())!
        notiCell.earnLbl.text = "\("Earned".localized()) : " + (self.levelListArray[indexPath.row].earned?.toString())!
        notiCell.selectionStyle = .none
        return notiCell
    }

    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.levelListArray[indexPath.row].invited != 0{
            let vcObj = self.storyboard?.instantiateViewController(withIdentifier: "InviteListViewController") as! InviteListViewController
            vcObj.levelStr = self.levelListArray[indexPath.row].level?.toString()
            self.navigationController?.pushViewController(vcObj, animated: true)
        }
    }
}

class LevelListTableViewCell: UITableViewCell {
    
    @IBOutlet var levelLbl : UILabel!
    @IBOutlet var invitedLbl : UILabel!
    @IBOutlet var earnLbl : UILabel!
    
    
    @IBOutlet var lbl_level : UILabel!
      @IBOutlet var Lbl_invited : UILabel!
      @IBOutlet var Lbl_earn : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
