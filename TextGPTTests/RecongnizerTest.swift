//
//  TextGPTTests.swift
//  TextGPTTests
//
//  Created by Ivan Kvyatkovskiy on 24/03/2023.
//

import XCTest
@testable import TextGPT

final class RecongnizerTests: XCTestCase {

    let sut = Recongnizer()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecognizesRequest() throws {
        let input =
        """
        /gpt
        What is your favourite color?
        """

        let r = sut.recognizeRequest(input)

        XCTAssertEqual(r?.request, "What is your favourite color?")
    }

    func testReturnsTextBefore() throws {
        let input =
        """
        The text before
        /gpt
        What is your favourite color?
        """

        let r = sut.recognizeRequest(input)

        XCTAssertEqual(r?.textBefore, "The text before\n")
    }


}
