//
//  LoginVC.swift
//  DinedooRestaurant
//
//  Created by Administrator on 20/02/18.
//  Copyright © 2018 casperonIOS. All rights reserved.
//

import UIKit

class LoginVC: UIViewController{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!

    var mainTheme:Themes = Themes()

    override func viewDidLoad(){
        super.viewDidLoad()
        self.updateUI()
    }
    //MARK:- Update UI
    func updateUI(){
        emailTxt.text = "krithunga_gachibowli@gmail.com"
        passwordTxt.text = "Krithunga@1234"
        emailTxt.placeholderColor("Email", color: .placeholderColor)
        passwordTxt.placeholderColor("Password", color: .placeholderColor)
    }
    @objc func movoToHome() {
        (UIApplication.shared.delegate as! AppDelegate).SetInitialViewController()
    }
    public func isStrongPassword(password : String) -> Bool{
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`’]{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    //MARK:- Login Api Hitting
    func LoginWebHit(){
        Themes.sharedInstance.activityView(View: self.view)
        let param = ["emailId": emailTxt.text!,
                               "password": passwordTxt.text!,
                               "through": "MOBILE"] 
        
        URLhandler.postUrlSession(urlString: Constants.urls.loginURL, params: param as [String : AnyObject], header: [:]) { (dataResponse) in
            print("Response login ----->>> ", dataResponse.json)
            Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                GlobalClass.restaurantLoginModel = RestaurantLoginModel.init(fromJson: dataResponse.json)
                UserDefaults.standard.set(dataResponse.dictionaryFromJson, forKey: "restaurantInfo")
                self.movoToHome()
            }
        }
    }
    //MARK:- IB Action Outlets
    @IBAction func ActionForgotPassword(_ sender: Any){
        let viewCon = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC")as? ForgotPasswordVC
        self.present(viewCon!, animated: true, completion: nil)
    }
    @IBAction func ActionLogin(_ sender: Any){
        if Utilities().trimString(string: self.emailTxt.text!)  == ""{
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.Email_Address_Is_Empty)
        }else if  !Utilities().isValidEmail(testStr: self.emailTxt.text!){
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.Invalid_Email)
        }else if Utilities().trimString(string: self.passwordTxt.text!) == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.password_empty)
        }else{
            self.LoginWebHit()
        }
    }
}
