//
//  BaseViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setConstraints()
    }
    
    
    func configure() {}
    
    func setConstraints() {}
    
    func showAlertMessage(title: String, button: String = "확인") { // 매개변수 기본값
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: button, style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
}
