//
//  ActivitiesViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseFirestore

class ActivitiesViewController: UIViewController {
    
    // MARK: - Data
    
    private var models: [Activity] = []
    
    // MARK: - Views
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let emptyView = EmptyView(type: .activities)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        fetch()
    }
    
    // MARK: - Actions
    
    @objc
    private func refreshControlDidChanged() {
        models = []
        fetch()
    }

    // MARK: - Methods
    
    private func fetch() {
        let ref = Firestore.firestore().collection("activities")
            .whereField("toUid", isEqualTo: Helpers.uid).order(by: "publishDate", descending: true)
        ref.getDocuments { querySnapshot, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                self.refreshControl.endRefreshing()
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showHUD(.error(text: "Documents not found"))
                self.refreshControl.endRefreshing()
                return
            }
            
            for document in documents {
                do {
                    let model = try document.data(as: Activity.self)
                    self.models.append(model!)
                } catch {
                    print("error with \(document.documentID) \(error)")
                }
            }
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            
            if self.models.isEmpty {
                self.emptyView.isHidden = false
            }
        }
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        navigationItem.title = "Activities"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "ActivityTableViewCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlDidChanged), for: .valueChanged)
        
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            .isActive = true
        emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            .isActive = true
        emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            .isActive = true
        emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            .isActive = true
    }
    
}

// MARK: - TableView DataSource

extension ActivitiesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell") as! ActivityTableViewCell
        if models.count > indexPath.row {
            let model = models[indexPath.row]
            cell.setup(model)
        }
        return cell
    }
    
    
}

// MARK: - TableView Delegate

extension ActivitiesViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
        let model = models[indexPath.row]
        let activityType = ActivityType(rawValue: model.type)
        
        switch activityType {
        case .follow:
            let vc = ProfileViewController(uid: model.linkId)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case .like:
            print("like")
        case .comment:
            print("comment")
        case .none:
            print("none")
        }
    }
    
}

