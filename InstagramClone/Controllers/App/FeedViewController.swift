//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Feed"
    }

}
