//
//  EditProfileViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 08/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import ImagePicker
import FlagPhoneNumber
import RSKImageCropper

class EditProfileViewController: BaseViewController<SignupData>, UITextFieldDelegate, FPNTextFieldDelegate, RSKImageCropViewControllerDelegate {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        controller.dismiss(animated: true) {
             self.imageSelected = true
            self.profilePicOutlet.image = croppedImage
        }
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        rightImage2.isHidden = !isValid
    }
    
    func fpnDisplayCountryList() {
        
    }
    
    
    @IBOutlet weak var lbl_upline: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var lbl_phone: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var firstPhNoView: UIView!
    @IBOutlet weak var secondPhNoView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var uplineView: UIView!
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var camerImageViewOutlet: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: FPNTextField!
    @IBOutlet weak var secondPnNoTextField: FPNTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var uplineCodeTextField: UITextField!
    @IBOutlet weak var updateBtnOutlet: UIButton!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightImage2: UIImageView!
    
    var imageSelected = false
    
    let repo = SettingRepository()
    var profile = CurrentSession.getI().localData.profile


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createNavigationLeftButton(NavigationTitleString.editProfile.localized().capitalized)
        settranslate()
        
        phoneNoTextField.flagButtonSize  = CGSize(width: 65, height: 20)
        phoneNoTextField.flagButton.isUserInteractionEnabled = false

        
        setNavigationTitleTextColor(NavigationTitleString.editProfile.localized().capitalized)
        secondPhNoView.isHidden = true
        
        secondPnNoTextField.delegate = self
        phoneNoTextField.delegate = self
        let data = self.data
        phoneNoTextField.text = data?.mobile
        rightImage2.isHidden = true
        rightImageView.isHidden = true
        
        
        if let _ = CurrentSession.getI().localData.token {
            self.setProfileData()
        }
        
    }
    
    
    
    func settranslate()  {
        lbl_upline.text = "Upline code".localized()
        lbl_email.text = "E-mail ( Optional )".localized()
        lbl_phone.text = "Phone number".localized()
        lbl_name.text = "Name".localized()
        updateBtnOutlet.setTitle("Update".localized().capitalized, for: .normal)
    }
    
    
    
    func onSave() {
        if nameTextField.text!.isEmpty {
            showAlert(msg: "Please Enter your phone number")
        }
    }
    
    
    @IBAction func updateBtnAction(_ sender: Any) {
        if nameTextField.text!.isEmpty {
            return showAlert(msg: "Please Enter name")
        }
        
        if !imageSelected {
            return showAlert(msg: "Please Select Image")
        }
        
        if !(emailTextField.text?.isEmpty ?? true) {
            if !self.isValidEmail(emailTextField.text ?? "") {
                 return showAlert(msg: "Please enter a valid email")
            }
        }
        
        repo.updateUserProfile(name: nameTextField.text!, phoneNumber: self.secondPnNoTextField.text!, image: (self.profilePicOutlet.image?.jpegData(compressionQuality: 0.5))!, userStatus: CurrentSession.getI().localData.profile?.user_status ?? "", email: self.emailTextField.text, uplineCode:self.uplineCodeTextField.text) { (data) in
            data.profile.user_status = "existing"
            CurrentSession.getI().localData.profile = data.profile
            CurrentSession.getI().saveData()
            self.onUpdateProfile()
        }
    }
    
    
    func onUpdateProfile() {
        let data = CurrentSession.getI().localData.profile
        
        #if Restaurant
        if  data?.userStatus == .addLocation {
            let c: AddAddressViewController = self.getViewController(.address, on: .map)
            self.navigationController?.pushViewController(c, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        #elseif Driver
        self.navigationController?.present(.driverTab, on: .main)
        #else
        self.navigationController?.popViewController(animated: true)
        
        #endif
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func setProfileData() {
        self.uplineCodeTextField.text = profile?.upline_code
        secondPnNoTextField.text = profile?.mobile1
        if let dp = profile?.profile_picture {
            ServerImageFetcher.i.loadImageIn(profilePicOutlet, url: dp)
            self.imageSelected = true
        }
        nameTextField.text = profile?.name?.capitalized
        let number = (profile?.country_code ?? "") + (profile?.mobile ?? "")
        phoneNoTextField.text = format(with: "+XX (XXX) XXX-XXXX", phone: number)
        phoneNoTextField.set(phoneNumber: number)
        rightImageView.isHidden = false
        emailTextField.text = profile?.email
        uplineCodeTextField.text = profile?.upline_code
        emailTextField.text = profile?.email
        self.uplineCodeTextField.isUserInteractionEnabled = false
    }
    
}

extension EditProfileViewController: ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let image = images.first{
            imagePicker.dismiss(animated: true) {
                let imageCropVC = RSKImageCropViewController(image: image)
                imageCropVC.delegate = self
                self.present(imageCropVC, animated: true, completion: nil)
               
            }
        }

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    /// mask example: `+X (XXX) XXX-XXXX`
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}


