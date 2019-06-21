//
//  LoginViewController.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/6/3.
//  Copyright © 2019 richie shih. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, XMLParserDelegate, URLSessionDelegate, UITextFieldDelegate {
    @IBOutlet weak var imgLoginLogo: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textFieldAccount: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var btnFake: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    
    let web_service_url = "http://61.216.114.217/asmx/WebService.asmx"
    let login_fun = "Chk_mobile"
    let signin_fun = "Ins_mobile_file"
    
    //var webResponseData: NSMutableData? = nil
    
    public var requestTime:TimeInterval?
    public var response:HTTPURLResponse?
    var completionHandler:((HTTPURLResponse) -> Void)?
    
    var login_error_count = 0
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }

    //for indicator
    var activityLabel: UILabel? = nil
    var activityIndicator: UIActivityIndicatorView? = nil
    var container: UIView? = nil
    let frame: CGRect? = nil
    
    var uuid: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //imgLoginLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        //get uuid
        
        
        let currentDevice = UIDevice.current
        uuid = currentDevice.identifierForVendor?.uuidString
        
        //debug uuid
        uuid = "358885096306040"
        
        print("uuid = ", uuid! as NSString)
        
        
        let guide = view.safeAreaLayoutGuide
        //let height = guide.layoutFrame.size.height
        let width = guide.layoutFrame.size.width
        let imgWidth = width
        let imgHeight = imgWidth/4	
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        print("statusBarHeight = \(statusBarHeight)")
    
        imgLoginLogo.frame = CGRect(x: 0, y: statusBarHeight , width: imgWidth, height: imgHeight)
        
        let title_y = statusBarHeight+imgHeight
        
        labelTitle.frame = CGRect(x:0, y: title_y, width: width, height: 48)
        self.labelTitle.text = NSLocalizedString("LOGIN_TITLE", comment: "")
        
        
        let account_y = title_y+48
        let textFieldWidth = width - 16
        
        textFieldAccount.frame = CGRect(x: 8, y: account_y, width: textFieldWidth, height: 43.0)
        textFieldAccount.placeholder = NSLocalizedString("LOGIN_EMP_NO", comment: "")
        
        textFieldAccount.delegate = self
        
        let password_y = account_y + 51 //(43+8)
        
        textFieldPassword.frame = CGRect(x: 8, y: password_y, width: textFieldWidth, height: 43)
        textFieldPassword.placeholder = NSLocalizedString("LOGIN_PASSWORD", comment: "")
        
        textFieldPassword.delegate = self
        
        let btnFake_y = password_y + 51 //(43+8)
        btnFake.frame = CGRect(x: 8, y: btnFake_y, width: textFieldWidth, height: 30)
        
        let btnLogin_y = btnFake_y + 38 //(30+8)
        btnLogin.frame = CGRect(x: 8, y: btnLogin_y, width: textFieldWidth, height: 40)
        btnLogin.layer.cornerRadius = 10
        btnLogin.clipsToBounds = true
        btnLogin.setTitle(NSLocalizedString("LOGIN_BUTTON_LOGIN", comment: ""), for: UIControl.State.normal)
    
        let label_uuid_y = btnLogin_y + 48 //(40+8)
        labelUUID.frame = CGRect(x: 8, y: label_uuid_y, width: textFieldWidth, height: 21)
        let code = "\(NSLocalizedString("LOGIN_UUID", comment: "")) \(uuid ?? "")"
        labelUUID.text = code
        
        let label_desc_y = label_uuid_y + 29 //(21+8)
        labelDesc.frame = CGRect(x: 8, y: label_desc_y, width: textFieldWidth, height: 42)
        labelDesc.text = NSLocalizedString("LOGIN_DESCRIPTION", comment: "")
        
        let btnRegister_y = label_desc_y + 50 //(42+8)
        btnRegister.frame = CGRect(x: 8, y: btnRegister_y, width: textFieldWidth, height: 40)
        btnRegister.layer.cornerRadius = 10
        btnRegister.clipsToBounds = true
        btnRegister.setTitle(NSLocalizedString("LOGIN_BUTTON_REGISTER", comment: ""), for: UIControl.State.normal)
        
        initLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        login_error_count = 0
        
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldPassword || textField == textFieldAccount {
            textField.resignFirstResponder()
            
            print("false")
            
            return false
        }
        
        print("true")
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func initLoading() {
        
        container = UIView.init(frame: CGRect.init(x: self.view.frame.size.width/4, y: self.view.frame.size.height/2 - 20, width: self.view.frame.size.width/2, height: 50))
        container?.layer.cornerRadius = 10
        container?.clipsToBounds = true
        container?.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        activityLabel = UILabel.init(frame: CGRect.init(x: 0, y: 3, width: self.view.frame.size.width/2-40, height: 40))
        activityLabel?.text = NSLocalizedString("LOGIN_PROGRESS", comment: "")
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
    
    
    @IBAction func LoginClick(_ sender: Any) {
        print("LoginClick")
        
        if textFieldAccount.text?.count == 0 {
            /*
             message = NSLocalizedString(@"LOGIN_ID_EMPTY", nil);
             
             alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:alert animated:YES completion:nil];
             int duration = 2;
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[alert dismissViewControllerAnimated:YES completion:nil];});
             
             _login_error_count++;
            */
            let title = NSLocalizedString("DIALOG_WARNING", comment: "")
            let message = NSLocalizedString("LOGIN_ID_EMPTY", comment: "")
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            let duration = 2.0
            delay(duration) {
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            
            showIndicator(show: true)
            
            //success func
            var p_json = "{\"p_cmd\":\"0\", \"m01\":\""
            p_json += textFieldAccount.text ?? "\"\""
            p_json += "\", \"m02\":\""
            p_json += uuid ?? "\"\""
            p_json += "\"}"
            sendHttpPost(fun_name: login_fun, p_json: p_json, completion: completionHandler)
        }
        
        
        
        //alamofire
        /*let parameters: [String: Any] = [
        
            "p_json": "{ p_cmd: 0, m01: 0133, m02: 358885096306040 }"
        ]
        
        print("parameters = \(parameters)")
        
        AF.request(login_url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            //.validate(contentType: ["application/x-www-form-urlencoded"])
            .validate(contentType: ["text/xml; charset=utf-8"])
            //.validate(contentType: ["application/json"])
            .responseData { (response: DataResponse) in
                print("response = \(response)")
                
                switch response.result {
                case .success:
                    print("success")
                    //print("Created board title is \(board.title)") // New York Highlights
                case .failure(let error):
                    print("Board creation failed with error: \(error.localizedDescription)")
                }
        }*/
    
        
        
        
    }
    
    @IBAction func RegisterClick(_ sender: Any) {
        if textFieldAccount.text?.count == 0 {
            
            let title = NSLocalizedString("DIALOG_WARNING", comment: "")
            let message = NSLocalizedString("LOGIN_ID_EMPTY", comment: "")
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            let duration = 2.0
            delay(duration) {
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            
            showIndicator(show: true)
            
            //success func
            var p_json = "{\"p_cmd\":\"0\", \"m01\":\""
            p_json += textFieldAccount.text ?? "\"\""
            p_json += "\", \"m02\":\""
            p_json += uuid ?? "\"\""
            p_json += "\", \"m03\":\""
            p_json += textFieldPassword.text ?? "\"\""
            p_json += "\"}"
            sendHttpPost(fun_name: signin_fun, p_json: p_json, completion: completionHandler)
        }
    }
    
    
    func completionHandler(value: NSDictionary) {
        print("Function completion handler value: \(value)")
        
        showIndicator(show: false)
        
        if let result = value["result"] {
            
            let result_str = result as? String ?? ""
            let result_str2 = value["result2"] as? String ?? ""
            
            if result_str == "1" {
                print("Login success")
                
                //save a sdefaults
                let defaults = UserDefaults.standard
                
                if textFieldAccount.text!.count > 0 {
                    defaults.set(textFieldAccount.text, forKey: "Account")
                }
                
                if textFieldPassword.text!.count > 0 {
                    defaults.set(textFieldPassword.text, forKey: "Password")
                }
                
                if (uuid!.count > 0) {
                    defaults.set(uuid, forKey: "DeviceID")
                }
                //save name
                if result_str2.count > 0 {
                    defaults.set(result_str2, forKey: "Name")
                }
                
                //save current view
                defaults.set(CurrentView.View.BaseViewController.rawValue, forKey: "CurrentView")
                
                //go baseview
                
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "BaseViewController")
                self.present(vc, animated: true, completion: nil)
                
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
