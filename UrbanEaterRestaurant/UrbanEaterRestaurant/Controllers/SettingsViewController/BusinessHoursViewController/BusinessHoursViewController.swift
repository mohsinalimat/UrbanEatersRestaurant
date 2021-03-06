//
//  BusinessHoursViewController.swift
//  DinedooRestaurant
//
//  Created by Nagaraju on 24/10/18.
//  Copyright © 2018 casperonIOS. All rights reserved.
//

import UIKit

class BusinessHoursViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var weekDaysView: UIView!
    @IBOutlet weak var weekEndsView: UIView!
    @IBOutlet weak var dateView1: UIView!
    @IBOutlet weak var dateView2: UIView!
    @IBOutlet weak var dateView3: UIView!
    @IBOutlet weak var dateView4: UIView!
    @IBOutlet weak var minutesBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var minutesBgView: ShadowView!
    @IBOutlet weak var minLbl: UILabel!
    
    @IBOutlet weak var weekDayFromLbl: UILabel!
    @IBOutlet weak var weekDayToLbl: UILabel!
    @IBOutlet weak var weekEndFromLbl: UILabel!
    @IBOutlet weak var weekEndToLbl: UILabel!
    
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var minutesPicker: UIPickerView!
    @IBOutlet weak var minutesContainerView: UIView!
    
    var btnTag = 0
    var gradePickerValues = [String]()
    var dateSelectedString = ""
    var minutesSelectedString = ""
    let dateFormatter = DateFormatter()
    var commonUtlity:Utilities = Utilities()
    var businessHoursParams:BusinessHourParameters!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 0 ..< 10
        for i in 0..<60 {
            gradePickerValues.append(String(i))
        }

        weekDaysView.layer.cornerRadius = 5.0
        weekEndsView.layer.cornerRadius = 5.0
        
        dateView1.customiseView()
        dateView2.customiseView()
        dateView3.customiseView()
        dateView4.customiseView()
        
        TheGlobalPoolManager.cornerAndBorder(saveBtn, cornerRadius: 5, borderWidth: 0, borderColor: .clear)
        TheGlobalPoolManager.cornerAndBorder(minutesBgView, cornerRadius: minutesBgView.layer.bounds.h/2, borderWidth: 0, borderColor: .clear)
        datePicker.datePickerMode = UIDatePickerMode.time
        dateFormatter.dateFormat = "HH:mm a"
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        minutesPicker.dataSource = self
        minutesPicker.delegate = self
        
        if let _ = GlobalClass.restModel {
            updateUI()
        }else{
             getRestarentProfile()
        }
    }
    func getRestarentProfile(){
        Themes.sharedInstance.activityView(View: self.view)
        let param = [ "id": GlobalClass.restaurantLoginModel.data.subId!]
        URLhandler.postUrlSession(urlString: Constants.urls.getRestaurantDataURL, params: param as [String : AnyObject], header: [:]) { (dataResponse) in
             Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                GlobalClass.restModel = RestaurantHomeModel(fromJson: dataResponse.json)
                self.updateUI()
            }
        }
    }
    func updateUI(){
        self.weekDayFromLbl.text = GlobalClass.restModel.data.timings.weekDay.startAt!
        self.weekDayToLbl.text = GlobalClass.restModel.data.timings.weekDay.endAt!
        self.weekEndFromLbl.text = GlobalClass.restModel.data.timings.weekEnd.startAt!
        self.weekEndToLbl.text = GlobalClass.restModel.data.timings.weekEnd.endAt!
        minutesSelectedString = String(GlobalClass.restModel.data.deliveryTime!)
        self.minLbl.text = "\(minutesSelectedString) min"
    }
    
    func validateInputs(){
        let delivaryTime = minutesBtn.titleLabel?.text
        if Utilities().trimString(string: self.weekDayFromLbl.text!) == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.WEEKDAY_START_TIME_EMPTY)
        }else if Utilities().trimString(string: self.weekDayToLbl.text!) == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.WEEKDAY_END_TIME_EMPTY)
        }else if Utilities().trimString(string: self.weekEndFromLbl.text!) == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.WEEKEND_START_TIME_EMPTY)
        }else if Utilities().trimString(string: self.weekEndToLbl.text!) == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.WEEKEND_END_TIME_EMPTY)
        }else if delivaryTime == "" {
            Themes.sharedInstance.shownotificationBanner(Msg: ToastMessages.DELIVARY_TIME_EMPTY)
        }
        else{
            updateBusinessHoursWebHit()
        }
    }
    func updateBusinessHoursWebHit(){
        Themes.sharedInstance.activityView(View: self.view)
        let restarentInfo = UserDefaults.standard.object(forKey: "restaurantInfo") as! NSDictionary
        let data = restarentInfo.object(forKey: "data") as! NSDictionary
        self.businessHoursParams = BusinessHourParameters.init(data.object(forKey: "subId") as! String, deliveryTime: Int(minutesSelectedString)!, weekday_startAt: weekDayFromLbl.text!, weekday_endAt: weekDayToLbl.text!, weekend_startAt: weekEndFromLbl.text!, weekend_endAt: weekEndToLbl.text!)
        URLhandler.postUrlSession(urlString: Constants.urls.businessHourUrl, params: self.businessHoursParams.parameters, header: [:]) { (dataResponse) in
            print("Response ----->>> ", dataResponse.json)
            Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                let dict = dataResponse.dictionaryFromJson! as NSDictionary
                Themes.sharedInstance.showToastView(dict.object(forKey: "message") as! String)
                self.getRestarentProfile()
            }
        }
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        sender.locale = Locale(identifier: "en_GB")
        sender.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateSelectedString = dateFormatter.string(from: sender.date)
        print("dateSelectedString ---->>> \(dateSelectedString)")
    }
    
    @IBAction func timeChangeBtnClicked(_ sender: UIButton) {
        btnTag = sender.tag
        dateContainerView.isHidden = false
        blurView.isHidden = false
    }
    
    @IBAction func datePickDoneClicked(_ sender: Any) {
        dateContainerView.isHidden = true
        blurView.isHidden = true
        let date = Date()
        if dateSelectedString.count == 0 {
            dateSelectedString =  dateFormatter.string(from: date)
        }
        
        dateSelectedString = commonUtlity.removeMeridiansfromTime(string: dateSelectedString)
        dateSelectedString = commonUtlity.trimString(string: dateSelectedString)

        if btnTag == 1 {
            weekDayFromLbl.text = dateSelectedString
            weekDayFromLbl.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }else if btnTag == 2 {
            weekDayToLbl.text = dateSelectedString
            weekDayToLbl.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }else if btnTag == 3 {
            weekEndFromLbl.text = dateSelectedString
            weekEndFromLbl.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }else if btnTag == 4 {
            weekEndToLbl.text = dateSelectedString
            weekEndToLbl.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        dateSelectedString = ""
    }
    
    @IBAction func datePickCancelClicked(_ sender: Any) {
        blurView.isHidden = true
        dateContainerView.isHidden = true
    }
    
    @IBAction func minutesBtnClicked(_ sender: Any) {
        minutesContainerView.isHidden = false
        blurView.isHidden = false
    }
    
    @IBAction func minutesPickDoneClicked(_ sender: Any) {
        minutesContainerView.isHidden = true
        blurView.isHidden = true
        if (minutesSelectedString ).isEmpty {
            minutesSelectedString =  "0"
        }
        self.minLbl.text = "\(minutesSelectedString) min"
    }
    
    @IBAction func minutesPickCancelClicked(_ sender: Any) {
        minutesContainerView.isHidden = true
        blurView.isHidden = true
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        validateInputs()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return gradePickerValues.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gradePickerValues[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        minutesSelectedString = gradePickerValues[row]
        self.view.endEditing(true)
    }
}

extension UIView {
    func customiseView(){
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.2509803922, green: 0.2901960784, blue: 0.4078431373, alpha: 0.5)
        self.clipsToBounds = true
    }
}

class BusinessHourParameters{
    var id:String!
    var deliveryTime:Int!
    
    var parameters = [String:AnyObject]()
    var timings = [String:AnyObject]()
    
    init(_ id:String, deliveryTime:Int, weekday_startAt:String, weekday_endAt:String, weekend_startAt:String, weekend_endAt:String) {
        self.id = id
        self.deliveryTime = deliveryTime
        self.timings[GlobalClass.KEY_WEEKDAY] = [
            GlobalClass.KEY_STARTAT:weekday_startAt,
            GlobalClass.KEY_ENDAT:weekday_endAt,
            GlobalClass.KEY_STATUS:"1"
            ] as AnyObject
        
        self.timings[GlobalClass.KEY_WEEKEND] = [
            GlobalClass.KEY_STARTAT:weekend_startAt,
            GlobalClass.KEY_ENDAT:weekend_endAt,
            GlobalClass.KEY_STATUS:"1"
            ] as AnyObject
        
        parameters = [GlobalClass.KEY_TIMINGS:self.timings,
                      GlobalClass.KEY_ID:self.id,
                      GlobalClass.KEY_DELIVERYTIME:self.deliveryTime] as [String : AnyObject]
    }
}
