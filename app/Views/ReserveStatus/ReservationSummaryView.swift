//
//  ReservationSummaryView.swift
//  app
//
//  Created by 高木一弘 on 2021/11/23.
//

import SwiftUI

struct ReservationSummaryView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State var booking : [Reservation] = []
    @State var history : [Reservation] = []
    
//    init(){
//        history = firestoreData.reservation.usersReservation
//    }
    
    var body: some View {
        
        GeometryReader{reader in
            ScrollView{
                VStack{
                    SectionTextView(sectionTitle: "予約状況")
                        .padding(.top)
                        .padding(.bottom)
    //                    .frame(height:20)
                    
                    ReservationDetailContainerView(altTxt: "現在予約中のトレーニングはございません", reservationList: $booking)
                        .frame(width: reader.size.width*0.8, height: reader.size.width*0.5)
//                        .background(Color.red)
                    
                    SectionTextView(sectionTitle: "トレーニング履歴")
                        .padding(.bottom)
                    
                    ReservationDetailContainerView(altTxt: "トレーニングの履歴がございません", reservationList: $history)
                        .frame(width: reader.size.width*0.8,height: reader.size.width*1.2)
                    
//                        .frame(width: reader.size.width*0.8)
                    
                    Spacer()
                }
            }
        }
        
        
        .onAppear{
            let bookingList = firestoreData.reservation.usersReservation
                .filter({$0.deleteFlg != 1})
                .filter({$0.startTime > Date()})
                .sorted(by: {(a, b) -> Bool in
                    return a.startTime < b.startTime})
            
            if(bookingList.count > 0){
//                booking.append(bookingList.first!)
                booking = bookingList
            }
            else{
                booking.removeAll()
            }
            
            history = firestoreData.reservation.usersReservation
                .filter({$0.deleteFlg != 1})
                .filter({$0.startTime < Date()})
                .sorted(by: { (a, b) -> Bool in
                    return a.startTime < b.startTime
            })
        }
    }
}

struct SectionTextView : View {
    
    var sectionTitle : String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(ColorManager.darkGray)
                    .frame(width: geometry.size.width*0.75, height: 2)
                
                
                
                Text(sectionTitle)
                    .foregroundColor(.clear)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .overlay(
                        Rectangle()
                            .fill(ColorManager.accentOrage)
                            .frame(height: 4)
                            .offset(y: -2)
                            .overlay(
                                Text(sectionTitle)
                                    .font(.title2)
                                    .fontWeight(.semibold)
//                                    .offset(y:14)
                                ,
                                alignment: .bottom
                            )
                        ,
                        alignment: .bottom)
                    .padding(.leading,20)
                    .padding(.trailing,20)
                    .background(Color(UIColor.systemBackground))
                    
            }
            .frame(width: geometry.size.width,height:20)
        }
    }
}

struct ReservationSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationSummaryView()
//            .environmentObject(FirestoreDataRepository())
    }
}
