//
//  Country.swift
//  IliadTestApp
//
//  Created by Samith on 20/07/23.
//

import Foundation
import UIKit

struct Country {
    var common: String
    var officialName: String?
    var capitals: [String]
    var independent: Bool?
    var continents: [String]
    var flags: Flags
    var region: String? 
    var subRegion: String?
    var population: Int64?
    var flagImage: UIImage?
}
