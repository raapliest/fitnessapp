//
//  FitnessApp.swift
//  Fitness
//
//  Created by 10 on 2026/5/7.
//

import SwiftUI
import FirebaseCore

@main
struct FitnessApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
