//
//  MyFirstSlideshowUITests.swift
//  MyFirstSlideshowUITests
//
//  Created by Mohd Haider on 27/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import XCTest

class MyFirstSlideshowUITests: XCTestCase {

    var application:XCUIApplication!
    
    override func setUp() {
        
        XCTContext.runActivity(named: "App Launch") { _ in
            
            continueAfterFailure = false
            
            application = XCUIApplication()
            application.launch()
        }
    }

    override func tearDown() {
        
        application = nil
    }

    func testExample() {
        
        
        XCTContext.runActivity(named: "Images Screen") { _ in
            
            let nextbuttonButton = application/*@START_MENU_TOKEN@*/.buttons["nextButton"]/*[[".buttons[\"   next   \"]",".buttons[\"nextButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            
            waitForVisible(nextbuttonButton, timeout: 3)
            
            XCTContext.runActivity(named: "Next Button Appear", block: { _ in

                XCTContext.runActivity(named: "Tapping Next Button", block: { _ in
                    
                    nextbuttonButton.tap()
                    nextbuttonButton.tap()
                    nextbuttonButton.tap()
                    nextbuttonButton.tap()
                })
            })
            
            let previousbuttonButton = application/*@START_MENU_TOKEN@*/.buttons["previousButton"]/*[[".buttons[\"   prev   \"]",".buttons[\"previousButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            
            XCTContext.runActivity(named: "Previous Button Appear", block: { _ in
                
                XCTContext.runActivity(named: "Tapping Previous Button", block: { _ in
                    
                    previousbuttonButton.tap()
                    previousbuttonButton.tap()
                    previousbuttonButton.tap()
                })
            })

            XCTContext.runActivity(named: "Rotating landscape and moving through images", block: { _ in

                nextbuttonButton.tap()
                
                XCUIDevice.shared.orientation = .landscapeRight
                
                nextbuttonButton.tap()
                previousbuttonButton.tap()
            })
            
            XCTContext.runActivity(named: "Rotating portrait and moving through images", block: { _ in
                
                XCUIDevice.shared.orientation = .portrait
                
                previousbuttonButton.tap()
                previousbuttonButton.tap()
            })
        }
    }
}
