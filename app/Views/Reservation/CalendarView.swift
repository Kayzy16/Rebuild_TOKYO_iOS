//
//  ReservationCalendar.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI

struct CalendarView: View {
    
    @State var startDay : Date
    @State var endDay   : Date
//    var staffViewModel = StaffViewModel()
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    init(){
        self._startDay = State(initialValue: getNormalizedDate(from: Date()))
        self._endDay  = State(initialValue: getNext3Day(from: Date()))
    }
    
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation{
                        startDay = getNext3Day(from: startDay)
                        endDay   = getNext3Day(from: endDay)
                    }
                }
                
                if $0.translation.width > 100 {
                    withAnimation{
                        startDay = getLast3Day(from: startDay)
                        endDay   = getLast3Day(from: endDay)
                    }
                }
            }
        return GeometryReader { geometry in
            VStack{
                HStack{
                    Button(action: {
                        startDay = getLast3Day(from: startDay)
                        endDay   = getLast3Day(from: endDay)
                        
                    }){
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 40)
                        }
                        .background(ColorManager.darkOrage)
                        .padding(.leading)
                    }
                    Spacer()
                    
                    Button(action: {
                        startDay = Date()
                        
                    }){
                        HStack{
                            Text("TODAY")
                                .padding(.trailing)
                                .padding(.leading)
                                .foregroundColor(.white)
                                .frame(height: 40)
                        }
                        .background(ColorManager.darkOrage)
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        startDay = getNext3Day(from: startDay)
                        endDay   = getNext3Day(from: endDay)
                        
                    }){
                        HStack{
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 40)
                        }
                        .background(ColorManager.darkOrage)
                        .frame(width: 60, height: 40)
                        .padding(.trailing)
                    }
                }
                .padding(.bottom)
                CalendarGridView(weekStartDay: startDay)
                    .environmentObject(firestoreData)
                
            }
        }
        .gesture(drag)
        .onAppear{
//            staffViewModel.fetchData()
        }
    }
}

struct ReservationCalendar_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environmentObject(ViewRouter())
    }
}
