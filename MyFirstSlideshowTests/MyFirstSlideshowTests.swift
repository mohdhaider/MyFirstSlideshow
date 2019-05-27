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
    
    var fetchExpectations: [XCTestExpectation]!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        fetchExpectations = [XCTestExpectation]()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        fetchExpectations.removeAll()
    }
    
    func testImagesDownloading() {
        
        let viewModel = ImagesViewModel()
        viewModel.prpareDataSource()
        
        for (index, model) in viewModel.arrImages.enumerated() {

            if let imageUrl = model.imageUrlString,
                !imageUrl.isEmpty {
                
                XCTContext.runActivity(named: "Image: \(imageUrl)") { _ in
                    
                    waitForTimeout(for: 30,
                                   callback: { (expectation) in
                                    self.fetchExpectations.append(expectation)
                                    
                                    self.get(imageAtURLString: imageUrl,
                                             completionBlock: { (image) in
                                                
                                                XCTAssertNotNil(image)
                                                
                                                ImageCache.shared.fetchImage(
                                                    forKey: imageUrl,
                                                    completionBlock: { (image) in
                                                        
                                                        XCTAssertNotNil(image)
                                                        
                                                        let attachment = XCTAttachment(image: image!)
                                                        attachment.lifetime = .keepAlways
                                                        self.add(attachment)
                                                        
                                                        self.fetchExpectations[index].fulfill()
                                                })
                                    })
                    })
                }
            }
        }
    }
}
