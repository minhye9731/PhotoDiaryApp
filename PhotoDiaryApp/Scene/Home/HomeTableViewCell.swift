//
//  HomeTableViewCell.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/24/22.
//

import UIKit

class HomeTableViewCell: BaseTableViewCell {
    
    let diaryImageView: DiaryImageView = {
        let view = DiaryImageView(frame: .zero)
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = Constants.BaseColor.text
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    let dateLabel: UILabel = {
       let label = UILabel()
        label.textColor = Constants.BaseColor.text
        label.font = .boldSystemFont(ofSize: 13)
        return label
    }()
    
    let contentLabel: UILabel = {
       let label = UILabel()
        label.textColor = Constants.BaseColor.text
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, dateLabel, contentLabel])
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillEqually
        view.spacing = 2
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(data: UserDiary) {
        titleLabel.text = data.diaryTitle
        dateLabel.text = data.diaryDate.formatted()
        contentLabel.text = data.diaryContent
    }
    
    override func configure() {
        backgroundColor = .clear
        
        [diaryImageView, stackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        let spacing = 16
        
        diaryImageView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.7)
            make.width.equalTo(diaryImageView.snp.height)
            make.centerY.equalToSuperview()
            make.trailingMargin.equalTo(-spacing)
        }
        
        stackView.snp.makeConstraints { make in
            make.leadingMargin.equalTo(spacing)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(diaryImageView.snp.leading).offset(-spacing)
            make.height.equalTo(diaryImageView.snp.height)
        }
    }
    
}
