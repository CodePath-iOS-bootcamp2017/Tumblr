//
//  HomeViewController.swift
//  Tumblr
//
//  Created by Satyam Jaiswal on 2/2/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//


import UIKit
import AFNetworking
import SVProgressHUD

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts: [NSDictionary] = []
    var profilePosterURL: URL = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        postTableView.rowHeight = UITableViewAutomaticDimension
        postTableView.estimatedRowHeight = 120
        
        loadFromNetwork()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.postTableView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(_ refreshControl: UIRefreshControl){
        loadFromNetwork()
        refreshControl.endRefreshing()
    }
    
    func loadFromNetwork(){
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        SVProgressHUD.show()
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
//                        print("responseDictionary: \(responseDictionary)")
            
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.postTableView.reloadData()
                        
                    }
                    SVProgressHUD.dismiss()
                }
        });
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = self.posts[indexPath.row]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
//            print("got photos")
            if let postImageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String{
//                print("got original_size.url")
                if let postImageUrl = URL(string: postImageUrlString){
//                    print("convert string to url")
                    cell.postPosterImageView.setImageWith(postImageUrl)
                    cell.profilePosterImageView.setImageWith(self.profilePosterURL)
                }
            }
            
        }
        
        if let name = post.value(forKeyPath: "blog_name") as? String{
            cell.usernameLabel.text = name
        }
        
        if let caption = post.value(forKeyPath: "caption") as? String{
            cell.captionLabel.text = caption
        }
        
        cell.profilePosterImageView.layer.cornerRadius = 25
        cell.profilePosterImageView.layer.masksToBounds = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.postTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? PostTableViewCell{
            if let selectedCellIndex = self.postTableView.indexPath(for: cell){
                if let detailsViewController = segue.destination as? DetailsViewController{
                    detailsViewController.post = self.posts[selectedCellIndex.row]
                }
            }
        }
    }
    

}
