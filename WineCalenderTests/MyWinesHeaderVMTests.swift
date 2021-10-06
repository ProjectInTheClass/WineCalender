//
//  MyWinesHeaderVMTests.swift
//  WineCalenderTests
//
//  Created by Susan Kim on 2021/10/06.
//

import XCTest
@testable import WineCalender

class MyWinesHeaderVMTests: XCTestCase {
    
    let user = User(uid: "i5yIPNa6HwV7SyJ1Jz04JcdEAJI3", email: "suzennk@test.com", profileImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/ProfileImage%2Fi5yIPNa6HwV7SyJ1Jz04JcdEAJI3.jpg?alt=media&token=042ce1d8-44a2-46bd-afa3-a35b164fc1c4"), nickname: "suzennk", introduction: nil)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let vm = MyWinesHeaderViewModel(user: user, num: 3)
        XCTAssertEqual(vm.profileImageURL?.absoluteString, "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/ProfileImage%2Fi5yIPNa6HwV7SyJ1Jz04JcdEAJI3.jpg?alt=media&token=042ce1d8-44a2-46bd-afa3-a35b164fc1c4")
        XCTAssertEqual(vm.nickname, "suzennk")
        XCTAssertEqual(vm.introduction, nil)
        XCTAssertEqual(vm.numberOfPosts, "3 게시물")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
