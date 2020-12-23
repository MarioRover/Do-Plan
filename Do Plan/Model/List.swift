//
//  List.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/3/1399 AP.
//

import Foundation
import RealmSwift

class List: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
}
