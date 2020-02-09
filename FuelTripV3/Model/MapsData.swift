//
//  MapsData.swift
//  FuelTripV3
//
//  Created by Tim Riedesel on 2/9/20.
//  Copyright © 2020 Tim Riedesel. All rights reserved.
//

import Foundation

struct MapsData: Codable {
    let rows: [Rows]
}

struct Rows: Codable {
    let elements: [Elements]
}

struct Elements: Codable {
    let distance: Distance
}

struct Distance: Codable {
    let value: Int
}
