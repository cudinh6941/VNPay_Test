//
//  VNpay_TestTests.swift
//  VNpay_TestTests
//
//  Created by pham kha dinh on 16/8/24.
//

import XCTest
@testable import VNpay_Test

class PicsumViewModelTests: XCTestCase {
    var viewModel: PicsumViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = PicsumViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchData() {
        let expectation = XCTestExpectation(description: "Fetch data from API")
        
        viewModel.reloadTableView = {
            XCTAssertFalse(self.viewModel.allItems.isEmpty)
            XCTAssertFalse(self.viewModel.filteredItems.isEmpty)
            XCTAssertEqual(self.viewModel.numberOfRows(), self.viewModel.filteredItems.count)
            XCTAssertTrue(self.viewModel.hasMorePages)
            expectation.fulfill()
        }
        
        viewModel.fetchData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFilterItems() {
        viewModel.allItems = [
            ImageItem(id: "1", author: "John", width: 200, height: 200, url: "", download_url: ""),
            ImageItem(id: "2", author: "Jane", width: 300, height: 300, url: "", download_url: "")
        ]
        
        viewModel.filterItems(with: "John")
        XCTAssertEqual(viewModel.numberOfRows(), 1)
        XCTAssertTrue(viewModel.isSearching)
        
        viewModel.filterItems(with: "")
        XCTAssertEqual(viewModel.numberOfRows(), 2)
        XCTAssertFalse(viewModel.isSearching)
    }
    
    func testDownloadImage() {
        let expectation = XCTestExpectation(description: "Download image")
        let urlString = "https://picsum.photos/200"
        
        viewModel.downloadImage(from: urlString) { image in
            XCTAssertNotNil(image)
            let cachedImage = ImageCache.shared.object(forKey: urlString as NSString)
            XCTAssertNotNil(cachedImage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
