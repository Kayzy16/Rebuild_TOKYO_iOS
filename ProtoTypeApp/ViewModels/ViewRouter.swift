//
//  ViewRouter.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/10.
//

import Foundation
import SwiftUI

class ViewRouter : ObservableObject {
    @Published var currentPage     : Page = .auth
    @Published var loginUserType   : LoginUserType = .customer
    @Published var sideMenuState   : SideMenuState = .isHidden
    @Published var loginStaffId    : String = ""
    @Published var loginCustomerId : String = ""
    @Published var selectedStaffId : String = ""
}
