//
//  ErrorEnums.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 06/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

enum HikebeatError: Swift.Error {
    case signedUrl
    case s3Upload
    case createMedia
    case statsCall
    case refreshTokenCall
    case getJourneysForUser
    case facebookLogin
    case profileImage
    case userSearch
    case journeySearch
    case getJourneyWithId
    case avAssetExportFail
    case compressionFailed
    case compressionCancelled
    case uploadBeat
    case uploadMedia
    case uploadChange
    case uploadAll
    case createNewJourneyCall
    case noNetworkConnection
    case updateUserCall
    case updateUserWithPermittedPhoneNumber
    case callFailed
    case imageDownload
    case imageSave
    case getUsers
    case noSuchListType
}

//enum UserCallError: Swift.Error {
//    case statsCall
//    case refreshTokenCall
//    case getJourneysForUser
//    case facebookLogin
//}
//
//enum MediaDownloadError: Swift.Error {
//    case profileImage
//}
//
//enum SearchError: Swift.Error {
//    case userSearch
//    case journeySearch
//    case getJourneyWithId
//}
//
//enum CompressionError: Swift.Error {
//    case avAssetExportFail
//    case compressionFailed
//    case compressionCancelled
//}
//
//enum SyncError: Swift.Error {
//    case uploadBeat
//    case uploadMedia
//    case uploadChange
//    case uploadAll
//}
