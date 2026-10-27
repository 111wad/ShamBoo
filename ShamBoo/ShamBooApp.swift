//
//  ShamBooApp.swift
//  ShamBoo
//
//  Created by wad on 27/10/2026.
//

import AVFoundation
import SwiftUI
import UIKit

@main
struct ShamBooApp: App {
    init() {
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Keep Spotify playing even if session setup fails.
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
