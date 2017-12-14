//
//  SearchTimeLineViewController.swift
//  Whatsthat
//
//  Created by Gouri Dutta on 12/11/17.
//  Copyright © 2017 Gouri Dutta. All rights reserved.
//

import UIKit
import TwitterKit

class SearchTimelineViewController: TWTRTimelineViewController {
    var twiiterTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Twitter.sharedInstance().start(withConsumerKey:"69C8fxBNnL5UnoKUiDyQVJMoU", consumerSecret:"3SfitHuHIOUxhb6afaD1Xp2keWglNGdVM3W7HSRWHhPBtg3fDe")
        let client = TWTRAPIClient()
        if let title = twiiterTitle {
            self.dataSource = TWTRSearchTimelineDataSource(searchQuery: "#\(title)", apiClient: client)
        }
        
    }
    
    
}
