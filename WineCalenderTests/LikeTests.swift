//
//  LikeTests.swift
//  WineCalenderTests
//
//  Created by Susan Kim on 2021/10/29.
//

import XCTest
@testable import WineCalender

class LikeTests: XCTestCase {
    var expectation: XCTestExpectation = .init()
    
    override func setUpWithError() throws {
        expectation = XCTestExpectation(description: "Wait for result")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     Test normal post with 1+ likes
     */
    func testFetch() throws {
        PostManager.shared.fetchLikes(postUID: "-MlirZvFlitkC8nuvREN") { result in
            switch result {
            case .success(let likes):
                XCTAssertEqual(likes.count, 2, "Equal number of likes")
            case .failure(_):
                assertionFailure("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchEmptyLikes() throws {
        PostManager.shared.fetchLikes(postUID: "-MlirkwOA6TubyKTaR7s") { result in
            switch result {
            case .success(let likes):
                XCTAssertEqual(likes.count, 0)
            case .failure(_):
                assertionFailure("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)

    }
    
    func testFetchUnavailablePost() throws {
        PostManager.shared.fetchLikes(postUID: "aaaaaaa") { result in
            switch result {
            case .success(let likes):
                XCTAssertEqual(likes.count, 0)
            case .failure(_):
                assertionFailure("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
