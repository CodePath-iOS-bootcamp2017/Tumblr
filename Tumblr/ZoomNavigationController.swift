//
//  ZoomNavigationController.swift
//  Tumblr
//
//  Created by Satyam Jaiswal on 2/10/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

class ZoomNavigationController: UINavigationController {

    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue in navi called")
        if let destinationViewController = segue.destination as? PhotoZoomViewController{
            destinationViewController.photoImageView.image = self.image
        }
    }
    */

}
