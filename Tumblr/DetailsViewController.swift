//
//  DetailsViewController.swift
//  Tumblr
//
//  Created by Satyam Jaiswal on 2/9/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    var post: NSDictionary!
    var profilePosterURL: URL = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
            if let postImageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String{
                if let postImageUrl = URL(string: postImageUrlString){
                    self.postImageView.setImageWith(postImageUrl)
                    self.profileImageView.setImageWith(self.profilePosterURL)
                    
                    let photoTapGesture = UITapGestureRecognizer()
                    photoTapGesture.addTarget(self, action: #selector(photoTapped))
                    self.postImageView.isUserInteractionEnabled = true
                    self.postImageView.addGestureRecognizer(photoTapGesture)
                }
            }
            
        }
        
        if let name = post.value(forKeyPath: "blog_name") as? String{
            self.usernameLabel.text = name
        }
        
        if let caption = post.value(forKeyPath: "caption") as? String{
            self.captionLabel.text = caption
        }
        
        self.profileImageView.layer.cornerRadius = 40
        self.profileImageView.layer.masksToBounds = true
    }
    
    func photoTapped(){
        performSegue(withIdentifier: "fullScreenSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullScreenSegue" {
            
            let zoomNavigationController = segue.destination as! ZoomNavigationController
            let photoZoomViewController = zoomNavigationController.viewControllers.first as?PhotoZoomViewController
            photoZoomViewController?.post = self.post
            
        }
    }
    

}
