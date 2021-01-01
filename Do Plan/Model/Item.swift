//
//  Item.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/3/1399 AP.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String  = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var priority: String = "None"
    @objc dynamic var done: Bool    = false
    @objc dynamic var createdAt: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
