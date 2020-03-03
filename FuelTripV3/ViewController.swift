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
    @IBOutlet weak var btnGoToAppleMapsButton: UIButton!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var mapsManager = MapsManager()
    var userSource : CLLocationCoordinate2D?
    var userDestination : CLLocationCoordinate2D?
    var userSourceString: String?
    var userDestinationString: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImagesAndLabel()
        mapView.delegate = self
        destinationTextField.delegate = self
        locationManager.delegate = self
        mapsManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthorization()
        
    }
    
    func performAction() {
           if destinationTextField.text != nil {
               locationManager.requestLocation()
               getCoordinate(destinationTextField.text!)
               textFieldDidEndEditing(destinationTextField)
               UserDefaults.standard.synchronize()
           }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            if destinationTextField.text == "" {
                destinationTextField.text = "San Francisco"
            }
        }
    }
//MARK: - LocationManager Functions
    
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

//MARK: - Create Directions Functions
    
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
                //print("getCoordinateFunc: lat: \(lat!) & lon: \(lon!)")
                self.userDestination = destinationLocation
                self.getDirections(with: destinationLocation)
                self.showFinalAnnotation(destinationLocation)
            }
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D, to destintationCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let startingLocation                = MKPlacemark(coordinate: coordinate)
        let destination                     = MKPlacemark(coordinate: destintationCoordinate)
        //print("Create DirectionRequ with destination: \(destination)" )
        
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
            
            guard let distance = response.routes.first?.distance else {
                print("Error getting Distance from MapKit")
                return
            }
            //print("\(distance * 0.000621371) Miles")
            self.mapsManager.perfromRequest(distance)
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
            }
        }
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        
    }
    
   
    
//MARK: - Set UIView Elements
    
    func setImagesAndLabel() {
        btnSettingsButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        lblmilesLabel.layer.cornerRadius = 5.0
        lblGasStopLabel.layer.cornerRadius = 5.0
        lblMoneyForGasLabel.layer.cornerRadius = 5.0
        destinationTextField.layer.cornerRadius = 5.0
        lblmilesLabel.layer.masksToBounds = true
        lblGasStopLabel.layer.masksToBounds = true
        lblMoneyForGasLabel.layer.masksToBounds = true
        destinationTextField.layer.masksToBounds = true
        lblmilesLabel.layer.borderColor = UIColor.gray.cgColor
        lblGasStopLabel.layer.borderColor = UIColor.gray.cgColor
        lblMoneyForGasLabel.layer.borderColor = UIColor.gray.cgColor
        destinationTextField.layer.borderColor = UIColor.gray.cgColor
        destinationTextField.layer.borderWidth = 1.0
        lblmilesLabel.layer.borderWidth = 1.0
        lblGasStopLabel.layer.borderWidth = 1.0
        lblMoneyForGasLabel.layer.borderWidth = 1.0
        lblmilesLabel.text = "Distance"
        lblGasStopLabel.text = "Stops for Gas"
        lblMoneyForGasLabel.text = "$"
    }
    
//MARK: - IBActions
    
    
    @IBAction func valueSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = MKMapType.standard
        } else {
            mapView.mapType = MKMapType.hybrid
        }
    
    }
    
    
    @IBAction func goToAppleMapsPressed(_ sender: UIButton) {
        openMapsWithDirection()
        
    }
    
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        performAction()
    }
    
}

//MARK: - MapsManagerDelegate

extension ViewController: MapsManagerDelegate {
    
    func fetchData(_ mapsManager: MapsManager, model: MapsModel) {
        DispatchQueue.main.async {
            if self.lblmilesLabel.text != "" {
                self.lblGasStopLabel.isHidden = false
                self.lblmilesLabel.isHidden = false
                self.lblMoneyForGasLabel.isHidden = false
                self.btnGoToAppleMapsButton.isHidden = false
                self.lblmilesLabel.text = " \(String(format: "%.0f", model.distanceMiles)) Miles"
                self.lblGasStopLabel.text = "\(String(model.numberOfGasStops)) Stops"
                self.lblMoneyForGasLabel.text = "$\(String(format: "%.2f", model.costOfTrip))"
                
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


//MARK: - CoreLocation Delegates

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationManager.location != nil {
            
            let userLocation : CLLocation = locations[0] as CLLocation
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil) {
                    print("error reverseGeoCode \(String(describing: error))")
                }
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let origin = String((placemark.first?.locality!)!)
                    self.userSourceString = origin
                    
                }
            }
            
            guard let location = locations.last else { return }
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            self.userSource = center
            mapView.setRegion(region, animated: true)
            
        } else {
            print("didUpdateLocation cannot be excuted")
        }
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
    
    func showFinalAnnotation(_ destination: CLLocationCoordinate2D) {
          let annotation = MKPointAnnotation()
          annotation.coordinate = destination
          
          mapView.addAnnotation(annotation)
      }
    
    func openMapsWithDirection() {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: userSource!))
        source.name = userSourceString

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: userDestination!))
        destination.name = userDestinationString
         
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
}

//MARK: - TextFieldDelegates
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performAction()
        destinationTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if destinationTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if destinationTextField.text != "" {
            MapsManager.destinationName = destinationTextField.text!
            destinationTextField.placeholder = destinationTextField.text
            userDestinationString = destinationTextField.text
        }
    }
    
}

