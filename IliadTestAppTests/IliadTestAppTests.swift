//
//  IliadTestAppTests.swift
//  IliadTestAppTests
//
//  Created by Samith on 18/07/23.
//

import XCTest
@testable import IliadTestApp

//let basePath = "http://restcountries.com/v3.1/"
//let allInformationUrlComponent = "all"
//let languageUrlComponent = "lang/"
//let currencyUrlComponent = "currency/"

final class IliadTestAppTests: XCTestCase {
    
    var countryViewModel: CountriesViewModel!

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let countriesViewController = storyboard.instantiateViewController(withIdentifier: "countriesViewController") as! CountriesViewController
        countryViewModel = CountriesViewModel(view: countriesViewController)
    }

    override func tearDown() {
        countryViewModel = nil
    }

    func testBasePathIsCorrect() {
        XCTAssertEqual(basePath, "http://restcountries.com/v3.1/")
    }
    
    func testAllInformationPathIsCorrect() {
        XCTAssertEqual(basePath + allInformationUrlComponent, "http://restcountries.com/v3.1/all")
    }
    
    func testLanguagePathIsCorrect() {
        XCTAssertEqual(basePath + languageUrlComponent, "http://restcountries.com/v3.1/lang/")
    }
    
    func testCurrencyPathIsCorrect() {
        XCTAssertEqual(basePath + currencyUrlComponent, "http://restcountries.com/v3.1/currency/")
    }

}
