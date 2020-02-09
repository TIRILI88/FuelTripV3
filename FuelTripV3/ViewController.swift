//
//  ViewController.swift
//  FuelTripV3
//
//  Created by Tim Riedesel on 2/8/20.
//  Copyright © 2020 Tim Riedesel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var lblmilesLabel: UILabel!
    @IBOutlet weak var lblGasStopLabel: UILabel!
    @IBOutlet weak var lblMoneyForGasLabel: UILabel!
    @IBOutlet weak var btnGoButton: UIButton!
    @IBOutlet weak var btnSettingsButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImagesAndLabel()
        
    }

    func setImagesAndLabel() {
        btnGoButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        btnSettingsButton.imageEdgeInsets = UIEdgeInsets(top: 22, left: 27, bottom: 22, right: 27)
//        lblmilesLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
//        lblGasStopLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
//        lblMoneyForGasLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
        lblmilesLabel.text = "1226 Miles"
        lblGasStopLabel.text = "4 Stops"
        lblMoneyForGasLabel.text = "$100.76"
        destinationTextField.text = "Los Angeles"
    }
    
    
}

//MARK: - TextField Delegates


//MARK: - CoreLocation Delegates




//MARK: - MapKit Delegates
