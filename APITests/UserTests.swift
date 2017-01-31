//
//  UserTests.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 27/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import XCTest
import BrightFutures

@testable import Hikebeat


class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRefreshToken() {
        let tokenExp = self.expectation(description: "Search expectation")
        refreshToken()
        .onSuccess { (token) in
            XCTAssert(true)
            tokenExp.fulfill()
        }.onFailure { (error) in
            XCTFail(error.localizedDescription)
            tokenExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print("Timeout with error: \(error)")
        }
    }
}
