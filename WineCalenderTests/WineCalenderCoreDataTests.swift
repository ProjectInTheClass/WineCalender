//
//  WineCalenderCoreDataTests.swift
//  WineCalenderCoreDataTests
//
//  Created by 강재권 on 2021/06/17.
//

import XCTest
@testable import WineCalender

class WineCalenderCoreDataTests: XCTestCase {
    let dm = DataManager.shared
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let originalCount = try? dm.mainContext.count(for: WineTastingNote.fetchRequest())

        let note = WineTastingNotes(tastingDate: Date(), place: "종로구", wineName: "용팔", category: "White", varieties: ["Merlot 메를로", "Malbec 말벡"], producingCountry: "Chile 칠레", producer: nil, vintage: "Non-Vintage", price: nil, alcoholContent: nil, sweet: 4, acidity: 2, tannin: 2, body: 2, aromasAndFlavors: ["블루베리", "키위", "아이리스", "토스트"], memo: "", rating: 5)

        dm.addWineTastingNote(tastingNote: note, images: [UIImage(named: "sj") ?? UIImage()])

        let newCount = try? dm.mainContext.count(for: WineTastingNote.fetchRequest())
        
        XCTAssertEqual(newCount ?? 0, (originalCount ?? 0) + 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
