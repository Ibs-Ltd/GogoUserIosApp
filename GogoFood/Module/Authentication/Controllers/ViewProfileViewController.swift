//
//  ViewProfileViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 08/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import ImagePicker
import RSKImageCropper
 import FlagPhoneNumber


class ViewProfileViewController: BaseViewController<ProfileData> {

    @IBOutlet weak var lbl_name: UILabel!
    
    @IBOutlet weak var lbl_phone: UILabel!
    
    @IBOutlet weak var lbl_upline: UILabel!
    
    @IBOutlet weak var lbl_email: UILabel!
    
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var nameTextFieldOutlet: UITextField!
    @IBOutlet weak var phoneNoTextFieldOutlet: FPNTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var uplineCodeTextField: UITextField!
    
    @IBOutlet weak var saveBtnOutlet: UIButton!
    
    var imageSelected = false
    private let repo = SettingRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

         lbl_upline.text = "Upline code".localized()
         lbl_email.text = "E-mail ( Optional )".localized()
         lbl_phone.text = "Phone number".localized()
         lbl_name.text = "Name".localized()
         saveBtnOutlet.setTitle("SAVE".localized().capitalized, for: .normal)
        
        
        saveBtnOutlet.layer.cornerRadius = saveBtnOutlet.frame.height / 2
        profilePicOutlet.layer.cornerRadius = profilePicOutlet.frame.height / 2
        profilePicOutlet.layer.borderWidth = 1.0
        profilePicOutlet.layer.borderColor = UIColor.lightGray.cgColor
      

        nameTextFieldOutlet.layer.borderWidth = 1.0
        nameTextFieldOutlet.layer.cornerRadius = nameTextFieldOutlet.frame.height / 2

        self.phoneNoTextFieldOutlet.text = self.data?.mobile
        self.nameTextFieldOutlet.text = self.data?.name
        self.uplineCodeTextField.text = UserDefaults.standard.value(forKey: "referalcode") as? String ?? ""

        
        if let i = self.data?.profile_picture {
            ServerImageFetcher.i.loadProfileImageIn(profilePicOutlet
                , url: i)
            imageSelected = true
        }
        createNavigationLeftButton("Profile".localized())
        phoneNoTextFieldOutlet.flagButtonSize  = CGSize(width: 65, height: 20)
        phoneNoTextFieldOutlet.flagButton.isUserInteractionEnabled = false
        let number = (self.data?.country_code ?? "") + (self.data?.mobile ?? "")
        phoneNoTextFieldOutlet.set(phoneNumber: number)
    }

    
    
    
    
    @IBAction func saveBtnAction(_ sender: Any) {
//        if !imageSelected {
//          //  showAlert(msg: "Please Select your image")
//
//        }else
        if nameTextFieldOutlet.text!.isEmpty {
            showAlert(msg: "Please Enter your name")
            
        }else{
            repo.updateUserProfile(name: nameTextFieldOutlet.text!, phoneNumber: nil, image: (self.profilePicOutlet.image?.jpegData(compressionQuality: 0.5)!)!, userStatus: data?.user_status ?? "", email: self.emailTextField.text, uplineCode:self.uplineCodeTextField.text) { (data) in
                    data.profile.user_status = "existing"
                    CurrentSession.getI().localData.profile = data.profile
                    CurrentSession.getI().saveData()
                    self.navigationController?.present(.userTab, on: .main)
            }
        }
       
        
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visibleNavigationBar()
    }
    
}

extension ViewProfileViewController: ImagePickerDelegate, RSKImageCropViewControllerDelegate{
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        profilePicOutlet.image = croppedImage
        controller.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let image = images.first{
            imagePicker.dismiss(animated: true) {
                let imageCropVC = RSKImageCropViewController(image: image)
                imageCropVC.delegate = self
                self.present(imageCropVC, animated: true, completion: nil)
                self.imageSelected = true
            }
          
        }
        
       
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

}
