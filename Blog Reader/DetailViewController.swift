//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Georgy Khaydenko on 04.02.18.
//  Copyright © 2018 Georgy Khaydenko. All rights reserved.
//

import UIKit

//setup paths to save htmls
var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [AnyObject]

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var webView: UIWebView!

    
    
    func configureView() {
        // Update the user interface for the detail item.
        if detailDescriptionLabel != nil {
            

            
            if let detail = detailItem {
                if let label = detailDescriptionLabel {
                    label.text = detail.title
                }
                
                let filePathToLoad : String = "\(paths[0])/\(detail.postID!)\(".html")"
                
                print(filePathToLoad)
                
                // Load file in UIWebView
                webView.loadRequest(URLRequest(url: URL(fileURLWithPath: filePathToLoad)))
               
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

