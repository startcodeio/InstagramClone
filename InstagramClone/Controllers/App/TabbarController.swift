//
//  TabbarViewController.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        tabBar.tintColor = .label

        viewControllers = [
            createNavigationController(vc: FeedViewController(), title: "Feed", icon: "house"),
            createNavigationController(vc: InterestingViewController(), title: "Interesting", icon: "magnifyingglass"),
            createNavigationController(vc: AddViewController(), title: "Add", icon: "plus.viewfinder"),
            createNavigationController(vc: ActivitiesViewController(), title: "Activities", icon: "suit.heart"),
            createNavigationController(vc: ProfileViewController(), title: "profile", icon: "person"),
        ]
    }
    
    // MARK: - Methods
    
    private func createNavigationController(vc: UIViewController, title: String, icon systemIconName: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = UIImage(systemName: systemIconName)
        return navigationController
    }

}
