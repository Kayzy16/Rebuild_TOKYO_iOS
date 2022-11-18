//
//  Helper.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/10.
//

import Foundation

enum Page {
    case auth
    case calendar
}

enum SideMenuState {
    case isVisible
    case isHidden
}

enum LoginUserType {
    case staff
    case trainer
    case customer
    case developer
    case adm
}

enum WeekDay: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}
