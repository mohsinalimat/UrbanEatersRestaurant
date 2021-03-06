//
//  RecommendedViewController.swift
//  DinedooRestaurant
//
//  Created by Nagaraju on 25/10/18.
//  Copyright © 2018 casperonIOS. All rights reserved.
//

import UIKit

class RecommendedViewController:UIViewController,SelectGroupDelegate {

    @IBOutlet weak var recommendItemTbl: UITableView!
    var itemsList = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName:"RecommendedTableViewCell" , bundle: nil)
        recommendItemTbl.register(nibName, forCellReuseIdentifier: "RecommendedTableViewCell")
        self.updateUI()
    }
    //MARK:- Update UI
    func updateUI(){
        itemsList = ["Biryani","Snacks"]
        recommendItemTbl.delegate = self
        recommendItemTbl.dataSource = self
        recommendItemTbl.tableFooterView = UIView()
        self.recommendedItemsApiHitting()
    }
    //MARK : - Select Categories Xib
    func selectCategoriesXib(){
        let tableView = SelectGroup(nibName: "SelectGroup", bundle: nil)
        tableView.delegate = self
        self.presentPopupViewController(tableView, animationType: MJPopupViewAnimationSlideTopTop)
    }
    func delegateForSelectedGroup(selectedGroup: [String], viewCon: SelectGroup) {
        self.dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideBottomBottom)
        if selectedGroup.count != 0 {
            self.itemsList.append(contentsOf: selectedGroup)
            self.recommendItemTbl.reloadData()
        }
    }
    //MARK:- Recommended  Items Api Hitting
    func recommendedItemsApiHitting(){
        Themes.sharedInstance.activityView(View: self.view)
        let param = ["restaurantId": GlobalClass.restaurantLoginModel.data.subId!,
                                "recommended": "1"]
        URLhandler.postUrlSession(urlString: Constants.urls.RecommendedItems, params: param as [String : AnyObject], header: [:]) { (dataResponse) in
            Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                GlobalClass.recommendedModel = RecommendedModel(fromJson: dataResponse.json)
                self.recommendItemTbl.reloadData()
            }
        }
    }
    //MARK:- Recommended Item Items Delete Api Hitting
    func recommendedItemDeleteApiHitting(_ itemID : String){
        Themes.sharedInstance.activityView(View: self.view)
        let param = ["id": [itemID]]
        URLhandler.postUrlSession(urlString: Constants.urls.RecommendedItemDelete, params: param as [String : AnyObject], header: [:]) { (dataResponse) in
            Themes.sharedInstance.removeActivityView(View: self.view)
            if dataResponse.json.exists(){
                self.recommendedItemsApiHitting()
            }
        }
    }
    //MARK:- IB Action Outlets
    @IBAction func addBtnClicked(_ sender: Any) {
        self.selectCategoriesXib()
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:- UI TableView Delegates
extension  RecommendedViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalClass.recommendedModel == nil ? 0 : GlobalClass.recommendedModel.data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell : RecommendedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecommendedTableViewCell") as! RecommendedTableViewCell
        let data = GlobalClass.recommendedModel.data[indexPath.row]
        cell.itemDeleteBtn.tag = indexPath.row
        cell.itemDeleteBtn.addTarget(self, action: #selector(self.itemDeleteBtnAction(_:)), for: .touchUpInside)
        cell.itemNameLbl.text = data.name!
        cell.itemPriceLbl.text = "₹ \(data.price!.toString)"
        let url = URL.init(string: Constants.BASEURL_IMAGE + data.avatar!)
        cell.itemImgView.sd_setImage(with: url ,placeholderImage:  #imageLiteral(resourceName: "PlaceHolderImage")) { (image, error, cache, url) in
            if error != nil{
            }else{
                cell.itemImgView.image = image
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    @objc func itemDeleteBtnAction(_ sender:UIButton){
        TheGlobalPoolManager.showAlertWith(title: "Are you sure", message: "You want to delete?", singleAction: false, okTitle:"Confirm") { (sucess) in
            if sucess!{
               let data = GlobalClass.recommendedModel.data[sender.tag]
               self.recommendedItemDeleteApiHitting(data.id!)
            }
        }
    }
}
