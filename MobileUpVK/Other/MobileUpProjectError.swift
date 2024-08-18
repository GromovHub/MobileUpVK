//
//  Project name: MobileUpVK
//  File name: MobileUpProjectError.swift
//
//  Copyright © Gromov V.O., 2024
//

import Foundation

// string for the nearest file location or any comment

enum MobileUpProjectError: Error {
    case invalidURL(String)
    case noDataReceived(String)
    case invalidResponse(String)
    case decoderError(String)
    case tokenError(String)
    case imageError(String)
    case groupIdError(String)
    case restoreTokenError(String)
    case collectionViewFlowError(String)
    case downloadPhotoError(String)
}


