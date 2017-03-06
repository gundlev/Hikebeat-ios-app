//
//  Calls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 02/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

func getCall(url: String, headers: [String: String]) -> Future<DataResponse<Any>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            guard successWith(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func postCall(url: String, parameters: [String: Any], headers: [String: String]) -> Future<DataResponse<Any>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            guard successWith(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func putCall(url: String, parameters: [String: Any], headers: [String: String]) -> Future<DataResponse<Any>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            guard successWith(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func deleteCall(url: String, headers: [String: String]) -> Future<DataResponse<Any>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            guard successWith(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func getDataCall(url: String) -> Future<DataResponse<Data>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url).responseData { response in
            
            guard successWithData(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func getImageCall(url: String) -> Future<DataResponse<UIImage>, HikebeatError> {
    return Future { complete in
        getSessionManager().request(url).responseImage {
            response in
            
            guard successWithImage(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            complete(.success(response))
        }
    }
}

func uploadMediaCall(path: URL, url: String, headers: [String: String]) -> Future<DataResponse<Any>, HikebeatError> {
    return Future { complete in
        
    }
}

// Utility functions

func getSessionManager() -> SessionManager {
    let manager = Alamofire.SessionManager.default
    manager.session.configuration.timeoutIntervalForRequest = 20
    return manager
}

func successWithData(response: DataResponse<Data>) -> Bool {
    switch (response.result) {
    case .success:
        return true
    case .failure(let error):
        if error._code == NSURLErrorTimedOut {
            print("\n\nRequest failed with error:\n \(error)")
        }
        print("\n\nAuth request failed with error:\n \(error)")
        print("response: ", response)
        return false
    }
}

func successWithImage(response: DataResponse<UIImage>) -> Bool {
    switch (response.result) {
    case .success:
        return true
    case .failure(let error):
        if error._code == NSURLErrorTimedOut {
            print("\n\nRequest failed with error:\n \(error)")
        }
        print("\n\nAuth request failed with error:\n \(error)")
        print("response: ", response)
        return false
    }
}

func successWith(response: DataResponse<Any>) -> Bool {
    switch (response.result) {
    case .success:
        return true
    case .failure(let error):
        if error._code == NSURLErrorTimedOut {
            print("\n\nRequest failed with error:\n \(error)")
        }
        print("\n\nAuth request failed with error:\n \(error)")
        return false
    }
}
