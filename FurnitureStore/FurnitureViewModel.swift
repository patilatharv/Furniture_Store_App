//
//  FurnitureViewModel.swift
//  FurnitureStore
//
//  Created by Mohammad Azam on 6/7/22.
//

import Foundation

enum WorldMapStatus: String  {
    case notAvailable = "Not Available"
    case limited = "Limited"
    case extending = "Extending"
    case mapped = "Mapped"
}

class FurnitureViewModel: ObservableObject {
    var onSave: () -> Void = { }
    var onClear: () -> Void = { }
    @Published var isSaved: Bool = false
    @Published var selectedFurniture: String = ""
    @Published var worldMapStatus: WorldMapStatus = .notAvailable
}
