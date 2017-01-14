//
//  UploadMediaTests.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 06/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import XCTest

@testable import Hikebeat

class UploadMediaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testGetSignedUrl() {
//        let expectation = self.expectation(description: "signedUrl recieved")
//        
//        getSignedUrlAndId(type: MediaType.image).onSuccess { (tuple) in
//            XCTAssert(tuple.signedUrl != "", "SignedUrl is empty")
//            XCTAssert(tuple.id != "", "Id is empty")
//            expectation.fulfill()
//        }.onFailure { (error) in
//            XCTFail("Failed with error: \(error)")
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 3) { (error) in
//            print("Timeout with error: \(error)")
//        }
//    }
    
    func testUploadImage() {
        
        // SETUP: Save test image to docs
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let testImage = #imageLiteral(resourceName: "testUploadImage")
        let testPath = "/testUploadImage.jpg"
        let fm = FileManager()
        let folderPath = documentsDirectory.appending(testPath)
        if fm.fileExists(atPath: folderPath) {
            print("file aldready exists")
        }else {
            let saveImageExp = expectation(description: "save image expectation")
            saveImageToDocs(fileName: testPath, image: testImage).onSuccess { (success) in
                if success {
                    saveImageExp.fulfill()
                } else {
                    XCTFail("Failed to save image")
                    saveImageExp.fulfill()
                }
            }
            waitForExpectations(timeout: 10) { (error) in
                XCTFail("Failed with error: \(error)")
            }

        }
        
        // 1. Get signed URL
        let signedUrlExp = self.expectation(description: "signedUrl recieved")
        var signedUrl = ""
        var fileKey = ""
        getSignedUrlAndId(type: MediaType.image).onSuccess { (tuple) in
            XCTAssert(tuple.signedUrl != "", "SignedUrl is empty")
            XCTAssert(tuple.id != "", "Id is empty")
            signedUrl = tuple.signedUrl
            fileKey = tuple.id
            signedUrlExp.fulfill()
        }.onFailure { (error) in
                XCTFail("Failed get signedUrl with error: \(error)")
                signedUrlExp.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            print("Timeout with error: \(error)")
        }
        
        // 2. Upload to S3
        let uploadExp = self.expectation(description: "signedUrl recieved")
        uploadToS3(signedUrl: signedUrl, path: URL(fileURLWithPath: documentsDirectory.appending(testPath)), type: MediaType.image) { (progress) in
            print("Progress: ", progress)
        }.onSuccess { (success) in
            uploadExp.fulfill()
        }.onFailure { (error) in
            XCTFail("Failed upload with error: \(error)")
            uploadExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print("Timeout with error: \(error)")
        }
        
        // 3. Create media to API
        let testUploadJourneyId = "5870380e31b08400129be9ad"
        let t = String(Date().timeIntervalSince1970)
        let e = t.range(of: ".")
        let timestamp = t.substring(to: (e?.lowerBound)!)
        let createExp = self.expectation(description: "signedUrl recieved")
        createMediaOnAPI(journeyId: testUploadJourneyId, fileKey: fileKey, timeCapture: timestamp).onSuccess { (success) in
            createExp.fulfill()
        }.onFailure { (error) in
            XCTFail("Failed upload with error: \(error)")
            createExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print("Timeout with error: \(error)")
        }
        XCTAssert(true)
    }
}
