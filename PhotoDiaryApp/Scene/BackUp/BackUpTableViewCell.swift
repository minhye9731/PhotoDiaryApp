//
//  BackUpTableViewCell.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/29/22.
//

import UIKit

class BackUpTableViewCell: BaseTableViewCell {

    let titleLabel: UILabel = {
       let view = UILabel()
        view.backgroundColor = .white
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 15)
        view.textAlignment = .left
        return view
    }()
    
    override func configure() {
        backgroundColor = .lightGray
        contentView.addSubview(titleLabel)
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self)
            make.leadingMargin.trailingMargin.equalTo(self.safeAreaLayoutGuide).offset(30)
        }
    }
    
}
