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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var posts: [NSDictionary] = []
    var profilePosterURL: URL = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
    var isMoreDataLoading: Bool = false
    var lastPostId = 0
    var loadingMoreProgressIndicator: InfiniteScrollActivityView?
    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        postTableView.rowHeight = UITableViewAutomaticDimension
        postTableView.estimatedRowHeight = 120
        
        let progressIndicatorFrame = CGRect(x: 0, y: self.postTableView.contentSize.height, width: self.postTableView.bounds.width, height: InfiniteScrollActivityView.defaultHeight)
        self.loadingMoreProgressIndicator = InfiniteScrollActivityView(frame: progressIndicatorFrame)
        loadingMoreProgressIndicator?.isHidden = true
        self.postTableView.addSubview(loadingMoreProgressIndicator!)
        
        var inset = self.postTableView.contentInset
        inset.bottom += (loadingMoreProgressIndicator?.bounds.height)!
        self.postTableView.contentInset = inset
        
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
    
    func loadMoreData(){
        let parameterString = "offset=\(self.posts.count)"
        let baseURLString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let urlString = "\(baseURLString)&\(parameterString)"
//        print(urlString)
        if let url = URL(string:urlString){
            let request = URLRequest(url: url)
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
            let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data{
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary{
                        if let additionalPosts = responseDictionary.value(forKeyPath: "response.posts") as? [NSDictionary]{
                            self.posts.append(contentsOf: additionalPosts)
                            
                            self.loadingMoreProgressIndicator?.stopAnimating()
                            self.postTableView.reloadData()
                            
                            self.isMoreDataLoading = false
                        }
                    }else{
                        print("json serialization error")
                    }
                }else{
                    print("data is nil")
                }
            })
            task.resume()
        }else{
            print("url is nil")
        }
        
    }
    
    
    // override table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.posts.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = self.posts[indexPath.section]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary]{
//            print("got photos")
            if let postImageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String{
//                print("got original_size.url")
                if let postImageUrl = URL(string: postImageUrlString){
//                    print("convert string to url")
                    cell.postPosterImageView.setImageWith(postImageUrl)
                    
                }
            }
            
        }
        /*
        if let name = post.value(forKeyPath: "blog_name") as? String{
            cell.usernameLabel.text = name
        }
        */
        
        if let caption = post.value(forKeyPath: "caption") as? String{
            cell.captionLabel.text = caption
        }
        
//        cell.profilePosterImageView.layer.cornerRadius = 25
//        cell.profilePosterImageView.layer.masksToBounds = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.postTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let label = UILabel()
        label.frame = CGRect(x: 45, y: 10, width: 500, height: 30)
//        label.clipsToBounds = true
        label.text = "humansofnewyork"
        label.textColor = UIColor.black
        let fontSize: CGFloat = 15.0
        label.font = label.font.withSize(fontSize)
        headerView.addSubview(label)
        
        
        if let date = self.posts[section].value(forKey: "date") as? String{
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: 250, y: 10, width: 200, height: 30)
            //        label.clipsToBounds = true
            dateLabel.text = date
            dateLabel.textColor = UIColor.gray
            let dateFontSize: CGFloat = 12.0
            dateLabel.font = dateLabel.font.withSize(dateFontSize)
            headerView.addSubview(dateLabel)
        }
        
    
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // overriding scrollViewDelegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            let scrollViewHeight = self.postTableView.contentSize.height
            let tableViewHeight = self.postTableView.bounds.height
            
            let loadMoreThresholdPosition = scrollViewHeight - tableViewHeight
            
            if(scrollView.contentOffset.y > loadMoreThresholdPosition && scrollView.isDragging){
                self.isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: self.postTableView.contentSize.height, width: self.postTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                self.loadingMoreProgressIndicator?.frame = frame
                self.loadingMoreProgressIndicator!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? PostTableViewCell{
            if let selectedCellIndex = self.postTableView.indexPath(for: cell){
                if let detailsViewController = segue.destination as? DetailsViewController{
                    detailsViewController.post = self.posts[selectedCellIndex.section]
                }
            }
        }
    }
    

}
