//
//  ViewController.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/5/30.
//  Copyright © 2019 richie shih. All rights reserved.
//

import UIKit
import NavigationDrawer

class BaseViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var titleBar: UINavigationBar!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         mage.topAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.topAnchor).isActive = true
        */
        
        titleBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear")
    }
    
    //2.
    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSlidingMenu", sender: nil)
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
}


