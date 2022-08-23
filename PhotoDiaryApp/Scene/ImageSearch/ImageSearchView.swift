//
//  ImageSearchView.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit

class ImageSearchView: BaseView {
    
    let searchAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    
    let searchBar: UISearchBar = {
       let view = UISearchBar()
        view.placeholder = "원하는 이미지를 검색해보세요!"
        view.backgroundColor = .white
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle("취소", for: .normal)
        view.tintColor = .red
        return view
    }()
    
    let selectButton: UIButton = {
        let view = UIButton()
        view.setTitle("선택", for: .normal)
        view.tintColor = .blue
        return view
    }()
     
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout())
        return view
    }()
    
     
    override func configureUI() {
        [searchAreaView, collectionView].forEach {
            self.addSubview($0)
        }
        
        [searchBar, cancelButton, selectButton].forEach {
            searchAreaView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        
        searchAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }
        
        selectButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchAreaView)
            make.trailing.equalTo(searchAreaView.snp.trailing).offset(-10)
            make.width.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchAreaView)
            make.trailing.equalTo(selectButton.snp.leading).offset(-10)
            make.width.height.equalTo(44)
        }
        
        searchBar.snp.makeConstraints { make in
            make.centerY.equalTo(searchAreaView)
            make.leading.equalTo(searchAreaView.snp.leading).offset(10)
//            make.width.equalTo(100)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-10)
        }
        
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(70)
            make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    
    
    
    
    
    // MARK: - CollectionViewLayout
    static func imageCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let deviceWidth: CGFloat = UIScreen.main.bounds.width
        let itemWidth: CGFloat = deviceWidth / 3
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.scrollDirection = .vertical
        return layout
    }
}
