//
//  SearchImageViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import Kingfisher

class SearchImageViewController: BaseViewController, UISearchBarDelegate {
    
    var delegate: SelectImageDelegate? // 4. protocol 데이터전달 - delegate 생성
    var selectImage: UIImage?
    var selectIndexPath: IndexPath?

    let mainView = ImageSearchView()
    
    var currentPage = 1 // 추가

    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.BaseColor.background
    }

    override func configure() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        mainView.searchBar.delegate = self
        
        mainView.collectionView.register(ImageSearchCollectionViewCell.self, forCellWithReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier)
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonClicked))
        navigationItem.leftBarButtonItem = closeButton
        
        // 5. protocol 데이터전달 - 전달함수 호출할 트리거
        let saveButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectButtonClicked))
        navigationItem.rightBarButtonItem = saveButton
        
        view.isUserInteractionEnabled = true
        mainView.collectionView.isUserInteractionEnabled = true
        
    }
    
    @objc func closeButtonClicked() {
        dismiss(animated: true)
    }
    
    // 6. protocol 데이터전달 - 전달할 이미지를 상수에 담아서 보냄
    @objc func selectButtonClicked() {
        guard let image = selectImage else {
            showAlertMessage(title: "사진을 선택해주세요", button: "확인")
            return
        }
        delegate?.sendImageData(image: image)
        dismiss(animated: true)
    }
}
 
// MARK: - collectionview 설정
extension SearchImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageDummy.data.count // 통신하면 곧 변경
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageSearchCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.layer.borderWidth = selectIndexPath == indexPath ? 4 : 0
        cell.layer.borderColor = selectIndexPath == indexPath ? Constants.BaseColor.point.cgColor : nil
        
        cell.setImage(data: ImageDummy.data[indexPath.item].url) // 통신하면 곧 변경

        return cell
    }
    
    // userInteractionEnabled  Progress Image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // notification 활용방법
//        let imgURL = ImageDummy.data[indexPath.item].url
//
//        // 데이터 넘기고
//        NotificationCenter.default.post(name: NSNotification.Name("PHOTO"), object: nil, userInfo: ["url" : imgURL])
//        print("url 넘기고 : \(imgURL)")
//        // 화면 내리고
//        dismiss(animated: true)
        
        // 7. protocol 데이터전달 - 전달할 이미지를 선택시 selectImage상수에 담기
        // 어떤 셀인지 어떤 이미지를 가지고 올 지 어떻게 알죠?
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageSearchCollectionViewCell else { return }
        
        selectIndexPath = indexPath
        selectImage = cell.searchImageView.image
        collectionView.reloadData()
    }
    
    // didDeselectItemAt
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(#function)
        selectIndexPath = nil
        selectImage = nil
        collectionView.reloadData()
    }

}

// MARK: - API 통신

extension SearchImageViewController {
    
    // 통신해서 데이터 받아오는 함수
    
    
}


