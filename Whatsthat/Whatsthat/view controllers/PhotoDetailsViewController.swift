//
//  PhotoDetailsViewController.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/9/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import UIKit
import SafariServices

class PhotoDetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var titleFromTableView = String()
    var image : UIImage?
    var url = URL(string : "https://en.wikipedia.org/")!
    let wikipediaAPiManager =  WikipediaAPIManager()
    
    @IBOutlet weak var webView: UIWebView!
    @IBAction func onSharePressed(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [self.url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func onTweetsPressed(_ sender: Any) {
        performSegue(withIdentifier: "TwitterSegue", sender: self)
    }
    
    @IBAction func openContentInSafari(_ sender: Any) {
        let safariVC = SFSafariViewController(url: self.url)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    func getWikipediaResult (title : String) {
        wikipediaAPiManager.getWikiDescription(title: title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let favoriteButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(PhotoDetailsViewController.saveButton))
        
        let unFavoriteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(PhotoDetailsViewController.deleteButton))
        
        navigationItem.rightBarButtonItems = [unFavoriteButton, favoriteButton]
        wikipediaAPiManager.delegate = self
        getWikipediaResult(title: self.titleFromTableView)
    }
    @objc func saveButton(sender: UIBarButtonItem){
        if let imagedata = self.image {
            let path = "\(self.titleFromTableView)\(UUID().uuidString).jpg"
            let favorite = Favorite(title: self.titleFromTableView, pathToImage: path)
            if PersistanceManager.sharedInstance.saveToFavorites(favorite: favorite) {
                PersistanceManager.sharedInstance.saveImageInDocumentDirectory(fileName: path, image: imagedata)
            }
        }
    }
    
    @objc func deleteButton(sender: UIBarButtonItem){
        PersistanceManager.sharedInstance.deleteFromFavorites(title: titleFromTableView)
    }
}

extension PhotoDetailsViewController : WikipediaResultDelegate {
    func wikipediaResultFound(wikipediaResult: WikipediaResult) {
        self.url = URL(string : "https://en.wikipedia.org/?curid=\(wikipediaResult.pageid)")!
        DispatchQueue.main.async {
            self.webView.loadHTMLString(wikipediaResult.extract, baseURL: nil)
        }
        
    }
    
    func wikipediaResultNotFound(reason: WikipediaAPIManager.FailureReason) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "Problem fetching wikipedia results", message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .networkRequestFailed:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.getWikipediaResult(title: self.titleFromTableView)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .badJSONResponse, .noData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TwitterSegue" {
            if let searchTimelineViewController = segue.destination as? SearchTimelineViewController {
                searchTimelineViewController.twiiterTitle = titleFromTableView
            }
        }
    }
    
}

