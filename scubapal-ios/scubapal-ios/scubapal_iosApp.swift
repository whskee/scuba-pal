//
//  scubapal_iosApp.swift
//  scubapal-ios
//
//  Created by Chinmaya Bidkar on 6/3/26.
//

import SwiftUI

@main
struct scubapal_iosApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .task {
                    await session.restore()
                }
        }
    }
}
