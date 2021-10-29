//
//  LikeTests.swift
//  WineCalenderTests
//
//  Created by Susan Kim on 2021/10/29.
//

import XCTest
@testable import WineCalender

class LikeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        PostManager.shared.fetchLikes(postUID: "-MlirZvFlitkC8nuvREN") { result in
            switch result {
            case .success(let postLike):
                print(postLike)
                XCTAssertEqual(postLike.likes.count, 2)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
