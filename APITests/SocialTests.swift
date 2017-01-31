//
//  SocialTests.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 15/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import XCTest
import BrightFutures

@testable import Hikebeat

class SocialTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSearchUsers() {
        let searchExp = self.expectation(description: "Search expectation")
        let search = Search(type: .user)
        search.startSearch(searchText: "o")
        .onSuccess { (users) in
            searchExp.fulfill()
        }.onFailure { (error) in
            print("Error: ", error)
            XCTAssert(false)
            searchExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print("Timeout with error: \(error)")
        }
        
        let nextExp = self.expectation(description: "Search expectation")
        search.nextPage()
        .onSuccess { (users) in
            nextExp.fulfill()
        }.onFailure { (error) in
            print("Error: ", error)
            XCTAssert(false)
            nextExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print("Timeout with error: \(error)")
        }
    }
    
}
