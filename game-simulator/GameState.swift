//
//  GameState.swift
//  game-simulator
//
//  Created by Evgeny Ukhanov on 04/06/2026.
//

import Foundation

struct GameState {
    var player = PlayerState(name: "Alex", level: 1)
    var resources: [ResourceCounter] = [
        ResourceCounter(kind: .tickets, amount: 51_595),
        ResourceCounter(kind: .credits, amount: 31),
        ResourceCounter(kind: .cash, amount: 1_049_904_187),
        ResourceCounter(kind: .science, amount: 202_480_000)
    ]
    var timedOffers: [TimedOffer] = [
        TimedOffer(kind: .shop, remainingText: "02ч 45м"),
        TimedOffer(kind: .cashBonus, remainingText: "3д 11ч"),
        TimedOffer(kind: .cargoBonus, remainingText: "3д 11ч")
    ]
    var clock = GameClock(hour: 4, minute: 43, weekday: "пт", day: 26, month: 1, year: 2063)
    var selectedAction: MenuAction?

    static let initial = GameState()

    var topResources: [ResourceCounter] {
        ResourceKind.topBarOrder.compactMap(resource)
    }

    func resource(_ kind: ResourceKind) -> ResourceCounter? {
        resources.first { $0.kind == kind }
    }

    mutating func select(_ action: MenuAction) {
        selectedAction = action
    }
}

struct PlayerState: Equatable {
    var name: String
    var level: Int
}

struct ResourceCounter: Equatable {
    var kind: ResourceKind
    var amount: Int

    var formattedAmount: String {
        amount.groupedWithSpaces
    }
}

enum ResourceKind: String, CaseIterable {
    case tickets
    case credits
    case cash
    case science

    static let topBarOrder: [ResourceKind] = [.tickets, .credits, .cash, .science]
}

struct TimedOffer: Equatable {
    var kind: TimedOfferKind
    var remainingText: String
}

enum TimedOfferKind: String, CaseIterable {
    case shop
    case cashBonus
    case cargoBonus
}

struct GameClock: Equatable {
    var hour: Int
    var minute: Int
    var weekday: String
    var day: Int
    var month: Int
    var year: Int

    var displayText: String {
        String(format: "%02d:%02d %@ %02d.%02d.%04d", hour, minute, weekday, day, month, year)
    }
}

enum MenuAction: String, CaseIterable {
    case routeMap
    case schedule
    case spotlight
    case messages
    case newspaper
    case tasks
    case globeNetwork
    case dutyFree
    case exchange
    case tickets
    case timeControl
    case fleet
    case airport
    case settings

    static let leftRail: [MenuAction] = [.routeMap, .schedule, .spotlight]
    static let rightRail: [MenuAction] = [.messages, .newspaper, .tasks]
    static let bottomDock: [MenuAction] = [.dutyFree, .exchange, .tickets, .timeControl, .fleet, .airport]
    static let floating: [MenuAction] = [.globeNetwork]
    static let topCorner: [MenuAction] = [.settings]

    var showsNotification: Bool {
        switch self {
        case .newspaper, .tasks, .exchange, .tickets:
            return true
        default:
            return false
        }
    }
}

extension Int {
    var groupedWithSpaces: String {
        let rawValue = String(self)
        let sign = rawValue.first == "-" ? "-" : ""
        let digits = sign.isEmpty ? rawValue : String(rawValue.dropFirst())
        var grouped = ""

        for (index, character) in digits.reversed().enumerated() {
            if index > 0 && index % 3 == 0 {
                grouped.append(" ")
            }
            grouped.append(character)
        }

        return sign + String(grouped.reversed())
    }
}

extension GameState {
    /// Demo fleet shown in the aircraft list until real data exists.
    static let demoPlaneRows: [PlaneRow] = [
        PlaneRow(category: 5, model: "ERJ-190", name: "BOOSTER-ERJ-190", hub: "KBP", usage: 98, capacity: "48(0/37/11)", cargo: nil, wear: 84.02, range: "4 447км"),
        PlaneRow(category: 5, model: "ERJ-195", name: "BOOSTER-ERJ-195", hub: "KBP", usage: 0, capacity: "77(46/22/9)", cargo: "4т", wear: 0.00, range: "4 077км"),
        PlaneRow(category: 1, model: "F900-B", name: "BOOSTER-F900-B", hub: "KBP", usage: 96, capacity: "13(9/3/1)", cargo: nil, wear: 84.74, range: "7 400км"),
        PlaneRow(category: 2, model: "Q-400", name: "BOOSTER-Q-400", hub: "KBP", usage: 2, capacity: "49(29/14/6)", cargo: "2т", wear: 0.00, range: "2 400км"),
        PlaneRow(category: 2, model: "S-2000", name: "BOOSTER-S-2000", hub: "KBP", usage: 88, capacity: "58(58/0/0)", cargo: nil, wear: 85.50, range: "2 869км"),
        PlaneRow(category: 1, model: "S-340BF", name: "BOOSTER-S-340BF", hub: "KBP", usage: 92, capacity: "", cargo: "3т", wear: 85.28, range: "1 731км"),
        PlaneRow(category: 1, model: "A220-100-R", name: "BSN", hub: "KBP", usage: 91, capacity: "68(0/53/15)", cargo: nil, wear: 81.96, range: "6 300км"),
        PlaneRow(category: 2, model: "L-1049G", name: "BSN-1", hub: "KBP", usage: 94, capacity: "106(106/0/0)", cargo: nil, wear: 88.98, range: "8 900км"),
        PlaneRow(category: 1, model: "F900-B", name: "BSN-1", hub: "KBP", usage: 97, capacity: "9(0/8/1)", cargo: nil, wear: 88.83, range: "7 400км"),
        PlaneRow(category: 3, model: "ERJ-145", name: "BOOSTER-ERJ-145", hub: "KBP", usage: 73, capacity: "50(42/6/2)", cargo: nil, wear: 69.12, range: "3 704км"),
        PlaneRow(category: 4, model: "CRJ-900", name: "BOOSTER-CRJ-900", hub: "KBP", usage: 66, capacity: "76(58/12/6)", cargo: nil, wear: 52.44, range: "3 200км"),
        PlaneRow(category: 5, model: "A319-100", name: "BOOSTER-A319", hub: "KBP", usage: 84, capacity: "124(94/22/8)", cargo: nil, wear: 74.06, range: "6 850км")
    ]
}
