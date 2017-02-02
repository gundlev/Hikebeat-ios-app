//
//  ErrorEnums.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 06/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

enum MediaUploadError: Swift.Error {
    case signedUrl
    case s3Upload
    case createMedia
}

enum UserCallError: Swift.Error {
    case statsCall
    case refreshTokenCall
    case getJourneysForUser
    case facebookLogin
}

enum MediaDownloadError: Swift.Error {
    case profileImage
}

enum SearchError: Swift.Error {
    case userSearch
    case journeySearch
}

enum CompressionError: Swift.Error {
    case avAssetExportFail
    case compressionFailed
    case compressionCancelled
}

enum SyncError: Swift.Error {
    case uploadBeat
    case uploadMedia
    case uploadChange
    case uploadAll
}
