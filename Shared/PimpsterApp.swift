//
//  PimpsterApp.swift
//  Shared
//
//  Created by Oleg Soldatoff on 11.02.21.
//

import SwiftUI

@main
struct PimpsterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(PlayerBrain())
        }
    }
}
