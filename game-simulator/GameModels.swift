//
//  GameModels.swift
//  game-simulator
//

import SpriteKit

enum ScreenMode {
    case main
    case aircraft
    case aircraftList
    case aircraftDetail
}

enum AircraftMenuAction: String, CaseIterable {
    case back
    case close
    case help
    case myPlanes
    case buyPlanes
    case maintenanceLog
    case liveries
    case listBack
    case listClose
    case listHelp
    case planeDetails
    case detailBack
    case detailClose
    case detailHelp
}

struct PlaneRow {
    let category: Int
    let model: String
    let name: String
    let hub: String
    let usage: Int
    let capacity: String
    let cargo: String?
    let wear: CGFloat
    let range: String
}
