//
//  Constant.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import Foundation

struct Constant {
    
    struct Color {
        static let middleDark = "MiddleDark"
        static let main       = "Main"
        static let grayWhite  = "GrayWhite"
        static let grayDark   = "GrayDark"
        static let grayDesc   = "GrayDesc"
    }

    struct Segue {
        static let newList = "NewListSegue"
        static let items   = "ItemsSegue"
        static let newItem = "NewItemSegue"
        static let notes    = "NotesSegue"
    }
    
    enum TypeOfItems: String {
        case all = "All"
        case today = "Today"
        case scheduled = "Scheduled"
        case category
    }
}
