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
    var pageId = Int64()
    let wikipediaAPiManager =  WikipediaAPIManager()
    
    @IBOutlet weak var webView: UIWebView!
    @IBAction func onSharePressed(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [textField.text!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func openContentInSafari(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: "https://en.wikipedia.org/?curid=\(self.pageId)")!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    func getWikipediaResult (title : String) {
        wikipediaAPiManager.getWikiDescription(title: title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wikipediaAPiManager.delegate = self
        getWikipediaResult(title: self.titleFromTableView)
    }
    
}

extension PhotoDetailsViewController : WikipediaResultDelegate {
    func wikipediaResultFound(wikipediaResult: WikipediaResult) {
        self.pageId = wikipediaResult.pageid
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
}

