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

class BaseViewController: UIViewController, UIViewControllerTransitioningDelegate,GMSMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var titleBar: UINavigationBar!
    
    @IBOutlet weak var stackViewPunchCard: UIStackView!
    
    @IBOutlet weak var GMSMapViewGoogleMaps: GMSMapView!
    
    var locationManager = CLLocationManager()
    
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
        
        	//let camera = GMSCameraPosition.camera(withLatitude: 34.675483, longitude: 135.500520, zoom: 17.0)
        //GMSMapViewGoogleMaps.camera = camera
        // Do any additional setup after loading the view.
        GMSMapViewGoogleMaps.isMyLocationEnabled = true
        GMSMapViewGoogleMaps.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
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
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:17.0)
        GMSMapViewGoogleMaps.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
}


