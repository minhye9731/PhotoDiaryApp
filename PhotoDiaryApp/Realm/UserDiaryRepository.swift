//
//  UserDiaryRepository.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/26/22.
//

import Foundation
import RealmSwift

class UserDiaryRepository {
    
    let localRealm = try! Realm()
    
    func fetch() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryDate", ascending: false)
    }
    
    func fetchSort(_ sort: String) -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: sort, ascending: true)
    }
    
    func fetchFilter() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] '3'")
    }
    
    func updateFavorite(item: UserDiary) {
//        try! self.localRealm.write {
//            self.task[a].favorite = !self.task[a].favorite
//        }
      
        try! localRealm.write {
            //하나의 레코드에서 특정 컬럼 하나만 변경
            item.favorite.toggle()

            //하나의 테이블에 특정 컬럼 전체 값을 변경
//                self.tasks.setValue(true, forKey: "favorite")

            //하나의 레코드에서 여러 컬럼들이 변경
//                self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "diaryContent": "변경 테스트", "diaryTitle": "제목임"], update: .modified)

            print("Realm UPdate Succeed, ReloadRows 필요")
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
