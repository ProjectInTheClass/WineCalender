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
        let vm = MyWinesHeaderViewModel(user: user, posts: 3)
        
        XCTAssertEqual(vm.profileImageURL?.absoluteString, "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/ProfileImage%2Fi5yIPNa6HwV7SyJ1Jz04JcdEAJI3.jpg?alt=media&token=042ce1d8-44a2-46bd-afa3-a35b164fc1c4")
        XCTAssertEqual(vm.nickname, "suzennk")
        XCTAssertEqual(vm.introduction, nil)
        XCTAssertEqual(vm.numberOfPosts, "3")
    }

    /**
     팔로워수가 4자리수 이상일 때 포맷팅 확인
     */
    func testFormatNumberOfPosts() throws {
        // 3자리(xxx)
        let vm3 = MyWinesHeaderViewModel(user: user, posts: 123)
        XCTAssertEqual(vm3.numberOfPosts, "123")
        
        // 4자리(x,xxx)
        let vm4 = MyWinesHeaderViewModel(user: user, posts: 1234)
        XCTAssertEqual(vm4.numberOfPosts, "1,234")
        
        // 5자리(x만)
        let vm5 = MyWinesHeaderViewModel(user: user, posts: 12345)
        XCTAssertEqual(vm5.numberOfPosts, "1만")
        
        // 6자리(xx만)
        let vm6 = MyWinesHeaderViewModel(user: user, posts: 123456)
        XCTAssertEqual(vm6.numberOfPosts, "12만")
        
        // 7자리(xxx만)
        let vm7 = MyWinesHeaderViewModel(user: user, posts: 1234567)
        XCTAssertEqual(vm7.numberOfPosts, "123만")
        
        // 8자리(x,xxx만)
        let vm8 = MyWinesHeaderViewModel(user: user, posts: 12345678)
        XCTAssertEqual(vm8.numberOfPosts, "1,234만")
        
        // 9자리(x억)
        let vm9 = MyWinesHeaderViewModel(user: user, posts: 123456789)
        XCTAssertEqual(vm9.numberOfPosts, "1억")
        
        // 10자리(xx억)
        let vm10 = MyWinesHeaderViewModel(user: user, posts: 1234567890)
        XCTAssertEqual(vm10.numberOfPosts, "12억")
        
        // 13자리(xx,xxx억)
        let vm13 = MyWinesHeaderViewModel(user: user, posts: 1234567890123)
        XCTAssertEqual(vm13.numberOfPosts, "12,345억")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
