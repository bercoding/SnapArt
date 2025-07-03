//
//  SnapArtApp.swift
//  SnapArt
//
//  Created by Le Thanh Nhan on 2/7/25.
//

import SwiftUI
import Firebase

@main
struct SnapArtApp: App {
    // Configure Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var firebaseManager = FirebaseManager.shared
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if firebaseManager.user != nil {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    AuthView()
                }
            }
        }
    }
}
