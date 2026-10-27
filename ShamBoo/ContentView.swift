//
//  ContentView.swift
//  ShamBoo
//
//  Created by wad on 27/10/2026.
//

import AVFoundation
import SwiftUI
import UIKit

private enum Palette {
    static let purple = Color(hex: 0xC79DE3)
    static let pink = Color(hex: 0xE39DB9)
    static let lime = Color(hex: 0xB9E39D)
    static let mint = Color(hex: 0x9DE3C7)
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var isRunning = false
    @State private var accumulated: TimeInterval = 0
    @State private var startedAt: Date?

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: !isRunning)) { context in
            let elapsed = displayedElapsed(at: context.date)

            VStack(spacing: 40) {
                Spacer()

                Text(timeString(from: elapsed))
                    .font(.system(size: 108, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .foregroundStyle(Palette.purple)
                    .contentTransition(.numericText())
                    .accessibilityLabel("Tiempo")
                    .accessibilityValue(timeString(from: elapsed))

                Spacer()

                GlassEffectContainer(spacing: 14) {
                    HStack(spacing: 14) {
                        Button(action: reset) {
                            Text("Reiniciar")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 76)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.roundedRectangle(radius: 28))
                        .tint(Palette.purple)
                        .disabled(accumulated == 0 && !isRunning)

                        Button(action: toggle) {
                            Text(isRunning ? "Pausar" : "Iniciar")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 76)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 28))
                        .tint(isRunning ? Palette.pink : Palette.mint)
                        .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.8), trigger: isRunning)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { ShamBooBackground() }
        }
        .ignoresSafeArea()
        .onAppear(perform: prepareSession)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                prepareSession()
            }
        }
    }

    private func displayedElapsed(at date: Date) -> TimeInterval {
        if isRunning, let startedAt {
            return accumulated + date.timeIntervalSince(startedAt)
        }
        return accumulated
    }

    private func timeString(from elapsed: TimeInterval) -> String {
        let total = max(0, Int(elapsed))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    private func start() {
        prepareSession()
        startedAt = .now
        isRunning = true
    }

    private func pause() {
        if let startedAt {
            accumulated += Date.now.timeIntervalSince(startedAt)
        }
        self.startedAt = nil
        isRunning = false
    }

    private func reset() {
        isRunning = false
        startedAt = nil
        accumulated = 0
    }

    private func prepareSession() {
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // If the session cannot activate, leave Spotify untouched.
        }
    }
}

private struct ShamBooBackground: View {
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: [
                Palette.purple, Palette.pink, Palette.purple,
                Palette.mint, Palette.lime, Palette.mint,
                Palette.pink, Palette.mint, Palette.lime
            ]
        )
        .ignoresSafeArea()
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

#Preview {
    ContentView()
}
