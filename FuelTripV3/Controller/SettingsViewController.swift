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
    @IBOutlet weak var pricePerGallonTextField: UITextField!
    @IBOutlet weak var milesPerGallonTextField: UITextField!
    @IBOutlet weak var gallonPerFillingTextField: UITextField!
    
    let viewController = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        milesPerGallonTextField.delegate = self
        pricePerGallonTextField.delegate = self
        gallonPerFillingTextField.delegate = self
        
        setLabelTextfield()
        initialUserDefaults()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    
//MARK: - SetLabel + Textfield
    
    func initialUserDefaults() {
        milesPerGallonTextField.text = UserDefaults.standard.string(forKey: K.KEYmpG)
        pricePerGallonTextField.text = UserDefaults.standard.string(forKey: K.KEYppG)
        gallonPerFillingTextField.text = UserDefaults.standard.string(forKey: K.KEYgpF)
    }
    
    func setLabelTextfield() {
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        btnDoneButton.layer.cornerRadius = 5
        btnDoneButton.layer.masksToBounds = true
        
        pricePerGallonTextField.layer.cornerRadius = 5
        milesPerGallonTextField.layer.cornerRadius = 5
        gallonPerFillingTextField.layer.cornerRadius = 5
        
        pricePerGallonTextField.layer.borderColor = UIColor.gray.cgColor
        milesPerGallonTextField.layer.borderColor = UIColor.gray.cgColor
        gallonPerFillingTextField.layer.borderColor = UIColor.gray.cgColor
        
        pricePerGallonTextField.layer.borderWidth = 1.0
        milesPerGallonTextField.layer.borderWidth = 1.0
        gallonPerFillingTextField.layer.borderWidth = 1.0
        
        pricePerGallonTextField.layer.masksToBounds = true
        milesPerGallonTextField.layer.masksToBounds = true
        gallonPerFillingTextField.layer.masksToBounds = true
        
    }
    
    func saveItems() {
        UserDefaults.standard.set(milesPerGallonTextField.text, forKey: K.KEYmpG)
        UserDefaults.standard.set(pricePerGallonTextField.text, forKey: K.KEYppG)
        UserDefaults.standard.set(gallonPerFillingTextField.text, forKey: K.KEYgpF)
    }
    
    //MARK: - IBAction
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
                
        saveItems()
        UserDefaults.standard.synchronize()
        dismiss(animated: true, completion: nil)
   
    }
    
}
//MARK: - TextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height / 2)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
    
    
    


