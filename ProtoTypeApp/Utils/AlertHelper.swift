//
//  AlertHelper.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/12.
//

import Foundation
import SwiftUI

struct AlertHelper {
    
    private var alertType : AlertType = .confirm
    
    private enum AlertType {
        case confirm
        case complete
        case failed
    }
    
//    private mutating func showCreateShiftAlert(isVisible:Binding<Bool>) -> Alert {
//        switch alertType {
//            case .confirm :
//                return Alert(
//                    title: Text("シフトを提出しますか？"),
//                    message: nil,
//                    primaryButton: .cancel(Text("キャンセル")),
//                    secondaryButton:
//                        .default (
//                            Text("OK"),
//                            action: {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
//                                    
//                                    alertType = .complete
//                                    isVisible.toggle()
//                                    // TODO シフトを保存するロジックをここに記載
//                                    
//                                }
//                            }
//                        )
//                    )
//            case .complete :
//                return Alert(
//                    title: Text("シフトを提出しました"),
//                    message:nil,
//                    dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
//                )
//        case .failed :
//            return Alert(
//                title: Text("シフトの作成に失敗しました"),
//                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
//                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
//            )
//        }
//    }
}
