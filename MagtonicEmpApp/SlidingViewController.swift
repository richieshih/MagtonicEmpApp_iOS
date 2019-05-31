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

class SlidingViewController: UIViewController {

    @IBOutlet weak var TopStackView: UIStackView!
    @IBOutlet weak var btnSpace: UIButton!
    
    var interactor:Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TopStackView.addBackground(color: UIColor.init(displayP3Red: (66/255.0), green: (165/255.0), blue: (245/255.0), alpha: 1.0))
        
        
        // Do any additional setup after loading the view.
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

}
