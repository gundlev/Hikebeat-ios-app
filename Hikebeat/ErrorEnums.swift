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
