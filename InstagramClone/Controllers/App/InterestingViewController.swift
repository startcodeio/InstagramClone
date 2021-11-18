//
//  InterestingViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseFirestore

class InterestingViewController: UIViewController {
    
    // MARK: - Data
    
    private var posts: [Post] = []
    
    // MARK: - Views

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        fetchPosts()
    }
    
    // MARK: - Methods
    
    private func fetchPosts() {
        let ref = Firestore.firestore().collection("posts")
        ref.getDocuments { querySnapshot, error in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showHUD(.error(text: "Documents not found"))
                return
            }
            
            for document in documents {
                do {
                    let post = try document.data(as: Post.self)
                    self.posts.append(post!)
                } catch {
                    print("error with \(document.documentID) \(error)")
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        navigationItem.title = "Interesting"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostGridCollectionViewCell")
    }

}

extension InterestingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
}

extension InterestingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostGridCollectionViewCell", for: indexPath) as! PostGridCollectionViewCell
        
        if posts.count > indexPath.row {
            let post = posts[indexPath.row]
            cell.setup(post)
        }
        
        return cell
    }
    
}

extension InterestingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
