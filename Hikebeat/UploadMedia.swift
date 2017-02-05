//
//  UploadMedia.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 06/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import BrightFutures
import Result

func uploadMediaForBeat(type: String, path: URL, journeyId: String, timeCapture: String, progressCallback: @escaping (_ progress: Float) -> ()) -> Future<String, HikebeatError> {
    return Future { complete in
        // 1. Get signedUrl and id from API
        getSignedUrlAndId(type: type).onSuccess(callback: { (tuple) in
            // 2. Upload media to S3
            uploadToS3(signedUrl: tuple.signedUrl, path: path, type: type, progressCallback: progressCallback).onSuccess(callback: { (success) in
                // 3. Call create media to API
                createMediaOnAPI(journeyId: journeyId, fileKey: tuple.id, timeCapture: timeCapture).onSuccess(callback: { (success) in
                    complete(.success(tuple.id))
                }).onFailure(callback: { (error) in
                    complete(.failure(error))
                })
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
    }
}

func uploadProfileImage(path: URL, progressCallback: @escaping (_ progress: Float) -> ()) -> Future<Bool, HikebeatError> {
    return Future { complete in
        // 1. Get signedUrl and id from API
        getSignedUrlAndId(type: "profile-photo").onSuccess(callback: { (tuple) in
            // 2. Upload media to S3
            uploadToS3(signedUrl: tuple.signedUrl, path: path, type: MediaType.image, progressCallback: progressCallback).onSuccess(callback: { (success) in
                // 3. Call create media to API
                createProfilePhotoOnAPI(fileKey: tuple.id).onSuccess(callback: { (success) in
                    complete(.success(success))
                }).onFailure(callback: { (error) in
                    complete(.failure(error))
                })
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
    }
}

func createProfilePhotoOnAPI(fileKey: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let userId = userDefaults.string(forKey: "_id")
        let url = IPAddress + "users/\(userId!)/profile-photo"
        let parameters = [
            "fileKey" : fileKey
        ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            if response.response?.statusCode == 200 {
//                print("create media: ", response.request?.httpBody)
//                print("response: ", response)
                complete(.success(true))
            } else {
                complete(.failure(.createMedia))
                print(response)
            }
        }
    }
}

func getSignedUrlAndId(type: String) -> Future<(signedUrl: String, id: String), HikebeatError> {
    return Future { complete in
        let urlJourney = IPAddress + "media/\(type)"
        print("url: ",urlJourney)
        Alamofire.request(urlJourney, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            print("signedResponse: ", response)
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value!)
                let signedUrl = json["data"]["signedUrl"].stringValue.removingPercentEncoding!
                let id = json["data"]["fileKey"].stringValue
                print("signedUrl: ", signedUrl)
                complete(.success((signedUrl: signedUrl, id: id)))
            } else {
                complete(.failure(.signedUrl))
            }
        }
    }
}

func uploadToS3(signedUrl: String, path: URL, type: String, progressCallback: @escaping (_ progress: Float) -> ()) -> Future<Bool, HikebeatError> {
    return Future { complete in
        var header = ""
        switch type {
        case MediaType.image: header = MediaUploadHeader.image
        case MediaType.video: header = MediaUploadHeader.video
        case MediaType.audio: header = MediaUploadHeader.audio
        default: header = MediaUploadHeader.image
        }
        let headers = ["Content-type": header, "Cache-Control": "max-age=31536000"]
        Alamofire.upload(path, to: signedUrl, method: .put, headers: headers).uploadProgress { uploadProg in
            let fraction = uploadProg.fractionCompleted
            progressCallback(Float(fraction))
        }.responseJSON { mediaResponse in
            print("response: ", mediaResponse.data?.base64EncodedString())
            print("Statuscode: ", mediaResponse.response?.statusCode)
            if mediaResponse.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                complete(.failure(.s3Upload))
            }
        }
    }
}

func createMediaOnAPI(journeyId: String, fileKey: String, timeCapture: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let url = IPAddress + "journeys/\(journeyId)/media"
        let parameters = [
            "timeCapture": timeCapture,
            "fileKey" : fileKey
        ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            if response.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                complete(.failure(.createMedia))
            }
        }
    }
}


