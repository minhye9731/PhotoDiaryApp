//
//  HomeViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/23/22.
//

import UIKit
import SnapKit
import RealmSwift

class HomeViewController: BaseViewController {
    
    let localRealm = try! Realm() // Realm 2. Realm파일에 접근하는 상수 선언
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .lightGray
        return view
    }() // 즉시 실행 클로저
    
    // Realm 3. Realm에서 읽어온 데이터를 담을 배열 선언
    // 어떤 작업이 있어도 property observer로 reload 해줄 수 있음!
    var tasks: Results<UserDiary>! {
        didSet {
            // present, overCurrentComtext, overFullscreen > viewWillAppear X
            // 정렬, 필터, 즐겨찾기 whatever
            tableView.reloadData()
            print("Tasks Changed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Realm 4. 배열에 Realm의 데이터 초기화, Realm 데이터를 정렬해
        // sorted 안해주면 데이터가 생성된 순서(objectid)로 정렬된다.
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryDate", ascending: false)
        print(#function)
        // 화면 갱신은 화면 전환 코드 및 생명 주기 실헹 점검 필요
    }
    
    func fetchRealm() {
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryDate", ascending: false)
    }
    
    override func configure() {
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        
        navigationItem.leftBarButtonItems = [sortButton, filterButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    
    @objc func sortButtonClicked() {
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "regdate", ascending: true)
    }
    
    // realm filter array, NSPredicate
    @objc func filterButtonClicked() {
        // string 비교시에는 하나의 비교단위를 작은 따옴표로 묶어줘야 함
        // 대소문자 상관없이 다 포함여부 확인하려면 CONTAINS[c] 넣고 해야함
        tasks = localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] '3'")
        //.filter("diaryTitle = '오늘의 일기 171'")
    }
    
    
    @objc func plusButtonClicked() {
        let vc = WriteViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



// Realm 5. 테이블뷰에 데이터 표현
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].diaryTitle
        // cell.setData(data: tasks[indexPath.row])
        return cell
    }
    
    // 참고. TableView Editing Mode
    // 테이블뷰 셀 높이가 작을 경우, 이미지가 없을 때, 시스템 이미지가 아닌 경우
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 공식문서 참고 : uicontextualactionhandler
        let favorite = UIContextualAction(style: .normal, title: "즐겨찾기") { action, view, completionHandler in
            //            print("leading - favorite button clicked")
            
            // realm data update
            try! self.localRealm.write {
                //하나의 레코드에서 특정 컬럼 하나만 변경
                self.tasks[indexPath.row].favorite = !self.tasks[indexPath.row].favorite
                
                //하나의 테이블에 특정 컬럼 전체 값을 변경
                //                self.tasks.setValue(true, forKey: "favorite")
                
                //하나의 레코드에서 여러 컬럼들이 변경
                //                self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "diaryContent": "변경 테스트", "diaryTitle": "제목임"], update: .modified)
                
                print("Realm UPdate Succeed, ReloadRows 필요")
            }
            
            // 1. 스와이프한 셀 하나만 ReloadRow에 코드를 구현
            // 12. 데이터가 변경됐으니 다시 realm에서 데이터를 가져오기 => didSet일관적 향태로 댄ㅁ
            self.fetchRealm()
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
            print("trailing - favorite button clicked")
        }
        
        let example = UIContextualAction(style: .normal, title: "예시") { action, view, completionHandler in
            print("trailing - example button clicked")
        }
        
        return UISwipeActionsConfiguration(actions: [favorite, example])
    }
    
    
}






