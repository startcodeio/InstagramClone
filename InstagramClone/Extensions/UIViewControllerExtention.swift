//
//  UIViewControllerExtention.swift
//  InstagramClone
//
//  Created by user on 17.11.2021.
//

import Foundation
import UIKit
import SVProgressHUD

enum TypeHUD {
    case loading
    case dismiss
    case error(text: String? = nil)
    case success(text: String? = nil)
    case info(text: String? = nil)
}

extension UIViewController {
    
    func showHUD(_ type: TypeHUD = .loading) {
        switch type {
        case .loading:
            view.isUserInteractionEnabled = false
            SVProgressHUD.show()
        case .dismiss:
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        case .error(let text):
            view.isUserInteractionEnabled = true
            SVProgressHUD.showError(withStatus: text)
        case .success(let text):
            view.isUserInteractionEnabled = true
            SVProgressHUD.showSuccess(withStatus: text)
        case .info(let text):
            view.isUserInteractionEnabled = true
            SVProgressHUD.showInfo(withStatus: text)
        }
    }
    
}
