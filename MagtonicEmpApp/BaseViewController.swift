//
//  ViewController.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/5/30.
//  Copyright © 2019 richie shih. All rights reserved.
//

import UIKit
import NavigationDrawer
import GoogleMaps


class BaseViewController: UIViewController, UIViewControllerTransitioningDelegate,GMSMapViewDelegate,CLLocationManagerDelegate,URLSessionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var itemTitle: UINavigationItem!
    
    @IBOutlet weak var stackViewPunchCardWhole: UIStackView!
    @IBOutlet weak var tableViewHistoryWhole: UITableView!
    @IBOutlet weak var historyMapViewWhole: GMSMapView!
    @IBOutlet weak var stackViewPunchCard: UIView!
    @IBOutlet weak var btnPunchCardClockOn: UIButton!
    @IBOutlet weak var btnPunchCardClockOff: UIButton!
    @IBOutlet weak var btnPunchCardGoOut: UIButton!
    @IBOutlet weak var btnPunchCardGoBack: UIButton!
    @IBOutlet weak var btnPunchCardClockOnOverTime: UIButton!
    @IBOutlet weak var btnPunchCardClockOffOverTime: UIButton!
    
    @IBOutlet weak var GMSMapViewGoogleMaps: GMSMapView!
    @IBOutlet weak var barItemMenu: UIBarButtonItem!
    @IBOutlet weak var barItemBack: UIBarButtonItem!
    @IBOutlet weak var barItemKeyboard: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "historyCell"
        
        let cell: UITableViewCell = tableViewHistoryWhole.dequeueReusableCell(withIdentifier: CellIdentifier)!
        
        let history: History = historyList[indexPath.row]
        
        var imageView: UIImageView = cell.contentView.viewWithTag(201) as! UIImageView
        
        switch history.code {
        case "00","02","04":
            imageView.image = UIImage.init(named: "arrow_forward")
        case "01","03","05":
            imageView.image = UIImage.init(named: "arrow_back")
        
        default:
            print("unknown code")
        }
        
        let labelDesc: UILabel = cell.contentView.viewWithTag(202) as! UILabel
        labelDesc.text = history.getDesc()
        
        let labelDate: UILabel = cell.contentView.viewWithTag(203) as! UILabel
        labelDate.text = history.getDate()
        
        let labelTime: UILabel = cell.contentView.viewWithTag(204) as! UILabel
        labelTime.text = history.getTime()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click \(indexPath.row)")
        
        let rowIndex = indexPath.row;
        
        let historyItem: History = historyList[rowIndex]
        
        
        let position = CLLocationCoordinate2D(latitude: historyItem.getLatitude(), longitude: historyItem.getLongitude())
        
        print("latitude = \(String(historyItem.getLatitude())), longitude = \(String(historyItem.getLongitude()))")
        
        historyMapViewWhole.clear()
        
        let marker = GMSMarker(position: position)
        
        var marker_title = historyItem.getDesc()
        //marker_title += " "
        //marker_title += historyItem.getDate()
        marker_title += " "
        marker_title += historyItem.getTime()
        marker.title = marker_title
        
        var snippet_string = NSLocalizedString("MAP_LONGITUDE", comment: "")
        snippet_string += " : "
        snippet_string += String(historyItem.getLongitude())
        snippet_string += "\n"
        snippet_string += NSLocalizedString("MAP_LATITUDE", comment: "")
        snippet_string += " : "
        snippet_string += String(historyItem.getLatitude())
        marker.snippet = snippet_string
        marker.map = historyMapViewWhole
        
        historyMapViewWhole.moveCamera(GMSCameraUpdate.setTarget(position, zoom: 17.0))
        /*
         let position = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
         let marker = GMSMarker(position: position)
         marker.title = NSLocalizedString("MAP_MARKER_MY_LOCATION", comment: "")
         var snippet_string = NSLocalizedString("MAP_LONGITUDE", comment: "")
         snippet_string += " : "
         snippet_string += String(location!.coordinate.longitude)
         snippet_string += " "
         snippet_string += NSLocalizedString("MAP_LATITUDE", comment: "")
         snippet_string += " : "
         snippet_string += String(location!.coordinate.latitude)
         marker.snippet = snippet_string
         marker.map = GMSMapViewGoogleMaps
         
         GMSMapViewGoogleMaps.moveCamera(GMSCameraUpdate.setTarget(position, zoom: 17.0))
        */
        
        //itemTitle.title = NSLocalizedString("FUNC_PUNCHCARD", comment: "")
        
        //changeMenuItemIcon(itemIcon: MenuItemIcon.back.rawValue)
        showBarItem(show: false, itemIcon: "")
        current_fragment = CurrentFragmentType.HistoryDetail
        
        stackViewPunchCardWhole.isHidden = true
        tableViewHistoryWhole.isHidden = true
        historyMapViewWhole.isHidden = false
        
        showBackItem(show: true)
        
        //set title date
        /*let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let date = dateFormatter. dateFromString (strDate)*/
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "YYYY/MM/dd"
        let date = date_formatter.date(from: historyItem.date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: date!)
        
        var date_string = weekDay
        date_string += " "
        date_string += historyItem.getTime()
        date_string += " "
        date_string += historyItem.getDate()
        
        itemTitle.title = date_string
    }
    
    
    
    var _account: String? = ""
    var _password: String? = ""
    var _deviceId: String? = ""
    var _longitude: Double? = 0.0
    var _latitude: Double? = 0.0
    var current_code: String? = ""
    var current_fragment: CurrentFragmentType = CurrentFragmentType.PunchCard
    
    var historyList = [History]()
    //var historyList: NSMutableArray? = nil
    
    var locationManager = CLLocationManager()
    var historyLocationManager = CLLocationManager()
    var currentMarkerNum: Int = 0

    //for punch card
    let web_service_url = "http://61.216.114.217/asmx/WebService.asmx"
    let punch_fun = "Ins_mobile3"

    @IBAction func ClockOnClick(_ sender: Any) {
        print("ClockOnClick")
        
        showIndicator(show: true)
        
        current_code = "00"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    @IBAction func ClockOffClick(_ sender: Any) {
        print("ClockOffClick")
        
        showIndicator(show: true)
        
        current_code = "01"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    @IBAction func GoOutClick(_ sender: Any) {
        print("GoOutClick")
        
        current_code = "02"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    @IBAction func GoBackClick(_ sender: Any) {
        print("GoBackClick")
        
        current_code = "03"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    @IBAction func ClockOnOverTimeClick(_ sender: Any) {
        print("ClockOnOverTimeClick")
        
        current_code = "04"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    @IBAction func ClockOffOverTimeClick(_ sender: Any) {
        print("ClockOffOverTimeClick")
        
        current_code = "05"
        let p_json = set_p_json_string(code: current_code!)
        sendHttpPost(fun_name: punch_fun, p_json: p_json, completion: completionHandler)
    }
    
    func set_p_json_string(code: String) -> String {
        
        var p_json: String = ""
        
        let date = Date()
        let date_formatter = DateFormatter()
        let time_formatter = DateFormatter()
        
        date_formatter.dateFormat = "YYYY/MM/dd"
        time_formatter.dateFormat = "hh:mm"
        let date_result = date_formatter.string(from: date)
        let time_result = time_formatter.string(from: date)
        
        print("date_result = \(date_result) time_result = \(time_result)")
        
        
        
        //success func
        p_json = "{\"p_cmd\":\"0\", \"cqr01\":\""
        p_json += _account ?? "\"\""
        p_json += "\", \"cqr02\":\""
        p_json += date_result
        p_json += "\", \"cqr03\":\""
        p_json += time_result
        p_json += "\", \"cqr04\":\""
        p_json += code
        p_json += "\", \"cqrmobile\":\""
        p_json += _deviceId ?? "\"\""
        p_json += "\", \"cqrlatit\":\""
        p_json += _latitude!.description
        p_json += "\", \"cqrlongit\":\""
        p_json += _longitude!.description
        p_json += "\"}"
        
        print("p_json = \(p_json)")
        
        return p_json
    }
    
    //var webResponseData: NSMutableData? = nil
    
    public var requestTime:TimeInterval?
    public var response:HTTPURLResponse?
    var completionHandler:((HTTPURLResponse) -> Void)?
    
    var login_error_count = 0
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    enum BarItemIcon: String {
        case keyboard = "keyboard_icon"
        case clear = "clear_all_icon"
        case locate = "locate_on_icon"
    }
    
    enum MenuItemIcon: String {
        case menu = "menu_icon"
        case back = "arrow_back"
    }
    
    enum CurrentFragmentType: Int {
        case PunchCard = 0
        case History = 1
        case HistoryDetail = 2
    }
    
    //for indicator
    var activityLabel: UILabel? = nil
    var activityIndicator: UIActivityIndicatorView? = nil
    var container: UIView? = nil
    let frame: CGRect? = nil
    
    var uuid: String? = ""
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    let interactor = Interactor()
    
    //load history from sqllite
    let historyOP: historyDB = historyDB.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide barItemBack
        showBackItem(show: false)
        
        //load defaults
        let defaults = UserDefaults.standard
        
        let currentDevice = UIDevice.current
        _deviceId = currentDevice.identifierForVendor?.uuidString
        
        _account = defaults.string(forKey: "Account") ?? ""
        _password = defaults.string(forKey: "Password") ?? ""
        _deviceId = defaults.string(forKey: "DeviceID") ?? ""
        //debug id
        _deviceId = "358885096306040"
        
        //load history from sqllite
        //let historyOP: historyDB = historyDB.init()
        historyList = historyOP.readAll()
        
        
        // Do any additional setup after loading the view.
        GMSMapViewGoogleMaps.isMyLocationEnabled = true
        GMSMapViewGoogleMaps.delegate = self
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        //history detail
        //historyMapViewWhole.isMyLocationEnabled = true
        historyMapViewWhole.delegate = self
        //self.historyLocationManager.delegate = self
        //self.historyLocationManager.startUpdatingLocation()
        
        //set buttons
        
        //let guide = view.safeAreaLayoutGuide
        //let height = guide.layoutFrame.size.height
        let width = stackViewPunchCard.bounds.size.width
        let height = stackViewPunchCard.bounds.size.height
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        print("statusBarHeight = \(statusBarHeight)")
        print("width = \(width)")
        print("height = \(height)")
        
        let btnwidth = (width - 45) / 2
        let btnHeight = ((height - 40) - statusBarHeight) / 3
        
        
        print("btnwidth = \(btnwidth)")
        print("btnHeight = \(btnHeight)")
        
        btnPunchCardClockOn.frame = CGRect(x: 15, y: 10 , width: btnwidth, height: btnHeight)
        btnPunchCardClockOn.layer.cornerRadius = 10
        btnPunchCardClockOn.clipsToBounds = true
        btnPunchCardClockOn.setTitle(NSLocalizedString("BTN_PUNCHCARD_CLOCK_ON", comment: ""), for: UIControl.State.normal)
        
        let btnClockOff_x = btnwidth + 30
        
        btnPunchCardClockOff.frame = CGRect(x: btnClockOff_x , y: 10 , width: btnwidth, height: btnHeight)
        btnPunchCardClockOff.layer.cornerRadius = 10
        btnPunchCardClockOff.clipsToBounds = true
        btnPunchCardClockOff.setTitle(NSLocalizedString("BTN_PUNCHCARD_CLOCK_OFF", comment: ""), for: UIControl.State.normal)
        
        let btnGoOut_y = btnHeight + 20
        
        btnPunchCardGoOut.frame = CGRect(x: 15, y: btnGoOut_y, width: btnwidth, height: btnHeight)
        btnPunchCardGoOut.layer.cornerRadius = 10
        btnPunchCardGoOut.clipsToBounds = true
        btnPunchCardGoOut.setTitle(NSLocalizedString("BTN_PUNCHCARD_GO_OUT", comment: ""), for: UIControl.State.normal)
        
        btnPunchCardGoBack.frame = CGRect(x: btnClockOff_x, y: btnGoOut_y, width: btnwidth, height: btnHeight)
        btnPunchCardGoBack.layer.cornerRadius = 10
        btnPunchCardGoBack.clipsToBounds = true
        btnPunchCardGoBack.setTitle(NSLocalizedString("BTN_PUNCHCARD_GO_BACK", comment: ""), for: UIControl.State.normal)
        
        let btnClockOnOverTime_y = btnHeight*2 + 30
        
        btnPunchCardClockOnOverTime.frame = CGRect(x: 15, y: btnClockOnOverTime_y, width: btnwidth, height: btnHeight)
        btnPunchCardClockOnOverTime.layer.cornerRadius = 10
        btnPunchCardClockOnOverTime.clipsToBounds = true
        btnPunchCardClockOnOverTime.setTitle(NSLocalizedString("BTN_PUNCHCARD_CLOCK_ON_OVERTIME", comment: ""), for: UIControl.State.normal)
        
        btnPunchCardClockOffOverTime.frame = CGRect(x: btnClockOff_x, y: btnClockOnOverTime_y, width: btnwidth, height: btnHeight)
        btnPunchCardClockOffOverTime.layer.cornerRadius = 10
        btnPunchCardClockOffOverTime.clipsToBounds = true
        btnPunchCardClockOffOverTime.setTitle(NSLocalizedString("BTN_PUNCHCARD_CLOCK_OFF_OVERTIME", comment: ""), for: UIControl.State.normal)
        
        initLoading()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         mage.topAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.topAnchor).isActive = true
        */
        
        titleBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        print("BaseViewController -> viewDidAppear")
        
        let defaults = UserDefaults.standard
        let current_view = defaults.string(forKey: "CurrentView") ?? ""
        
        if current_view.count > 0 {
            if current_view == CurrentView.View.BaseViewController.rawValue {
                
                itemTitle.title = NSLocalizedString("FUNC_PUNCHCARD", comment: "")
                
                stackViewPunchCardWhole.isHidden = false
                tableViewHistoryWhole.isHidden = true
                historyMapViewWhole.isHidden = true
                
                showBarItem(show: true, itemIcon: BarItemIcon.locate.rawValue)
                current_fragment = CurrentFragmentType.PunchCard
                
                //clear marker
                GMSMapViewGoogleMaps.clear()
                //start update
                self.locationManager.startUpdatingLocation()
                
            } else if current_view == CurrentView.View.HistoryViewController.rawValue {
                
                itemTitle.title = NSLocalizedString("FUNC_HISTORY", comment: "")
                
                stackViewPunchCardWhole.isHidden = true
                tableViewHistoryWhole.isHidden = false
                historyMapViewWhole.isHidden = true
                
                tableViewHistoryWhole.reloadData()
                
                showBarItem(show: true, itemIcon: BarItemIcon.clear.rawValue)
                current_fragment = CurrentFragmentType.History
            } else if current_view == CurrentView.View.LoginViewController.rawValue {
                
                itemTitle.title = NSLocalizedString("LOGIN_BUTTON_LOGIN", comment: "")
                
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                
                let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            stackViewPunchCardWhole.isHidden = false
            tableViewHistoryWhole.isHidden = true
            historyMapViewWhole.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self)
        
        super.viewDidDisappear(animated)
        
        print("BaseViewController -> viewDidDisappear")
    }
    
    func initLoading() {
        
        container = UIView.init(frame: CGRect.init(x: self.view.frame.size.width/4, y: self.view.frame.size.height/2 - 20, width: self.view.frame.size.width/2, height: 50))
        container?.layer.cornerRadius = 10
        container?.clipsToBounds = true
        container?.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        activityLabel = UILabel.init(frame: CGRect.init(x: 0, y: 3, width: self.view.frame.size.width/2-40, height: 40))
        activityLabel?.text = NSLocalizedString("DATA_LOADING", comment: "")
        activityLabel?.textColor = UIColor.white
        activityLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        activityLabel?.textAlignment = .center
        container!.addSubview(activityLabel!)
        
        
        activityIndicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
        container?.addSubview(activityIndicator!)
        activityIndicator?.frame = CGRect.init(x: self.view.frame.size.width/2 - 40, y: 10, width: 30, height: 30)
        activityIndicator?.hidesWhenStopped = true
        
        
        
        self.view.addSubview(container!)
        container?.center = CGPoint(x: -(self.view.frame.size.width), y: self.view.frame.size.height/2)
        //activityIndicator?.startAnimating()
        
    }
    
    func showIndicator(show: Bool) {
        /*
         if (show) {
         container.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
         [activityIndicator startAnimating];
         } else {
         [activityIndicator stopAnimating];
         container.center = CGPointMake(-(self.view.frame.size.width), self.view.frame.size.height/2);
         }
         */
        
        if show {
            container?.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
            activityIndicator?.startAnimating()
        } else {
            container?.center = CGPoint(x: -(self.view.frame.size.width), y: self.view.frame.size.height/2)
            activityIndicator?.stopAnimating()
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    //2.
    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "showSlidingMenu", sender: nil)
        
        
    }
    @IBAction func barItemBackPressed(_ sender: UIBarButtonItem) {
        
        current_fragment = CurrentFragmentType.History
        
        stackViewPunchCardWhole.isHidden = true
        tableViewHistoryWhole.isHidden = false
        historyMapViewWhole.isHidden = true
        
        showBackItem(show: false)
        
    }
    
    @IBAction func barItemKeyboardPressed(_ sender: UIBarButtonItem) {
        if current_fragment == CurrentFragmentType.PunchCard {
            print("use locate function")
            
            //clear marker
            GMSMapViewGoogleMaps.clear()
            //start update
            self.locationManager.startUpdatingLocation()
            
        } else if current_fragment == CurrentFragmentType.History {
            print("use clear function")
            
            //confirm dialog
            
            let alert = UIAlertController.init(title: NSLocalizedString("DIALOG_WARNING", comment: ""), message: NSLocalizedString("DIALOG_CLEAR_ALL_HISTORY", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let confirmBtn = UIAlertAction.init(title: NSLocalizedString("COMMON_OK", comment: ""), style: UIAlertAction.Style.default) { (UIAlertAction) in
                //clear sqlite db
                self.historyOP.clearAll()
                //clear array
                self.historyList.removeAll()
                
                self.tableViewHistoryWhole.reloadData()
            }
            
            let cancelBtn = UIAlertAction.init(title: NSLocalizedString("COMMON_CANCEL", comment: ""), style: UIAlertAction.Style.default, handler: nil)
            
            alert.addAction(confirmBtn)
            alert.addAction(cancelBtn)
            
            self.present(alert, animated: true, completion: nil)
            
            
            /*
             UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SETTING_LOGOUT_ALERT_TITLE", nil)
             message:NSLocalizedString(@"SETTING_LOGOUT_ALERT_MSG", nil) preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *yesBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
             
             NSString *topic = [NSString stringWithFormat:@"/topics/%@", self->user_id];
             
             [[FIRMessaging messaging] unsubscribeFromTopic:topic];
             NSLog(@"Unsubscribed topic: %@", topic);
             
             
             UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
             [self presentViewController:vc animated:YES completion:nil];
             }];
             
             UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             
             }];
             
             [alert addAction:yesBtn];
             [alert addAction:cancelBtn];
            */
            
            
            
            
        }
    }

    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SlidingViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = self.interactor
        }
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("locationManager: didUpdateLocations")
        
        //get my last location
        let location = locations.last
        let position = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = NSLocalizedString("MAP_MARKER_MY_LOCATION", comment: "")
        var snippet_string = NSLocalizedString("MAP_LONGITUDE", comment: "")
        snippet_string += " : "
        snippet_string += String(location!.coordinate.longitude)
        snippet_string += " "
        snippet_string += NSLocalizedString("MAP_LATITUDE", comment: "")
        snippet_string += " : "
        snippet_string += String(location!.coordinate.latitude)
        marker.snippet = snippet_string
        marker.map = GMSMapViewGoogleMaps
        
        _latitude = location!.coordinate.latitude
        _longitude = location!.coordinate.longitude
        /*
         let position = CLLocationCoordinate2D(latitude: 10, longitude: 10)
         let marker = GMSMarker(position: position)
         marker.title = "Hello World"
         marker.map = mapView
        */
        
        //let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:17.0)
        
        GMSMapViewGoogleMaps.moveCamera(GMSCameraUpdate.setTarget(position, zoom: 17.0))
        //GMSMapViewGoogleMaps.animate(to: camera)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    
    func showBarItem(show: Bool, itemIcon: String) {
        if show {
            barItemKeyboard.isEnabled = true
            barItemKeyboard.image = UIImage.init(named: itemIcon)
        } else {
            barItemKeyboard.isEnabled = false
            barItemKeyboard.image = nil
        }
    }
    
    func showBackItem(show: Bool) {
        
        if show {
            barItemMenu.isEnabled = false
            barItemMenu.image = nil
            
            barItemBack.isEnabled = true
            barItemBack.image = UIImage.init(named: "arrow_back")
            
        } else {
            barItemBack.isEnabled = false
            barItemBack.image = nil
            
            barItemMenu.isEnabled = true
            barItemMenu.image = UIImage.init(named: "menu_icon")
            
        }
        
        
        
    }
    
    
    //@objc func receiveTestNotification(notification: Notification) {
    //    print("BaseViewController -> receiveTestNotification")
    //}
    
    func completionHandler(value: NSDictionary) {
        print("Function completion handler value: \(value)")
        
        showIndicator(show: false)
        
        if let result = value["result"] {
            
            let result_str = result as? String ?? ""
            let result_str2 = value["result2"] as? String ?? ""
            
            if result_str == "1" {
                print("punch card success")
                
                let date = Date()
                let date_formatter = DateFormatter()
                
                date_formatter.dateFormat = "YYYY/MM/dd"
                
                let date_result = date_formatter.string(from: date)
            
                
                let resultArray = result_str2.components(separatedBy: ":")
                let hours = resultArray[1]
                let minutes = resultArray[2]
                var desc: String = ""
                switch current_code {
                case "00":
                    desc = NSLocalizedString("PUNCHCARD_CLOCK_ON_SUCCESS", comment: "")
                    break
                case "01":
                    desc = NSLocalizedString("PUNCHCARD_CLOCK_OFF_SUCCESS", comment: "")
                    break
                case "02":
                    desc = NSLocalizedString("PUNCHCARD_GO_OUT_SUCCESS", comment: "")
                    break
                case "03":
                    desc = NSLocalizedString("PUNCHCARD_GO_BACK_SUCCESS", comment: "")
                    break
                case "04":
                    desc = NSLocalizedString("PUNCHCARD_CLOCK_ON_OVERTIME_SUCCESS", comment: "")
                    break
                case "05":
                    desc = NSLocalizedString("PUNCHCARD_CLOCK_OFF_OVERTIME_SUCCESS", comment: "")
                    break
                case .none:
                    print("none")
                case .some(_):
                    print("some")
                }
                
                //show message
                let alert = UIAlertController.init(title: "", message: desc, preferredStyle: UIAlertController.Style.alert)
                
                self.present(alert, animated: true, completion: nil)
                let duration = 2.0
                delay(duration) {
                    alert.dismiss(animated: true, completion: nil)
                }
                
                var time = hours
                time += ":"
                time += minutes
                
                let history = History(code: current_code!, desc: desc, date: date_result, time: time, latitude: _latitude!, longtitude: _longitude!)
                
                historyList.append(history)
                
                //add to sqlite
                historyOP.insert(history: history)
                
                print("historyList size = \(historyList.count)")
                
                for i in 0..<historyList.count {
                    print("historyList[\(i)] = \(historyList[i].getDesc())")
                }
                
            } else {
                
                
                
                //let message = NSLocalizedString("LOGIN_ID_EMPTY", comment: "")
                let alert = UIAlertController.init(title: "", message: result_str2, preferredStyle: UIAlertController.Style.alert)
                
                self.present(alert, animated: true, completion: nil)
                let duration = 2.0
                delay(duration) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func findFirstChar(output: String, compare: Character) -> Int {
        var ret = -1
        
        var index = 0
        for char in output {
            if compare == char {
                print("compare = \(compare), char = \(char)")
                ret = index
                break
            }
            index = index + 1
        }
        
        
        return ret
    }
    
    func sendHttpPost(fun_name: String, p_json: String, completion: @escaping (NSDictionary) -> Void) {
        
        var soapMessage = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        soapMessage += "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
        soapMessage += "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
        soapMessage += "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        soapMessage += "<soap:Body>"
        
        soapMessage += "<"
        soapMessage += fun_name
        soapMessage += " xmlns=\"http://tempuri.org/\">"
        soapMessage += "<p_json>"
        soapMessage += p_json
        soapMessage += "</p_json>"
        soapMessage += "</"
        soapMessage += fun_name
        soapMessage += ">"
        soapMessage += "</soap:Body>"
        soapMessage += "</soap:Envelope>"
        
        print("Soap message = \(soapMessage)")
        print("")
        
        let defaultConfigObject = URLSessionConfiguration.default
        
        let defaultSession = URLSession.init(configuration: defaultConfigObject, delegate: self, delegateQueue:OperationQueue.main)
        
        //now create a request to URL
        //let url_string = URL.init(fileURLWithPath: "http://61.216.114.217/asmx/WebService.asmx")
        let url_string = URL(string: web_service_url)
        var theRequest = URLRequest.init(url: url_string!)
        let msgLength = soapMessage.count
        //ad required headers to the request
        theRequest.addValue("61.216.114.217", forHTTPHeaderField: "Host")
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        var soap_action = "http://tempuri.org/"
        soap_action += fun_name
        
        theRequest.addValue(soap_action, forHTTPHeaderField: "SOAPAction")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8)
        
        let dataTask = URLSession.shared.dataTask(with: theRequest) { (data, response, error) in
            
            /*
             DispatchQueue.main.async { // Make sure you're on the main thread here
             imageview.image = UIImage(data: data)
             }
             */
            DispatchQueue.main.async {
                if error != nil{
                    print(error as Any)
                }else{
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    
                    //print("responsse = \(response)")
                    print("outputStr = \(outputStr)")
                    
                    var cut_tail: String = ""
                    if outputStr!.count > 0 {
                        
                        print("outputStr.count = \(outputStr!.count)")
                        let start_index = self.findFirstChar(output: outputStr!, compare: "[")
                        print("start_index = \(start_index)")
                        let end_index = self.findFirstChar(output: outputStr!, compare: "]")
                        print("end_index = \(end_index)")
                        
                        let start_offset = start_index + 1
                        let end_offset = end_index - outputStr!.count
                        
                        let start = outputStr!.index(outputStr!.startIndex, offsetBy: start_offset) //"["
                        let cut_head = String(outputStr![start...])
                        let end = cut_head.index(cut_head.endIndex, offsetBy: end_offset) //"]"
                        cut_tail = String(cut_head[..<end])
                        
                        print("cut_tail = \(cut_tail)")
                    }
                    
                    let input_data: Data? = Data(cut_tail.utf8)
                    
                    
                    do {
                        guard let data = input_data else {
                            throw JSONError.NoData
                        }
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            throw JSONError.ConversionFailed
                        }
                        completion(json)
                    } catch let error as JSONError {
                        print(error.rawValue)
                        
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    
                }
            }
            
            
        }
        
        dataTask.resume()
    }
}


