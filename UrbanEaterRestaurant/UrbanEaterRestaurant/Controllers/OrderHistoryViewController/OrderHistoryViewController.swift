//
//  OrderHistoryViewController.swift
//  DinedooRestaurant
//
//  Created by Nagaraju on 23/10/18.
//  Copyright © 2018 casperonIOS. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderHistoryViewController: UIViewController {

    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var totalOrdersLbl: UILabel!
    @IBOutlet weak var totalEarningsLbl: UILabel!
    @IBOutlet weak var exportBtn: UIButton!
    @IBOutlet weak var orderHistoryTbl: UITableView!
    var collapaseHandlerArray = [String]()
    var fromDateString : String!
    var toDateString : String!
    var dateSelectedString : String!
    var isFromDateSelected = false
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName:"OrderHistoryTableViewCell" , bundle: nil)
        orderHistoryTbl.register(nibName, forCellReuseIdentifier: "OrderHistoryTableViewCell")
        let nibName1 = UINib(nibName:"ItemsCell" , bundle: nil)
        orderHistoryTbl.register(nibName1, forCellReuseIdentifier: "ItemsCell")
        self.updateUI()
    }
    //MARK:- Update UI
    func updateUI(){
        TheGlobalPoolManager.cornerAndBorder(fromDateView, cornerRadius: 5, borderWidth: 1, borderColor: .lightGray)
        TheGlobalPoolManager.cornerAndBorder(toDateView, cornerRadius: 5, borderWidth: 1, borderColor: .lightGray)
        
        orderHistoryTbl.tableFooterView = UIView()
        orderHistoryTbl.delegate = self
        orderHistoryTbl.dataSource = self
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        datePicker.maximumDate = NSDate() as Date
        datePicker.maximumDate = Date()
        self.foodOrderApiHitting()
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        dateSelectedString = dateFormatter.string(from: sender.date)
    }
    //MARK:- Food Order Api Hitting
    func foodOrderApiHitting(){
        Themes.sharedInstance.activityView(View: self.view)
        let param = ["restaurantId": [GlobalClass.restaurantLoginModel.data.subId!]]
        URLhandler.postUrlSession(urlString: Constants.urls.getFoodOrdersURL, params: param as [String : AnyObject], header: [:]) { (dataResponse) in
            Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                GlobalClass.foodOrderModel = FoodOrderModel(fromJson: dataResponse.json)
                self.orderHistoryTbl.reloadData()
            }
        }
    }
    //MARK:- IB Action Outlets
    @IBAction func fromDateBtnClicked(_ sender: Any) {
        dateContainerView.isHidden = false
        blurView.isHidden = false
        isFromDateSelected = true
    }
    @IBAction func toDateBtnClicked(_ sender: Any) {
        if fromDateString == nil{
            TheGlobalPoolManager.showToastView("Please select from date first")
            return
        }
        dateContainerView.isHidden = false
        blurView.isHidden = false
        isFromDateSelected = false
    }
    @IBAction func datePickDoneClicked(_ sender: Any) {
        dateContainerView.isHidden = true
        blurView.isHidden = true
        print("dateSelectedString ---->>> \(dateSelectedString)")
        let date = Date()
        if (dateSelectedString ?? "").isEmpty {
            dateSelectedString =  dateFormatter.string(from: date)
        }
        if isFromDateSelected {
            fromDateString = dateSelectedString
            fromDateLbl.text = dateSelectedString
            fromDateLbl.textColor = .textColor
        }else{
            toDateString = dateSelectedString
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date1 = dateFormatter.date(from: fromDateString)
            let date2 = dateFormatter.date(from: toDateString)
            if date1 == date2{
                toDateLbl.text = dateSelectedString
                toDateLbl.textColor = .textColor
                //self.foodOrderApiHitting()
            }else if date1! > date2! {
                TheGlobalPoolManager.showAlertWith(message: "Oops!, 'To Date' is past date when compared to 'From Date", singleAction: true, callback: { (success) in
                    if success!{}
                })
                return
            }else if date1! < date2! {
                toDateLbl.text = dateSelectedString
                toDateLbl.textColor = .textColor
                //self.foodOrderApiHitting()
            }
        }
    }
    @IBAction func datePickCancelClicked(_ sender: Any) {
        blurView.isHidden = true
        dateContainerView.isHidden = true
    }
    @IBAction func exportBtn(_ sender: UIButton) {
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:-----TableView Methods------
extension OrderHistoryViewController : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return GlobalClass.foodOrderModel == nil ? 0 : GlobalClass.foodOrderModel.completed.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTableViewCell") as! OrderHistoryTableViewCell
        headerCell.dropDownBtn.tag = section
        let data = GlobalClass.foodOrderModel.completed[section]
        headerCell.orderIDLbl.text = "Order ID: \(data.order[0].subOrderId!)"
        headerCell.noOfItemsLbl.text = data.items.count.toString
        headerCell.orderAmountLbl.text = "₹\(data.order[0].billing.orderTotal!.toString)"
        headerCell.orderStatusLbl.text = data.order[0].statusText!
        if self.collapaseHandlerArray.contains(data.order[0].subOrderId!){
            headerCell.dropDownBtn.setTitle("1", for: .normal)
            headerCell.farwardImg.image = #imageLiteral(resourceName: "UpArrow").withColor(.secondaryTextColor)
        }
        else{
            headerCell.dropDownBtn.setTitle("0", for: .normal)
            headerCell.farwardImg.image = #imageLiteral(resourceName: "Farward").withColor(.secondaryTextColor)
        }
        headerCell.dropDownBtn.addTarget(self, action: #selector(HandleheaderButton(sender:)), for: .touchUpInside)
        return headerCell.contentView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = GlobalClass.foodOrderModel.completed[section]
        if self.collapaseHandlerArray.contains(data.order[0].subOrderId!){
            return GlobalClass.foodOrderModel.completed[section].items.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell") as! ItemsCell
        let data = GlobalClass.foodOrderModel.completed[0].items[indexPath.row]
        cell.contentLbl.text = data.name!
        cell.priceLbl.text = "₹\(data.price.toString)"
        if data.vorousType == 1{
            cell.vorousTypeImg.image = #imageLiteral(resourceName: "Veg")
        }else{
            cell.vorousTypeImg.image = #imageLiteral(resourceName: "NonVeg")
        }
        cell.quantityLbl.text = "✕\(data.quantity!.toString)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        footerView.backgroundColor = .clear
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    @objc func HandleheaderButton(sender: UIButton){
        if let buttonTitle = sender.title(for: .normal) {
            if buttonTitle == "0"{
                let data = GlobalClass.foodOrderModel.completed[sender.tag]
                self.collapaseHandlerArray.append(data.order[0].subOrderId!)
                sender.setTitle("1", for: .normal)
            }
            else {
                let data = GlobalClass.foodOrderModel.completed[sender.tag]
                while self.collapaseHandlerArray.contains(data.order[0].subOrderId!){
                    if let itemToRemoveIndex = self.collapaseHandlerArray.index(of: data.order[0].subOrderId!) {
                        self.collapaseHandlerArray.remove(at: itemToRemoveIndex)
                        sender.setTitle("0", for: .normal)
                    }
                }
            }
        }
        self.orderHistoryTbl.reloadSections(IndexSet(integer: sender.tag), with: .none)
    }
}

