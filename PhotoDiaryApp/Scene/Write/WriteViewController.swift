//
//  WriteViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import Kingfisher
import RealmSwift //Realm 1.

// 0. protocol 데이터전달 - protocol 생성
protocol SelectImageDelegate {
    func sendImageData(image: UIImage)
}

class WriteViewController: BaseViewController {

    let mainView = WriteView()
    let localRealm = try! Realm() //Realm 2. Realm 테이블에 데이터를 CRUD할 때, Realm 테이블 경로에 접근
    
    override func loadView() {
        self.view = mainView
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.BaseColor.background
        
//        setNav()
        
        print("Realm is located at:", localRealm.configuration.fileURL!)
        
        // notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(sendPhotoNotificationObserver(notification:)), name: NSNotification.Name("PHOTO"), object: nil)
    }
    
//    func setNav() {
//        title = "오늘의 일기장"
//        self.navigationController?.navigationBar.tintColor = UIColor.black
//
//        let navibarAppearance = UINavigationBarAppearance()
//        let barbuttonItemAppearance = UIBarButtonItemAppearance()
//
//        navibarAppearance.backgroundColor = .clear
//
//        navibarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 18, weight: .bold)]
//
//        barbuttonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.green, .backgroundColor: UIColor.red, .font: UIFont.systemFont(ofSize: 14, weight: .bold)]
//
//            self.navigationItem.scrollEdgeAppearance = navibarAppearance
//            self.navigationItem.standardAppearance = navibarAppearance
//            navibarAppearance.buttonAppearance = barbuttonItemAppearance
//    }
    
    override func configure() {
        // 1. protocol 데이터전달 - 이미지 선택화면으로 이동
        mainView.searchImageButton.addTarget(self, action: #selector(selectImageButtonClicked), for: .touchUpInside)
        
        mainView.sampleButton.addTarget(self, action: #selector(sampleButtonClicked), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonClicked))
       
//        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelWriteDiary))
//
//        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveNewDiary))
//
//        self.navigationItem.rightBarButtonItems = [saveButton, cancelButton]
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
    
    // 2. protocol 데이터전달 - 이미지 선택화면으로 이동 & 해당화면의 대리자를 현뷰컨으로 지정
    @objc func selectImageButtonClicked() {
        let vc = SearchImageViewController()
        vc.delegate = self
        transition(vc, transitionStyle: .prsentNavigation)
    }
    
    @objc func closeButtonClicked() {
        dismiss(animated: true)
    }
    
    // Ream + 이미지 도큐먼트 저장
    @objc func saveButtonClicked() {
        print("작성한 다이어리 쓰기 저장")
        
        guard let title = mainView.titleTextField.text else {
            showAlertMessage(title: "제목을 입력해주세요", button: "확인")
            return
        }
        
        let task = UserDiary(diaryTitle: title, diaryContent: mainView.contentTextView.text!, diaryDate: Date(), regDate: Date(), photo: nil)
        
        do {
            try localRealm.write {
                localRealm.add(task)
            }
        } catch let error {
            print(error)
        }
        
        if let image = mainView.userImageView.image {
            saveImageToDocument(fileName: "\(task.objectId).jpg", image: image)
        }
        
        dismiss(animated: true)
    }
    
    
    @objc func sendPhotoNotificationObserver(notification: NSNotification) {
        
        print(#function)
        
        if let pickedImgURL = notification.userInfo?["url"] as? String {
            
            print(pickedImgURL)
            self.mainView.userImageView.kf.setImage(with: URL(string: pickedImgURL))
        }
        
    }
}


// 3. protocol 데이터전달 - 이미지 선택화면에서 선택된 이미지를 현뷰컨으로 가져오는 함수
extension WriteViewController: SelectImageDelegate {
    
    // 언제 실행이 되면 될까요? -> 이미지 서치화면에서 [선택]버튼 눌릴 때
    func sendImageData(image: UIImage) {
        mainView.userImageView.image = image
        print(#function)
    }
}
