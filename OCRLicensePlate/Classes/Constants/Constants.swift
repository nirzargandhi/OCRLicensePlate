//
//  Constants.swift
//  OCRLicensePlate
//
//  Created by Nirzar Gandhi on 25/04/25.
//

import Foundation
import UIKit

let BASEWIDTH = 375.0
let SCREENSIZE: CGRect      = UIScreen.main.bounds
let SCREENWIDTH             = UIScreen.main.bounds.width
let SCREENHEIGHT            = UIScreen.main.bounds.height
let STATUSBARHEIGHT         = UIApplication.shared.statusBarFrame.size.height
var NAVBARHEIGHT            = 44.0

let APPDELEOBJ              = UIApplication.shared.delegate as! AppDelegate

struct Constants {
    
    struct Storyboard {
        
        static let Main = "Main"
    }
    
    struct LicensePlate {
        
        static let standardRegex = "^[A-Z]{2}[-\\s]?[0-9]{1,2}[-\\s]?[A-Z]{1,3}[-\\s]?[0-9]{4}$"
        static let temporaryRegex = "^(TEMP|[0-9]{4}[-\\s]?TEMP|[A-Z]{2}[-\\s]?TEMP[-\\s]?[0-9]{4})$"
        static let militaryRegex = "^(?i)\\b[0-9]{2}[A-Z][- ]?[0-9]{5,6}[- ]?[A-Z]\\b$"
        static let diplomaticRegex = "^[0-9]{1,3}[-\\s]?(CD|UN)[-\\s]?[0-9]{1,4}"
        static let vintageRegex = "^[A-Z]{2}V[-\\s]?[0-9]{4}$"
        static let bhSeriesRegex = "^[0-9]{2}[-\\s]?BH[-\\s]?[0-9]{4}[-\\s]?[A-Z]{0,2}$"
        static let firstNumberRegex = "^[0-9]{4}[-\\s]?[A-Z]{2}[-\\s]?[A-Z]{1,2}$"
        
        // General Regex
        static let indianPlatePattern = "^([A-Z]{2}[-\\s]?[0-9]{1,2}[-\\s]?[A-Z]{1,3}[-\\s]?[0-9]{4}|(TEMP|[0-9]{4}[-\\s]?TEMP|[A-Z]{2}[-\\s]?TEMP[-\\s]?[0-9]{4})|(?i)\\b[0-9]{2}[A-Z][- ]?[0-9]{5,6}[- ]?[A-Z]\\b|[0-9]{1,3}[-\\s]?(CD|UN)[-\\s]?[0-9]{1,4}|[A-Z]{2}V[-\\s]?[0-9]{4}|[0-9]{2}[-\\s]?BH[-\\s]?[0-9]{4}[-\\s]?[A-Z]{0,2}|[0-9]{4}[-\\s]?[A-Z]{2}[-\\s]?[A-Z]{1,2})$"
    }
}
