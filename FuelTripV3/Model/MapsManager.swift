//
//  MapKitManager.swift
//  FuelTripV3
//
//  Created by Tim Riedesel on 2/9/20.
//  Copyright © 2020 Tim Riedesel. All rights reserved.
//

import Foundation

protocol MapsManagerDelegate {
    func fetchData(_ mapsManager: MapsManager, model: MapsModel)
    func didFailWithError(error: Error)
}

struct MapsManager {
    
    var delegate: MapsManagerDelegate?
    static var destinationName = ""
    static var fuelInTank : Int = 10         //Average consumption per Gasstop (in  Gallon)
    static var fuelPrice : Double = 2.29     //Input of actual Gasprice on a later state
    static var milesPerGallon : Int = 32     //milesPerGallon
    
    var rangePerFill: Double {
        return Double(MapsManager.fuelInTank) * Double(MapsManager.milesPerGallon)
    }                           //Average of 32 Miles per Gallon
    
    var pricePerFill: Double {
        return MapsManager.fuelPrice * Double(MapsManager.fuelInTank)
    }                           // fuelPrice * fuelInTank
    

    func fetchDistance(_ origin: String) {
        let urlString = "\(K.URLfirst)\(origin)&destinations=\(MapsManager.destinationName)&key=\(K.apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let encodedURL = URL(string: url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: encodedURL!) { (data, response, error) in
                if error != nil {
                    print("urlString didnt work: \(String(describing: error))")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let model = self.parseJSON(mapsData: safeData) {
                        self.delegate?.fetchData(self, model: model)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(mapsData: Data) -> MapsModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(MapsData.self, from: mapsData)
            let distance = decodedData.rows[0].elements[0].distance.value
            var distanceMiles: Double {
                return ((Double(distance) * 0.000621371))
            }
            var numberOfGasStops: Int {
                return Int(Double(distanceMiles) / rangePerFill)
            }
            var costOfTrip: Double {
                return Double(numberOfGasStops) * Double(pricePerFill)
            }
            let model = MapsModel(lengthInMeters: distance, distanceMiles: distanceMiles, costOfTrip: costOfTrip, numberOfGasStops: numberOfGasStops)
            print(model)
            return model
            
        } catch {
            print(error)
            return nil
        }
    }
}

