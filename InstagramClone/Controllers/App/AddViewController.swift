//
//  AddViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class AddViewController: UIViewController {
    
    // MARK: - Data
    
    private var image: UIImage?
    
    // MARK: - Views

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addLocationView: UIView!
    
    private lazy var pickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.delegate = self
        controller.videoMaximumDuration = 60
        return controller
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "New post"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareDidTapped))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageDidTapped)))
    }
    
    // MARK: - Actions
    
    @objc
    private func shareDidTapped() {
        showHUD()
        guard let image = image,
              let compressedImage = image.jpegData(compressionQuality: 0.4) else {
            self.showHUD(.error(text: "Load image"))
            return
        }
        
        let ref = Firestore.firestore().collection("posts").document()
        
            
        self.saveImage(id: ref.documentID, imageData: compressedImage) { imageURL in
            let post = Post(
                id: ref.documentID,
                image: imageURL,
                description: self.textView.text,
                author: Helpers.author,
                publishDate: Timestamp(date: Date())
            )
            self.savePostToFirestore(post, to: ref)
        }
    }
    
    @objc
    private func imageDidTapped() {
        presentAlert()
    }
    
    // MARK: - Methods
    
    private func savePostToFirestore(_ post: Post, to ref: DocumentReference) {
        do {
            try ref.setData(from: post)
            incrementUserPostsCounter(post.author.uid)
            removeFillData()
            showHUD(.success(text: "Post successfully created!"))
            tabBarController?.selectedIndex = 4
        } catch {
            showHUD(.error(text: error.localizedDescription))
        }
    }
    
    private func removeFillData() {
        imageView.image = UIImage(systemName: "camera")
        textView.text = "Write a caption..."
    }
    
    private func saveImage(id: String, imageData: Data, completion: @escaping(String) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let ref = Storage.storage().reference().child("posts/\(id).jpg")
        
        ref.putData(imageData, metadata: metadata, completion: { (_, error) in
            if let error = error {
                self.showHUD(.error(text: error.localizedDescription))
                return
            }
            ref.downloadURL(completion: { (url, _) in
                if let url = url?.absoluteString {
                    completion(url)
                }
            })
        })
    }
    
    private func incrementUserPostsCounter(_ uid: String) {
        Firestore.firestore().collection("users").document(uid).updateData(["counters.posts": FieldValue.increment(Int64(1))])
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .camera
            self.navigationController?.present(self.pickerController, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .photoLibrary
            self.navigationController?.present(self.pickerController, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        navigationController?.present(alert, animated: true)
    }

}

extension AddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.image = image
        imageView.image = image
        pickerController.dismiss(animated: true)
    }
    
}
