//
//  HomeViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import SnapKit
import RealmSwift
import FSCalendar

class HomeViewController: BaseViewController {
    
    let repository = UserDiaryRepository()
    
    lazy var calendar: FSCalendar = {
        let view = FSCalendar()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        return view
    }()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .lightGray
        return view
    }()
    
    // Realm 3. Realm에서 읽어온 데이터를 담을 배열 선언
    // 어떤 작업이 있어도 property observer로 reload 해줄 수 있음! (정렬, 필터, 즐겨찾기 whatever)
    var tasks: Results<UserDiary>! {
        didSet {
            tableView.reloadData()
            print("Tasks Changed!!")
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        // Realm 4. 배열에 Realm의 데이터 초기화, Realm 데이터를 정렬해
        // sorted 안해주면 데이터가 생성된 순서(objectid)로 정렬된다.
        fetchRealm()
    }
    
    // MARK: - layout
    override func configure() {
        view.addSubview(tableView)
        view.addSubview(calendar)
        setNaviBarItem()
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
            make.topMargin.equalTo(300)
        }
        
        calendar.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(300)
        }
    }
    
    func setNaviBarItem() {
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        navigationItem.leftBarButtonItems = [sortButton, filterButton]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
    }

}

// MARK: - Realm 5. 테이블뷰에 데이터 표현
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.diaryImageView.image = loadImageFromDocument(fileName: "\(tasks[indexPath.row].objectId).jpg")
        cell.setData(data: tasks[indexPath.row])
        
        return cell
    }
    
    // 참고. TableView Editing Mode
    // 테이블뷰 셀 높이가 작을 경우, 이미지가 없을 때, 시스템 이미지가 아닌 경우
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 공식문서 참고 : uicontextualactionhandler
        let favorite = UIContextualAction(style: .normal, title: "즐겨찾기") { action, view, completionHandler in
            
            // realm data update
            self.repository.updateFavorite(item: self.tasks[indexPath.row])
            // self.fetchRealm() 이제 이거 안해도 됨. 바뀌면 자동으로 인식해서 재정렬하니까.
        }
        
        //realm 데이터 기준
        let image = tasks[indexPath.row].favorite ? "star.fill" : "star"
        favorite.image = UIImage(systemName: image)
        favorite.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 공식문서 참고 : uicontextualactionhandler
        let favorite = UIContextualAction(style: .normal, title: "즐겨찾기") { action, view, completionHandler in
            
            // 해결방법 : 인텍스를 변수에 담아둬라. 데이터의 정합성을 위해
//            let task = self.tasks[indexPath.row]
            
            self.repository.deleteItem(item: self.tasks[indexPath.row])
            
            // 먼저하면 에러안남
//            self.removeImageFromDocument(fileName: "\(self.tasks[indexPath.row].objectId).jpg")
//
//            try! self.localRealm.write {
//                self.localRealm.delete(self.tasks[indexPath.row])
//            } // 여기서 task 삭제되자마자 property observer에 의해 tableview가 갱신되어서 데이터 표상에서는 해당 index 데이터는 사라져버림
            
            //후에 지우면 에러남. 왜? indexPath.row 가 같은애를 말하지 않아서. 시기 차이가 있어서 다른애를 호출하고 있어서 충돌이 난다.
//            self.removeImageFromDocument(fileName: "\(self.tasks[indexPath.row].objectId).jpg")
        }
        
        let example = UIContextualAction(style: .normal, title: "예시") { action, view, completionHandler in
            print("trailing - example button clicked")
        }
        
        return UISwipeActionsConfiguration(actions: [favorite, example])
    }
    
}


extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return repository.fetchDate(date: date).count
    }
    
//    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
//        return "새싹"
//    }

//    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
//        return UIImage(systemName: "star.fill")
//    }

    //date: yyyyMMdd hh:mm:ss => dateformatter
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return formatter.string(from: date) == "220907" ? "오프라인 행사" : nil
    }

    // 재확인 필요
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        tasks = repository.fetchDate(date: date)
//    }

}


// MARK: - 기타 함수들
extension HomeViewController {
 
    
    @objc func sortButtonClicked() {
        tasks = repository.fetchSort("regdate")
    }
    
    @objc func filterButtonClicked() {
        tasks = repository.fetchFilter()
    }
    
    @objc func plusButtonClicked() {
        let vc = WriteViewController()
        transition(vc, transitionStyle: .presentFullNavigation)
    }
    
    func fetchRealm() {
        tasks = repository.fetch()
    }

}
