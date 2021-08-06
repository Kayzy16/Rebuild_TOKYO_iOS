//
//  ProgramPickerView.swift
//  app
//
//  Created by 高木一弘 on 2021/08/03.
//


import SwiftUI

struct ProgramPickerView: View {
    
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State var programsList : [Program] = []
    @Binding var selectedProgram : Program?
    @EnvironmentObject var viewRouter: ViewRouter

    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(programsList,id:\.id) { (prgrm : Program) in
                ListRowProgram(program: prgrm)
                    .onTapGesture {
                        self.selectedProgram = prgrm
                        self.presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .onAppear{
            programsList  = firestoreData.programs.entities
        }
    }
    
}
