//
//  scubapal_iosApp.swift
//  scubapal-ios
//
//  Created by Chinmaya Bidkar on 6/3/26.
//

import SwiftUI

@main
struct ScubaPalApp: App {
    private let dependencies: AppDependencies
    @StateObject private var session: SessionStore
    @StateObject private var badges: BadgeStore
    @StateObject private var appUI = AppUIStore()

    init() {
        let environment = AppDependencies.live
        dependencies = environment
        _session = StateObject(
            wrappedValue: SessionStore(authRepository: environment.authRepository)
        )
        _badges = StateObject(
            wrappedValue: BadgeStore(
                messagingRepository: environment.messagingRepository,
                notificationsRepository: environment.notificationsRepository
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .environmentObject(session)
                .environmentObject(badges)
                .environmentObject(appUI)
                .task {
                    await session.restore()
                }
        }
    }
}
