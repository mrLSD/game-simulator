//
//  GameStateTests.swift
//  game-simulatorTests
//
//  Created by Evgeny Ukhanov on 04/06/2026.
//

import Testing
@testable import game_simulator

struct GameStateTests {
    @Test func topResourcesKeepStateOrderAndFormatting() {
        let state = GameState.initial

        #expect(state.topResources.map(\.kind) == [.tickets, .credits, .cash, .science])
        #expect(state.resource(.tickets)?.formattedAmount == "51 595")
        #expect(state.resource(.cash)?.formattedAmount == "1 049 904 187")
        #expect(state.resource(.science)?.formattedAmount == "202 480 000")
    }

    @Test func menuActionsAreGroupedForClickableZones() {
        #expect(MenuAction.leftRail == [.routeMap, .schedule, .spotlight])
        #expect(MenuAction.rightRail == [.messages, .newspaper, .tasks])
        #expect(MenuAction.bottomDock == [.dutyFree, .exchange, .tickets, .timeControl, .fleet, .airport])
        #expect(MenuAction.floating == [.globeNetwork])
        #expect(MenuAction.topCorner == [.settings])
    }

    @Test func selectedActionLivesInGameState() {
        var state = GameState.initial

        #expect(state.selectedAction == nil)
        state.select(.airport)
        #expect(state.selectedAction == .airport)
    }
}
