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

class ViewController: UIViewController, MapsManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var lblmilesLabel: UILabel!
    @IBOutlet weak var lblGasStopLabel: UILabel!
    @IBOutlet weak var lblMoneyForGasLabel: UILabel!
    @IBOutlet weak var btnGoButton: UIButton!
    @IBOutlet weak var btnSettingsButton: UIButton!
    
    let locationManager = CLLocationManager()
    var mapsManager = MapsManager()
    let regionInMeters: Double = 10000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImagesAndLabel()
        mapView.delegate = self
        destinationTextField.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthorization()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func setImagesAndLabel() {
        btnGoButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        btnSettingsButton.imageEdgeInsets = UIEdgeInsets(top: 22, left: 27, bottom: 22, right: 27)
        //        lblmilesLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
        //        lblGasStopLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
        //        lblMoneyForGasLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Rectangle 6.png")!)
        
    }
    
    func fetchData(_ mapsManager: MapsManager, model: MapsModel) {
        DispatchQueue.main.async {
            self.lblmilesLabel.text = " \(String(format: "%.0f", model.distanceMiles)) Miles"
            self.lblGasStopLabel.text = "\(String(format: "%.0f", model.numberOfGasStops)) Stops"
            self.lblMoneyForGasLabel.text = "$\(String(format: "%.2f", model.costOfTrip))"
            
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //maybe UIAlert with Error Message
            print("location services not enabled")
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            break
        case .denied:
            //Show Alert instruction to enable
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show Alert letting user know whats up
            break
        case .authorizedAlways:
            break
        }
    }
    
    func getCoordinate(_ addressString: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            if ((error) != nil) {
                print("Error while Goecoding: \(String(describing: error))" )
            }
            if let placemarks = placemarks?.first {
                let lat = placemarks.location?.coordinate.latitude
                let lon = placemarks.location?.coordinate.longitude
                let destinationLocation = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                print("getCoordinateFunc: lat: \(lat!) & lon: \(lon!)")
                self.getDirections(with: destinationLocation )
            }
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D, to destintationCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let startingLocation                = MKPlacemark(coordinate: coordinate)
        let destination                     = MKPlacemark(coordinate: destintationCoordinate)
        print("Create DirectionRequ with destination: \(destination)" )
        
        let request                         = MKDirections.Request()
        request.source                      = MKMapItem(placemark: startingLocation)
        request.destination                 = MKMapItem(placemark: destination)
        request.transportType               = .automobile
        request.requestsAlternateRoutes     = false
        
        return request
    }
    
    func getDirections(with destination: CLLocationCoordinate2D) {
        
        guard let location = locationManager.location?.coordinate else {
            print("getDirectionsFunc: No Permission to retrive location")
            return
        }
        
        
        let request = createDirectionRequest(from: location, to: destination)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response , error) in
            //print("***error in directions calculation: \(String(describing: error))")
            guard let response = response else { return } //Show response not available in UIalert
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func performAction() {
        if destinationTextField.text != nil {
            locationManager.requestLocation()
            getCoordinate(destinationTextField.text!)
            
        }
    }
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        performAction()
    }
    
}


//MARK: - CoreLocation Delegates

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil) {
                print("error reverseGeoCode \(String(describing: error))")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let origin = String((placemark.first?.locality!)!)
                self.mapsManager.fetchDistance(origin)
                
            }
        }
        
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
        
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


//MARK: - MapKit Delegates

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        
        return renderer
    }
    
}

//MARK: - TextField Delegates
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performAction()
        destinationTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.text = ""
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if destinationTextField.text != "" {
            destinationTextField.placeholder = destinationTextField.text
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}

