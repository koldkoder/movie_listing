//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Kushal Bhatt on 9/12/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _displayMovieDetail()
    }
    
    func _displayMovieDetail() {
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        let imageUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        posterImageView.setImageWithURL(imageUrl)
        _displayHighResolutionImageUrl()
        
    }

    func _displayHighResolutionImageUrl() {
        let alternateIds = movie["alternate_ids"] as? NSDictionary
        let imdbId = alternateIds?["imdb"] as? String
        if let imdbId = imdbId {
            let imdbUrl = NSURL(string:"http://www.omdbapi.com/?i=tt\(imdbId)&plot=full&r=json")!
            let imdbUrlRequest = NSURLRequest(URL: imdbUrl)
            NSURLConnection.sendAsynchronousRequest(imdbUrlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                
                if let _ = error {
                    return
                }
                if let data = data {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
                    
                    if let responseDictionary = responseDictionary {
                        let imageUrl = responseDictionary["Poster"] as? String
                        if let imageUrl = imageUrl {
                            let highResImageUrl = NSURL(string: imageUrl)!
                            self._delay(0.5) {
                                self.posterImageView.setImageWithURL(highResImageUrl)
                            }
                        }
                    }
                }

            }
        }
    }
    
    func _delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
