//
//  SettingsViewController.swift
//  FuelTripV3
//
//  Created by Tim Riedesel on 2/10/20.
//  Copyright © 2020 Tim Riedesel. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var btnDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        btnDoneButton.layer.cornerRadius = 5
        btnDoneButton.layer.masksToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    
    }
}
