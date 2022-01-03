//
//  ReservationDetailContainerView.swift
//  app
//
//  Created by 高木一弘 on 2021/11/23.
//

import SwiftUI

struct ReservationDetailContainerView: View {
    
    var altTxt : String
    @Binding var reservationList : [Reservation]
    
    
    var body: some View {
        GeometryReader{ reader in
            VStack{
//                Spacer()
                if(reservationList.count != 0){
                    
                    if(reservationList.count == 1){
                        ReservationDetailView(reservationList.first!)
                            .padding()
                            .background(
                                Rectangle()
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                    }
                    else{
                        ScrollView {
                            LazyVStack {
                                ForEach(reservationList,id:\.self){ reserve in
                                    ReservationDetailView(reserve)
                                        .padding()
                                        .background(
                                            Rectangle()
                                                .fill(Color(UIColor.secondarySystemBackground))
                                        )
        //                                .frame(height:reader.size.width*0.6)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                    
                    
                }
                else{
                    Text(altTxt)
                        .font(.headline)
                        .frame(height:reader.size.width*0.6)
                        .padding(.leading,20)
                        .padding(.trailing,20)
                        .background(
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                }
                Spacer()
            }
            .frame(width:reader.size.width)
            .onAppear{
                // To remove only extra separators below the list:
                UITableView.appearance().tableFooterView = UIView()

                // To remove all separators including the actual ones:
                UITableView.appearance().separatorStyle = .none
            }
//            .background(
//                Rectangle()
//                    .fill(Color(UIColor.secondarySystemBackground))
//            )
        }
    }
}

struct ReservationDetailContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationDetailContainerView(altTxt: "現在予約中のトレーニングはございません",reservationList: .constant([Reservation()]))
    }
}
