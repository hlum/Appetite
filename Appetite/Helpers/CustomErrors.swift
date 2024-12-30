//
//  CustomErrors.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation

enum CustomErrors: Error {
    
//    HotPepperAPIError
    case NoDataFound
    case InvalidURL
    //LocationManager Errors
    case LocationPermissionDenied

    var localizedDescription: String? {
        switch self {
        case .NoDataFound:
            return NSLocalizedString(
                "No data was found.",
                comment: "No data found error"
            )
        case .InvalidURL:
            return NSLocalizedString(
                "The URL is invalid.",
                comment: "Invalid URL error"
            )
        case .LocationPermissionDenied:
            return NSLocalizedString(
                "Location access permission was denied.",
                comment: "Location permission denied error"
            )
        }
    }
    
}


