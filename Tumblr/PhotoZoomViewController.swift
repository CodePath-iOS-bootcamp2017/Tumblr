//
//  PhotoZoomViewController.swift
//  Tumblr
//
//  Created by Satyam Jaiswal on 2/10/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

class PhotoZoomViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var post: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollview.delegate = self
        scrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
            if let postImageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String{
                if let postImageUrl = URL(string: postImageUrlString){
                    self.photoImageView.setImageWith(postImageUrl)
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
