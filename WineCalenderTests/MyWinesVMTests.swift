//
//  MyWinesVMTests.swift
//  WineCalenderTests
//
//  Created by Susan Kim on 2021/10/06.
//

import XCTest
@testable import WineCalender

class MyWinesVMTests: XCTestCase {
    
    let tastingNotes = WineTastingNotes(tastingDate: Date(timeIntervalSince1970: 1633504008),
                                        place: "Oomph",
                                        wineName: "파이니스트 모젤 리슬링",
                                        category: "White",
                                        varieties: ["Riesling 리슬링"],
                                        producingCountry: "Germany 독일",
                                        producer: nil, vintage: nil, price: nil, alcoholContent: 11,
                                        sweet: 1, acidity: 3, tannin: 3, body: 3,
                                        aromasAndFlavors: ["라임"],
                                        memo: nil,
                                        rating: 5)

    lazy var post = Post(postID: "-MlJQtDIa38wN9_bWWuG",
                         authorUID: "i5yIPNa6HwV7SyJ1Jz04JcdEAJI3",
                         postingDate: Date(timeIntervalSince1970: 1633504171),
                         updatedDate: nil,
                         postImageURL: ["https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/PostImage%2F-MlJQtDIa38wN9_bWWuG%2F-MlJQtDIa38wN9_bWWuG0.jpg?alt=media&token=91332640-18ee-4dfa-a25b-64728647afad"],
                         tastingNote: tastingNotes,
                         likeUIDs: nil,
                         comments: nil)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPost() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let vm = MyWinesViewModel(post: post)
        XCTAssertEqual(vm.firstImage, UIImage()) // 제안: nil
        XCTAssertEqual(vm.firstImageURL?.absoluteString, "https://firebasestorage.googleapis.com:443/v0/b/wine-calendar-3e6a1.appspot.com/o/PostImage%2F-MlJQtDIa38wN9_bWWuG%2F-MlJQtDIa38wN9_bWWuG0.jpg?alt=media&token=91332640-18ee-4dfa-a25b-64728647afad")
        XCTAssertEqual(vm.ratingDescription, "⭐️ 5")
        XCTAssertEqual(vm.tastingDateDescription, "🗓 2021. 10. 6.")
        XCTAssertEqual(vm.wineNameDescription, "🍷 파이니스트 모젤 리슬링")
    }
    
    func testNote() throws {
//        let vm = MyWinesViewModel(note: tastingNotes)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
