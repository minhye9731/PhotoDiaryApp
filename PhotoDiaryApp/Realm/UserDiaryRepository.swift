//
//  UserDiaryRepository.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/26/22.
//

import Foundation
import RealmSwift

// 여러개의 테이블 => CRUD

// 레포지토리가 하나라 해도, 어떤 메서드가 있는지 보기 편하게 프로토콜 만드는게 좋음
protocol UserDiaryRepositoryType {
    func fetch() -> Results<UserDiary>
    func fetchSort(_ sort: String) -> Results<UserDiary>
    func fetchFilter() -> Results<UserDiary>
    func fetchDate(date: Date) -> Results<UserDiary>
    func updateFavorite(item: UserDiary)
    func deleteItem(item: UserDiary)
    func plusItem(item: UserDiary)
}

class UserDiaryRepository: UserDiaryRepositoryType {
    
    // Realm 2. Realm파일에 접근하는 상수 선언
    let localRealm = try! Realm() // struct가 싱글톤이 안되는 이유?
    
    func fetch() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryTitle", ascending: true)
    }
    
    func fetchSort(_ sort: String) -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: sort, ascending: true)
    }
    
    // realm filter array, NSPredicate
    func fetchFilter() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] 'a'")
    }
    // string 비교시에는 하나의 비교단위를 작은 따옴표로 묶어줘야 함
    //.filter("diaryTitle = '오늘의 일기 171'")
    // 대소문자 상관없이 다 포함여부 확인하려면 CONTAINS[c] 넣고 해야함
    
    func fetchDate(date: Date) -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).filter("diaryDate >= %@ AND diaryDate < %@", date, Date(timeInterval: 86400, since: date)) // NSPredicate
    }
    
    
    func updateFavorite(item: UserDiary) {
        
        let localRealm = try! Realm()
      
        try! localRealm.write {
            item.favorite.toggle()

            //하나의 테이블에 특정 컬럼 전체 값을 변경
//                self.tasks.setValue(true, forKey: "favorite")

            //하나의 레코드에서 여러 컬럼들이 변경
//                self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "diaryContent": "변경 테스트", "diaryTitle": "제목임"], update: .modified)

            print("Realm UPdate Succeed, ReloadRows 필요")
        }
    }
    
    func plusItem(item: UserDiary) {
        do {
            try localRealm.write {
                localRealm.add(item)
            }
        } catch let error {
            print(error)
        }
    }
    
    
    func deleteItem(item: UserDiary) {
        try! localRealm.write {
            localRealm.delete(item)
        }
        
        removeImageFromDocument(fileName: "\(item.objectId).jpg")
        
        print("trailing - favorite button clicked")
    }
    
    
    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return } // Document 경로
        let fileURL = documentDirectory.appendingPathComponent(fileName) // 세부 경로. 이미지를 저장할 위치
    
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            print(error)
        }
    }
    
}
