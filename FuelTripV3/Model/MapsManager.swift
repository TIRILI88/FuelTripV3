//
//  MapKitManager.swift
//  FuelTripV3
//
//  Created by Tim Riedesel on 2/9/20.
//  Copyright © 2020 Tim Riedesel. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapsManagerDelegate {
    func fetchData(_ mapsManager: MapsManager, model: MapsModel)
    func didFailWithError(error: Error)
}

struct MapsManager {
    
    var delegate: MapsManagerDelegate?
    static var destinationName = ""
    
    static var pricePerGallon: String = {
        UserDefaults.standard.register(defaults: [K.KEYppG : "2.29"])
        return UserDefaults.standard.string(forKey: K.KEYppG)!
    }()
    
    static var gallonPerFilling : String = {
        UserDefaults.standard.register(defaults: [K.KEYgpF : "10"])
        return UserDefaults.standard.string(forKey: K.KEYgpF)!
    }()
    
    static var milesPerGallon : String = {
        UserDefaults.standard.register(defaults: [K.KEYmpG : "32"])
        return UserDefaults.standard.string(forKey: K.KEYmpG)!
    }()
    
    var rangePerFill: Double {
        return Double(MapsManager.gallonPerFilling)! * Double(MapsManager.milesPerGallon)!
    }
    
    var pricePerMile: Double {
        return (Double(MapsManager.gallonPerFilling)! * Double(MapsManager.pricePerGallon)!) / Double(rangePerFill)
    }
    
    var pricePerFill: Double {
        return Double(MapsManager.pricePerGallon)! * Double(MapsManager.gallonPerFilling)!
    }
    
    
    func getDistanceFromMapKit(with distance: CLLocationDistance) -> MapsModel? {
        var distance = Int(distance)
        var distanceMiles: Double {
            return ((Double(distance) * 0.000621371))
        }
        var numberOfGasStops: Int {
            return Int(Double(distanceMiles) / rangePerFill)
        }
        var costOfTrip: Double {
            return distanceMiles * pricePerMile
        }
        let model = MapsModel(lengthInMeters: distance, distanceMiles: distanceMiles, costOfTrip: costOfTrip, numberOfGasStops: numberOfGasStops)
        return model
        
    }
    
    func perfromRequest(_ distance: CLLocationDistance) {
        if let model = getDistanceFromMapKit(with: distance) {
            delegate?.fetchData(self, model: model)
        }
    }
}

