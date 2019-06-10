//
//  OpeningViewController.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/6/3.
//  Copyright © 2019 richie shih. All rights reserved.
//

import UIKit

class OpeningViewController: UIViewController {
    @IBOutlet var UIViewLogoText: UIView!
    @IBOutlet weak var labelCompany: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var _account: String = ""
    var _password: String = ""
    var _deviceId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //let currentDevice = UIDevice.current
        //let uuid = currentDevice.identifierForVendor?.uuidString
        //print("uuid = ", uuid! as NSString)
        
        let defaults = UserDefaults.standard
        
        //detect height, width
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        let width = guide.layoutFrame.size.width
        let imgWidth = width*3/4
        let imgHeight = imgWidth/4
        let img_x = width/8
        let img_y = height/2 - imgHeight/2
        imgLogo.frame = CGRect(x: img_x, y: img_y, width: imgWidth, height: imgHeight)
        labelCompany.frame = CGRect(x: 0, y: img_y-40, width: width, height: 40)
        labelTitle.frame = CGRect(x: 0, y: img_y+imgHeight, width: width, height: 40)
        /*
         UserDefaults.standard.set("Anand", forKey: "name")
         
         let name = UserDefaults.standard.string(forKey: “name”) ?? “”
        */
        
        _account = defaults.string(forKey: "Account") ?? ""
        _password = defaults.string(forKey: "Password") ?? ""
        _deviceId = defaults.string(forKey: "DeviceID") ?? ""
        
        print("account = \(_account) password = \(_password) deviceID = \(_deviceId)")
        
        
        self.labelCompany.text = NSLocalizedString("OPENING_COMPANY_NAME", comment: "")
        self.labelTitle.text = NSLocalizedString("OPENING_TITLE", comment: "")
        
        labelCompany.alpha = 0.0
        labelTitle.alpha = 0.0
        imgLogo.alpha = 0.0
        
        
        //fade in
        /*
        UIView.animateWithDuration(2.0, delay: 2.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
        }, completion: {_ in
            imageView.image = secondImageView.image
            secondImageView.removeFromSuperview()
        })
        */
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            
            
            
            self.labelCompany.alpha = 1.0
            self.labelTitle.alpha = 1.0
            self.imgLogo.alpha = 1.0
            
        }, completion: { _ in
            
            //fade out
            UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.labelCompany.alpha = 0
                self.labelTitle.alpha = 0
                self.imgLogo.alpha = 0
        
                }, completion: { _ in
                    
                    //UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    
                    if self._account != "" && self._deviceId != "" {
                        let vc = storyBoard.instantiateViewController(withIdentifier: "BaseViewController")
                        
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    
                    /*
                     if (self->_account != nil && ![self->_account isEqualToString: @""] &&
                     self->_deviceId != nil && ![self->_deviceId isEqualToString:@""]) {
                     
                     UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
                     [self presentViewController:vc animated:YES completion:nil];
                     } else {
                     UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                     [self presentViewController:vc animated:YES completion:nil];
                     }
                    */
            })
        })
        
        
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
    
        if (recognizer.state == UIGestureRecognizer.State.ended){
            //code here
            print("subview touched");
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            
            if self._account != "" && self._deviceId != "" {
                let vc = storyBoard.instantiateViewController(withIdentifier: "BaseViewController")
                
                self.present(vc, animated: true, completion: nil)
            } else {
                let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
