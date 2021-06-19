//
//  StaffViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import Foundation
import RealmSwift

class StaffViewModel:ObservableObject {
    
    private var token : NotificationToken?
    private var modelResults = StaffDao.getAll()
    
    @Published var entities : [Staff] = []
    
    init(){
        token = modelResults.observe {[weak self] _ in
            self?.entities = self?.modelResults.map{$0} ?? []
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    func fetchData(completion: @escaping (Staff) -> Void) {
        // TODO オンラインから取得して返却
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let staff = StaffDao.getFirst()
            completion(staff)
        }

    }
}
