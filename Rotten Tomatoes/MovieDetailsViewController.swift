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
    @IBOutlet weak var movieDetailTextView: UITextView!
    @IBOutlet weak var movieDetailNavItem: UINavigationItem!
    
    var movie : NSDictionary!
    var popUpTextPosition: CGRect?
    var popDownTextPosition:CGRect?
    var texViewUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _displayMovieDetail()
    }
 
    
    func _displayMovieDetail() {
       
        movieDetailTextView.text = movie["synopsis"] as? String
        movieDetailNavItem.title = movie["title"] as? String
        texViewUp = false
        _setPopupPositions()
        _addGestures()
        let imageUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        posterImageView.setImageWithURL(imageUrl)
        _displayHighResolutionImageUrl()
        

        
    }
    

    func _displayHighResolutionImageUrl() {
        let alternateIds = movie["alternate_ids"] as? NSDictionary
        let imdbId = alternateIds?["imdb"] as? String
        if let imdbId = imdbId {
            let imdbUrl = NSURL(string:"http://www.omdbapi.com/?i=tt\(imdbId)&plot=full&r=json")!
            let imdbUrlRequest = NSURLRequest(URL: imdbUrl,  cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
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
                            let highResImageUrlRequest = NSURLRequest(URL: highResImageUrl, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
                                self.posterImageView.setImageWithURLRequest(highResImageUrlRequest, placeholderImage: nil, success: { (req, res, image) -> Void in
                                    self.posterImageView.image = image
                                    self.posterImageView.alpha = 0.3
                                    UIView.animateWithDuration(1, animations: { () -> Void in
                                        self.posterImageView.alpha = 1
                                    })
                                    }, failure: { (req, res, err) -> Void in
                                    NSLog("Error loading high res poster")
                                })
                            
                        }
                    }
                }

            }
        }
    }
    
    func _setPopupPositions() {
        popDownTextPosition = movieDetailTextView.frame
        let contentHeight = movieDetailTextView.contentSize.height
        let popupWidth = movieDetailTextView.frame.width
        let popupHeight = contentHeight < view.frame.height * 0.6 ? contentHeight : view.frame.height * 0.6
        let popupOriginY = view.frame.height - popupHeight
        let popupOriginX = movieDetailTextView.frame.origin.x
        popUpTextPosition = CGRectMake(popupOriginX, popupOriginY, popupWidth, popupHeight)
    }
    
    func _addGestures() {
        let tapGuesture = UITapGestureRecognizer(target: self, action: "_slideTextView")
        movieDetailTextView.addGestureRecognizer(tapGuesture)
    }
    
    
    func _slideTextView() {
        var targetPostion = popUpTextPosition
        
        if (texViewUp) {
            targetPostion = popDownTextPosition
        }
        UIView.animateWithDuration(1, delay:0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: UIViewAnimationOptions.CurveLinear, animations:({
            self.movieDetailTextView.frame = targetPostion!
        }),completion: nil)
        texViewUp = !texViewUp
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
