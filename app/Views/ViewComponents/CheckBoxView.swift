//
//  CheckBoxView.swift
//  app
//
//  Created by 高木一弘 on 2021/11/21.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool

    var body: some View {
        
        
        HStack {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(Color.white)
                
            Text("次回以降メールアドレスとパスワードの入力を省略する")
                .foregroundColor(Color.white)
        }
        .onTapGesture {
            self.checked.toggle()
        }
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    struct CheckBoxViewHolder: View {
        @State var checked = false

        var body: some View {
            CheckBoxView(checked: $checked)
        }
    }

    static var previews: some View {
        CheckBoxViewHolder()
    }
}
