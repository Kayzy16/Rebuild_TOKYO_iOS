//
//  CalendarTimeLabel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/13.
//

import SwiftUI

struct CalendarTimeLabel: View {
    var startTime : String
    var endTime : String
    var body: some View {
        VStack{
            Text(startTime)
                .font(.caption2)
            Spacer()
            Text(endTime)
                .font(.caption2)
        }
        .frame(width:time_axis_width, height: event_frame_height)
//        .background(Color.yellow)
        .padding(.bottom)
    }
}

struct CalendarTimeLabel_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTimeLabel(startTime: String("10:00"), endTime: String("11:00"))
    }
}
