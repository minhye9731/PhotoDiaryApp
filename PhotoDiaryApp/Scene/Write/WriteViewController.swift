//
//  WriteViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import PhotosUI

import Kingfisher
import RealmSwift //Realm 1.

// 0. protocol 데이터전달 - protocol 생성
protocol SelectImageDelegate {
    func sendImageData(image: UIImage)
}

final class WriteViewController: BaseViewController {

    let mainView = WriteView()
    let localRealm = try! Realm()
    let repository = UserDiaryRepository()
    
    override func loadView() {
        self.view = mainView
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.BaseColor.background
        
        print("Realm is located at:", repository.localRealm.configuration.fileURL!)
        
        // notification 데이터 전달 - notification observer
//        NotificationCenter.default.addObserver(self, selector: #selector(sendPhotoNotificationObserver(notification:)), name: NSNotification.Name("PHOTO"), object: nil)
    }
    
    override func configure() {
        // BarButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonClicked))
        
        // 1. protocol 데이터전달 - 이미지 선택화면으로 이동
        mainView.searchImageButton.addTarget(self, action: #selector(selectImageButtonClicked), for: .touchUpInside)
        
        mainView.sampleButton.addTarget(self, action: #selector(sampleButtonClicked), for: .touchUpInside)
    }
    
}


// 3. protocol 데이터전달 - 이미지 선택화면에서 선택된 이미지를 현뷰컨으로 가져오는 함수
//extension WriteViewController: SelectImageDelegate {
//
//    // 언제 실행이 되면 될까요? -> 이미지 서치화면에서 [선택]버튼 눌릴 때
//    func sendImageData(image: UIImage) {
//        mainView.userImageView.image = image
//        print(#function)
//    }
//
//    // notification 데이터 전달
//    @objc func sendPhotoNotificationObserver(notification: NSNotification) {
//
//        print(#function)
//
//        if let pickedImgURL = notification.userInfo?["url"] as? String {
//
//            print(pickedImgURL)
//            self.mainView.userImageView.kf.setImage(with: URL(string: pickedImgURL))
//        }
//
//    }
//}


extension WriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let result = results.first else { return }
        
        let itemProvider = result.itemProvider
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                
                DispatchQueue.main.async {
                    self.mainView.userImageView.image = image as? UIImage
                    self.dismiss(animated: true)
                }
            }
        } else {
            showAlertMessage(title: "이미지를 가져오는 것에 실패했습니다ㅜㅜ")
        }
    }
}


// MARK: - 기타 함수들 모음
extension WriteViewController {
    
    // X 버튼 클릭시 홤수
    @objc private func closeButtonClicked() {
        dismiss(animated: true)
    }
    
    // 작성한 일기내용, 선택한 이미지 저장
    // Realm + 이미지 도큐먼트 저장
    @objc func saveButtonClicked() {
        print("작성한 다이어리 쓰기 저장")
        
        guard let title = mainView.titleTextField.text else {
            showAlertMessage(title: "제목을 입력해주세요", button: "확인")
            return
        }
        
        guard let contents = mainView.contentTextView.text else {
            showAlertMessage(title: "내용을 입력해주세요", button: "확인")
            return
        }
        
        let task = UserDiary(diaryTitle: title, diaryContent: contents, diaryDate: Date(), regDate: Date(), photo: nil)
        
        repository.plusItem(item: task)
        
        if let image = mainView.userImageView.image {
            saveImageToDocument(fileName: "\(task.objectId).jpg", image: image)
        }
        
        dismiss(animated: true)
    }
    
    // (초록색 버튼) 샘플일기 만들기 - Realm Create Sample
    @objc func sampleButtonClicked() {
        
        let task = UserDiary(diaryTitle: "오늘의 일기\(Int.random(in: 1...1000))",
                             diaryContent: "일기 테스트 내용",
                             diaryDate: Date(),
                             regDate: Date(),
                             photo: nil)
        repository.plusItem(item: task)
    }
    
    // 이미지 선택하러 가기 버튼
    @objc func selectImageButtonClicked() {
//        let vc = SearchImageViewController()
          // 2. protocol 데이터전달 - 이미지 선택화면으로 이동 & 해당화면의 대리자를 현뷰컨으로 지정
//        vc.delegate = self
//        transition(vc, transitionStyle: .prsentNavigation)
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images, .livePhotos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        transition(picker, transitionStyle: .present)
    }
    
    
    
}
