//
//  MyFirstSlideshowTests.swift
//  MyFirstSlideshowTests
//
//  Created by Charles Vu on 17/05/2017.
//  Copyright © 2017 Yoti. All rights reserved.
//

import XCTest
@testable import MyFirstSlideshow

class MyFirstSlideshowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImagesDownloading() {
        
        var fetchExpectations = [XCTestExpectation]()
        
        let viewModel = ImagesViewModel()
        viewModel.prpareDataSource()
        
        for (index, model) in viewModel.arrImages.enumerated() {

            if let imageUrl = model.imageUrlString,
                !imageUrl.isEmpty {
                
                XCTContext.runActivity(named: "Image: \(imageUrl)") { _ in
                    
                    let waitExpectation = expectation(description: "Waiting: \(imageUrl)")

                    fetchExpectations.append(waitExpectation)
                    
                    self.get(imageAtURLString: imageUrl,
                             completionBlock: { (image) in
                                
                                ImageCache.shared.fetchImage(
                                    forKey: imageUrl,
                                    completionBlock: { (image) in
                                        if image != nil {
                                            fetchExpectations[index].fulfill()
                                        }
                                })
                    })
                }
            }
        }
     
        let timeOut = TimeInterval(viewModel.arrImages.count * 10)
        
        let result = XCTWaiter.wait(for: fetchExpectations,
                       timeout: timeOut)
        
        XCTContext.runActivity(named: "Result") { _ in
            
            switch result {
            case .completed:
                print("completed")
            case .interrupted:
                print("interrupted")
            case .timedOut:
                print("timedOut")
            default:
                print("none")
            }
        }
    }
}
