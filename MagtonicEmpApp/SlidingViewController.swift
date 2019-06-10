//
//  SlidingViewController.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/5/30.
//  Copyright © 2019 richie shih. All rights reserved.
//

import UIKit
import NavigationDrawer

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

class SlidingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var funcArray = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return funcArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "funCell"
        
        //UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        let cell: UITableViewCell = funcTableView.dequeueReusableCell(withIdentifier: CellIdentifier)!
        
        let func_name: String = funcArray[indexPath.row]
        let imageView: UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
        
        if indexPath.row == 0 {
            imageView.image = UIImage.init(named: "punch_card_icon")
        } else if indexPath.row == 1 {
            imageView.image = UIImage.init(named: "history_icon")
        } /*else if indexPath.row == 2 {
            imageView.isHidden = true //show label only
        }*/
        else if indexPath.row == 2 {
            imageView.image = UIImage.init(named: "logout_icon")
        }
        
        let labelFuncName: UILabel = cell.contentView.viewWithTag(102) as! UILabel
        labelFuncName.text = func_name
        
        return cell
    }
    
    //(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if indexPath.row == 0 {
            //let vc = storyBoard.instantiateViewController(withIdentifier: "BaseViewController")
            
            //present(vc, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            
            
            //let vc = storyBoard.instantiateViewController(withIdentifier: "HistoryViewController")
            
            //present(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var funcTableView: UITableView!
    @IBOutlet weak var TopStackView: UIStackView!
    @IBOutlet weak var btnSpace: UIButton!
    @IBOutlet weak var labelMenuTopTitle: UILabel!
    @IBOutlet weak var labelMenuTopEmpGreeting: UILabel!
    var interactor:Interactor? = nil
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TopStackView.addBackground(color: UIColor.init(displayP3Red: (66/255.0), green: (165/255.0), blue: (245/255.0), alpha: 1.0))
        
        self.labelMenuTopTitle.text = NSLocalizedString("SLIDINGVIEW_MENU_TOP_TITLE", comment: "")
        
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: "Name") ?? ""
        
        self.labelMenuTopEmpGreeting.text = NSLocalizedString("SLIDINGVIEW_MENU_TOP_EMP_GREETING", comment: "") + name
        
        //init func array
        let func1:String = NSLocalizedString("FUNC_PUNCHCARD", comment: "")
        let func2:String = NSLocalizedString("FUNC_HISTORY", comment: "")
        //let func3:String = NSLocalizedString("FUNC_OTHER", comment: "")
        let func4:String = NSLocalizedString("FUNC_LOGOUT", comment: "")
        
        funcArray.append(func1)
        funcArray.append(func2)
        //funcArray.append(func3)
        funcArray.append(func4)
        
        print("funcArray size = \(funcArray.count)")
        
        for i in 0..<funcArray.count {
            print("funcArray[\(i)] = \(funcArray[i])")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        funcTableView.reloadData()
        
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        funcArray.removeAll()
        
        print("viewDidDisappear")
    }
    
    //Handle Gesture
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        
        return topMostViewController
    }

}
