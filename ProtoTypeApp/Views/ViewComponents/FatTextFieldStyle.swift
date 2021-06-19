//
//  FatTextFieldStyle.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI

public struct FatTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
                configuration
                    .font(.body) // set the inner Text Field Font
                    .padding(10) // Set the inner Text Field Padding
                    //Give it some style
//                    .background(
//                        RoundedRectangle(cornerRadius: 5)
//                            .strokeBorder(Color.primary.opacity(0.5), lineWidth: 3)
//                    )
            }
}
