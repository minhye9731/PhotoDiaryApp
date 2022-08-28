//
//  TabBarController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/28/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabBarController()
        setupTabBarAppearance()
        
    }
    
    func configureTabBarController() {
        let firstVC = HomeViewController()
        firstVC.tabBarItem.title = "홈"
        firstVC.tabBarItem.image = UIImage(systemName: "house")
        firstVC.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        let firstNav = UINavigationController(rootViewController: firstVC)
        
        let secondVC = SnapDetailViewController()
        secondVC.tabBarItem = UITabBarItem(title: "스냅킷", image: UIImage(systemName: "trash"), selectedImage: UIImage(systemName: "trash.fill"))
        
        let thirdVC = DetailViewController()
        thirdVC.title = "디테일"
        
        setViewControllers([firstNav, secondVC, thirdVC], animated: true)
    }
    
    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .red
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .black
    }
}


extension TabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }
    
}




