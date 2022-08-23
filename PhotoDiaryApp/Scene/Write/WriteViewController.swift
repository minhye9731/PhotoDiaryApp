//
//  WriteViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import Kingfisher
import RealmSwift //Realm 1.

class WriteViewController: BaseViewController {

    let mainView = WriteView()
    let localRealm = try! Realm() //Realm 2. Realm 테이블에 데이터를 CRUD할 때, Realm 테이블 경로에 접근
    
    override func loadView() {
        self.view = mainView
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setNav()
        setBarButtonItem()
        
        print("Realm is located at:", localRealm.configuration.fileURL!)
        
        // notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(sendPhotoNotificationObserver(notification:)), name: NSNotification.Name("PHOTO"), object: nil)
    }
    
    func setNav() {
        title = "오늘의 일기장"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        let navibarAppearance = UINavigationBarAppearance()
        let barbuttonItemAppearance = UIBarButtonItemAppearance()
        
        navibarAppearance.backgroundColor = .clear
        
        navibarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        barbuttonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.green, .backgroundColor: UIColor.red, .font: UIFont.systemFont(ofSize: 14, weight: .bold)]

            self.navigationItem.scrollEdgeAppearance = navibarAppearance
            self.navigationItem.standardAppearance = navibarAppearance
            navibarAppearance.buttonAppearance = barbuttonItemAppearance
    }
    
    func setBarButtonItem() {
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelWriteDiary))
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveNewDiary))
       
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelWriteDiary))

        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveNewDiary))

        self.navigationItem.rightBarButtonItems = [saveButton, cancelButton]
    }
    
    @objc func cancelWriteDiary() {
        print("다이어리 쓰기 취소")
    }
    
    @objc func saveNewDiary() {
        print("작성한 다이어리 쓰기 저장")
    }
    
    override func configure() {
        mainView.searchImageButton.addTarget(self, action: #selector(selectImageButtonClicked), for: .touchUpInside)
        mainView.sampleButton.addTarget(self, action: #selector(sampleButtonClicked), for: .touchUpInside)
    }
    
    //Realm Create Sample
    @objc func sampleButtonClicked() {
        
        let task = UserDiary(diaryTitle: "오늘의 일기\(Int.random(in: 1...1000))",
                             diaryContent: "일기 테스트 내용",
                             diaryDate: Date(),
                             regDate: Date(),
                             photo: nil)

        try! localRealm.write {
            localRealm.add(task) //Create
            print("Realm Succeed")
            dismiss(animated: true)
        }
    }
      
    @objc func selectImageButtonClicked() {
        let vc = SearchImageViewController()
        transition(vc)
    }
    
    @objc func sendPhotoNotificationObserver(notification: NSNotification) {
        
        print(#function)
        
        if let pickedImgURL = notification.userInfo?["url"] as? String {
            
            print(pickedImgURL)
            self.mainView.userImageView.kf.setImage(with: URL(string: pickedImgURL))
        }
        
    }
    
    
    
    
    
}
