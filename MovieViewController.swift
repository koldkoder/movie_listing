//
//  MovieViewController.swift
//  Rotten Tomatoes
//
//  Created by Kushal Bhatt on 9/12/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD



class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var alertMessage : String?
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        moviesSearchBar.delegate = self
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        _addRefreshControl()
        _fetchMovies()

    }
    
    func _addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "_onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func _fetchMovies() {
        
        let apiKey = "dagqdghwaq3e3mxyrp7kmmj5"
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=\(apiKey)&limit=20")!
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    self.alertMessage = "Network Error"
                }
            }
            
            if let _ = error {
                self.alertMessage = "Newtork Error!"
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                return
            }
            if let data = data {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
                if let responseDictionary = responseDictionary {
                    self.movies = responseDictionary["movies"] as? [NSDictionary]
                    self.movies?.shuffle()
                    self.alertMessage = nil
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
            }
            
        }
    }
    
    
    func _onRefresh() {
        _fetchMovies()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            if let filteredMovies = filteredMovies {
                return filteredMovies.count
            }
        } else {
            if let movies = movies {
                return movies.count
            }
        }
        
        return 0;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        var movie = movies![indexPath.row]
        if searchActive {
            movie = filteredMovies![indexPath.row]
        }
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let imageUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        let imageUrlRequest = NSURLRequest(URL: imageUrl, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        cell.posterView.setImageWithURLRequest(imageUrlRequest, placeholderImage: nil,
            success: {(req, res, image) -> Void in
                cell.posterView.image = image
                cell.posterView.alpha = 0.1;
                UIView.animateWithDuration(1, animations: { () -> Void in
                    cell.posterView.alpha = 1
                    
                })
            },
            failure: {(req, res, err) -> Void in
                NSLog("Image loading failed!!!!")
            }
        )
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  alertHeaderCell = tableView.dequeueReusableCellWithIdentifier("AlertHeaderCell") as! AlertHederCell
        alertHeaderCell.accessoryType = UITableViewCellAccessoryType.None
        if let alertMessage = alertMessage {
            alertHeaderCell.messageLabel.text = alertMessage
        }
        return alertHeaderCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = alertMessage {
            return 30.0
        }
        return 0.0
    }

    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies?.filter({ (movie) -> Bool in
            let movieTitle: NSString? = movie["title"] as? NSString
            if let movieTitle = movieTitle {
                let range = movieTitle.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            }
            return false
        })
        if(filteredMovies?.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        var movie = movies![indexPath.row]
        if searchActive {
            movie = filteredMovies![indexPath.row]
        }
        let movieDetailsController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsController.movie = movie
    }
    
}

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
