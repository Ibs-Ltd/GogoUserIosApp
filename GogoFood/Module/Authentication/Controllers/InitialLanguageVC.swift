//
//  InitialLanguageVC.swift
//  User
//
//  Created by Apple on 23/08/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import Localize_Swift
class ChangeInitialLanguageCellClass: UITableViewCell {
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var selectBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        selectBtnOutlet.layer.cornerRadius = selectBtnOutlet.frame.height / 2
        selectBtnOutlet.layer.borderColor = UIColor.red.cgColor
        selectBtnOutlet.layer.borderWidth = 0.8
    }
}

class InitialLanguageVC: UIViewController {
    var countryArray: [String]!
    var flagCountryArray: [String]!
    var isSelected: Int!
    private var selectedLanguage = ""
    @IBOutlet weak var languageTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        languageTableView.delegate = self
        languageTableView.dataSource = self
        languageTableView.separatorColor = .black
        isSelected = 1
        selectedLanguage = "en"
        countryArray = ["ខ្មែរ", "English", "中文"]
        flagCountryArray = ["khmer-flag", "english-flag", "chinese-flag"]
        languageTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    func showLoginScreen() {
        self.performSegue(withIdentifier: "start", sender: self)
    }
    
    

    //MARK:- IBAction Method(s)
    @IBAction func nextBtnAction(_ sender: UIButton) {
        UserDefaults.standard.set("yes", forKey: "firstTime")
        UserDefaults.standard.set(selectedLanguage, forKey: "savedLang")
        Localize.setCurrentLanguage(selectedLanguage)
        if let user = CurrentSession.getI().localData.profile {
            if (user.userStatus ?? .exsisting) == .exsisting {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: Controller.userTab.rawValue)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else{
                showLoginScreen()
            }
        }else{
            showLoginScreen()
        }
    }
    

}


extension InitialLanguageVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = languageTableView.dequeueReusableCell(withIdentifier: "cell") as! ChangeInitialLanguageCellClass
        cell.countryNameLabel.text = countryArray[indexPath.row]
        cell.imageViewOutlet.image = UIImage(named: flagCountryArray[indexPath.row])
        if isSelected == indexPath.row {
            cell.selectBtnOutlet.setImage(UIImage(named: "circle"), for: .normal)
            cell.selectBtnOutlet.center = .zero
            cell.selectBtnOutlet.imageView?.contentMode = .scaleAspectFit
            cell.selectBtnOutlet.setTitle("", for: UIControl.State.normal)
        } else {
            cell.selectBtnOutlet.setImage(nil, for: .normal)
        }
        cell.selectBtnOutlet.tag = indexPath.row
        cell.selectBtnOutlet.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @objc func selectImage(sender: UIButton) {
        isSelected = sender.tag
        selectLanguage(sender: sender)
        languageTableView.reloadData()
    }
    
    private func selectLanguage(sender: UIButton){
        switch sender.tag {
        case 0:
            self.selectedLanguage = "km"
        case 1:
            self.selectedLanguage = "en"
        case 2:
            self.selectedLanguage = "zh"
        default:
            break;
        }
    }
}
