//
//  ViewController.swift
//  MyFirstSlideshow
//
//  Created by Charles Vu on 17/05/2017.
//  Copyright © 2017 Yoti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLConnectionDataDelegate {
    // Images under Creative Commons 
    // Images attributed to (in order) https://www.flickr.com/photos/_torne/
    // https://www.flickr.com/photos/chrisyarzab/
    // https://www.reddit.com/user/lalien42/
    // http://www.kapstadt.de/

    let images: Array<String> = ["https://c1.staticflickr.com/6/5615/15570202337_0e64f5046e_k.jpg",
                                 "https://c1.staticflickr.com/4/3169/2846544061_cb7c04b46f_b.jpg",
                                  "https://i.redd.it/d8q1wkgu1awy.jpg",
                                  "http://www.kapstadt.de/webcam.jpg"]

    var i: Int = 0
    var j: Int = 0

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!

    @IBOutlet var dots1: [UIView]?
    @IBOutlet var dots2: [UIView]?

    @IBAction func onButtonOneClicked(_ sender: UIButton) {
        let currentImage = images[i % 4]
        i += 1
        // the last url of the array changes every ~ 15 minutes
        let data = try! Data(contentsOf: URL(string: currentImage)!, options: .uncached)
        let image = UIImage(data: data)
        image1.image = image
        if i % 4 == 0 {
            dots1![0].backgroundColor = UIColor.green
            dots1![1].backgroundColor = UIColor.gray
            dots1![2].backgroundColor = UIColor.gray
            dots1![3].backgroundColor = UIColor.gray
        }
        if i % 4 == 1 {
            dots1![1].backgroundColor = UIColor.green
            dots1![0].backgroundColor = UIColor.gray
            dots1![2].backgroundColor = UIColor.gray
            dots1![3].backgroundColor = UIColor.gray
        }
        if i % 4 == 2 {
            dots1![2].backgroundColor = UIColor.green
            dots1![0].backgroundColor = UIColor.gray
            dots1![1].backgroundColor = UIColor.gray
            dots1![3].backgroundColor = UIColor.gray
        }
        if i % 4 == 3 {
            dots1![3].backgroundColor = UIColor.green
            dots1![1].backgroundColor = UIColor.gray
            dots1![2].backgroundColor = UIColor.gray
            dots1![0].backgroundColor = UIColor.gray
        }

    }

    @IBAction func onButtonTwoClicked(_ sender: UIButton) {
        let currentImage = images[j % 4]
        j += 1
        let data = try! Data(contentsOf: URL(string: currentImage)!, options: .uncached)
        let image = UIImage(data: data)
        image2.image = image

        if j % 4 == 0 {
            dots2![0].backgroundColor = UIColor.green
            dots2![1].backgroundColor = UIColor.gray
            dots2![2].backgroundColor = UIColor.gray
            dots2![3].backgroundColor = UIColor.gray
        }
        if j % 4 == 1 {
            dots2![1].backgroundColor = UIColor.green
            dots2![0].backgroundColor = UIColor.gray
            dots2![2].backgroundColor = UIColor.gray
            dots2![3].backgroundColor = UIColor.gray
        }
        if j % 4 == 2 {
            dots2![2].backgroundColor = UIColor.green
            dots2![1].backgroundColor = UIColor.gray
            dots2![0].backgroundColor = UIColor.gray
            dots2![3].backgroundColor = UIColor.gray
        }
        if j % 4 == 3 {
            dots2![3].backgroundColor = UIColor.green
            dots2![1].backgroundColor = UIColor.gray
            dots2![2].backgroundColor = UIColor.gray
            dots2![0].backgroundColor = UIColor.gray
        }
    }

    @IBAction func onImageTapped(_ sender: Any) {

    }
}

