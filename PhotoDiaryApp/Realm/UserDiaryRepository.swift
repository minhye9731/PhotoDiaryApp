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
    
}
