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
                XCTFail("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchEmptyLikes() throws {
        PostManager.shared.fetchLikes(postUID: "-Mlisjt7-m5-yAZbp-_e") { result in
            switch result {
            case .success(let likes):
                XCTAssertEqual(likes.count, 0)
            case .failure(_):
                XCTFail("Fetch likes on post that has not been liked should return .success([])")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchUnavailablePost() throws {
        PostManager.shared.fetchLikes(postUID: "thisPostUidDoesNotExist") { result in
            switch result {
            case .success(let likes):
                XCTAssertEqual(likes.count, 0)
            case .failure(_):
                XCTFail("Fetch likes on invalid postUid should return .success([])")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testLike() throws {
        PostManager.shared.like(postUID: "-Mlnr5TxOP2gcOBtWht2") { result in
            switch result {
            case .success():
                break
            case .failure(_):
                XCTFail("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUnlike() throws {
        PostManager.shared.unlike(postUID: "-Mlnr5TxOP2gcOBtWht2") { result in
            switch result {
            case .success():
                break
            case .failure(_):
                XCTFail("Should succeed")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUnlikePostThatWasNeverLiked() throws {
        PostManager.shared.unlike(postUID: "Qru1IYtIvbRvRXU4t0yW4mfMNHO2") { result in
            switch result {
            case .success():
                break
            case .failure(_):
                XCTFail("Unlike should succeed whether or not user LIKEd the post before")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUnlikeUnavailablePost() throws {
        PostManager.shared.unlike(postUID: "thisPostUidDoesNotExist") { result in
            switch result {
            case .success():
                break
            case .failure(_):
                XCTFail("Unlike should succeed whether or not postUID is valid")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
