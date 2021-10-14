//
//  PostThumbnailVMTests.swift
//  WineCalenderTests
//
//  Created by Susan Kim on 2021/10/06.
//

import XCTest
@testable import WineCalender

class PostThumbnailVMTests: XCTestCase {
    let tastingNotes = WineTastingNotes(tastingDate: Date(timeIntervalSince1970: 1633504008), place: "Oomph", wineName: "파이니스트 모젤 리슬링", category: "White", varieties: ["Riesling 리슬링"], producingCountry: "Germany 독일", producer: nil, vintage: nil, price: nil, alcoholContent: 11, sweet: 1, acidity: 3, tannin: 3, body: 3, aromasAndFlavors: ["라임"], memo: nil, rating: 5)

    lazy var post = Post(postID: "-MlJQtDIa38wN9_bWWuG",
                         authorUID: "i5yIPNa6HwV7SyJ1Jz04JcdEAJI3",
                         postingDate: Date(timeIntervalSince1970: 1633504171),
                         updatedDate: nil,
                         postImageURL: ["https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/PostImage%2F-MlJQtDIa38wN9_bWWuG%2F-MlJQtDIa38wN9_bWWuG0.jpg?alt=media&token=91332640-18ee-4dfa-a25b-64728647afad"],
                         tastingNote: tastingNotes,
                         likeUIDs: nil,
                         comments: nil)
    
    let user = User(uid: "i5yIPNa6HwV7SyJ1Jz04JcdEAJI3", email: "suzennk@test.com", profileImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/ProfileImage%2Fi5yIPNa6HwV7SyJ1Jz04JcdEAJI3.jpg?alt=media&token=042ce1d8-44a2-46bd-afa3-a35b164fc1c4"), nickname: "suzennk", introduction: nil)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let vm = PostThumbnailVM(post, user.nickname, user.profileImageURL, .red)
        XCTAssertEqual(vm.profileImageURL?.absoluteString, "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/ProfileImage%2Fi5yIPNa6HwV7SyJ1Jz04JcdEAJI3.jpg?alt=media&token=042ce1d8-44a2-46bd-afa3-a35b164fc1c4")
        XCTAssertEqual(vm.postMainText, "파이니스트 모젤 리슬링")
        XCTAssertEqual(vm.postSubText, "")
        XCTAssertEqual(vm.postSubTextIsHidden, true)
        XCTAssertEqual(vm.thumbnailImageURL?.absoluteString, "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/PostImage%2F-MlJQtDIa38wN9_bWWuG%2F-MlJQtDIa38wN9_bWWuG0.jpg?alt=media&token=91332640-18ee-4dfa-a25b-64728647afad")
        XCTAssertEqual(vm.userName, "suzennk")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
