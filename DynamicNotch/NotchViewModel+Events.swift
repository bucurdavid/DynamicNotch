import Cocoa
import Combine
import Foundation
import SwiftUI

extension NotchViewModel {
    func setupCancellables() {
        let events = EventMonitors.shared
        
        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation

                switch self.status {
                case .opened:
                    if !self.notchOpenedRect.contains(mouseLocation) && !self.isMediaPlaying() {
                        self.notchClose()
                    } else if !self.notchOpenedRect.contains(mouseLocation) && self.isMediaPlaying() {
                        self.notchMedia()
                    } else if self.deviceNotchRect.insetBy(dx: self.inset, dy: self.inset).contains(mouseLocation) {
                        self.notchClose()
                    } else if self.headlineOpenedRect.contains(mouseLocation) {
                        if let nextValue = ContentType(rawValue: self.contentType.rawValue + 1) {
                            self.contentType = nextValue
                        } else {
                            self.contentType = ContentType(rawValue: 0)!
                        }
                    }
                case .closed, .popping:
                    if self.deviceNotchRect.insetBy(dx: self.inset, dy: self.inset).contains(mouseLocation) {
                        self.notchOpen(.click)
                    }
                case .media:
                    if self.isMediaPlaying() {
                        if self.deviceNotchRect.insetBy(dx: self.inset, dy: self.inset).contains(mouseLocation) {
                            self.notchOpen(.click)
                        }
                    } else {
                        self.notchClose()
                    }
                }
            }
            .store(in: &cancellables)

        events.optionKeyPress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
                guard let self else { return }
                self.optionKeyPressed = input
            }
            .store(in: &cancellables)

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mouseLocation in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let aboutToOpen = self.deviceNotchRect.insetBy(dx: self.inset, dy: self.inset).contains(mouseLocation)
                if self.status == .closed, aboutToOpen {
                    self.notchPop()
                }
                if self.status == .media, aboutToOpen {
                    self.notchPop()
                }
                if self.status == .popping, !aboutToOpen, self.isMediaPlaying() {
                    self.notchMedia()
                }
                if self.status == .popping, !aboutToOpen, !self.isMediaPlaying() {
                    self.notchClose()
                }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 != .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Reduce animation delay here if necessary
                withAnimation(.easeInOut(duration: 0.15)) {
                    self?.notchVisible = true
                }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 == .popping }
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard NSEvent.pressedMouseButtons == 0 else { return }
                self?.hapticSender.send()
            }
            .store(in: &cancellables)

        hapticSender
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard self?.hapticFeedback ?? false else { return }
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .now
                )
            }
            .store(in: &cancellables)

        $status
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.global())
            .filter { $0 == .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    self?.notchVisible = false
                }
            }
            .store(in: &cancellables)

        $selectedLanguage
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.notchClose()
                output.apply()
            }
            .store(in: &cancellables)

     
        currentMediaPlayer.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                
                // Only switch to media mode if it's not already in the opened state
                if isPlaying {
                    if self.status != .opened {
                        self.notchMedia()
                    }
                } else {
                    // Only close the notch if it's not in the opened state
                    if self.status != .opened {
                        self.notchClose()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func isMediaPlaying() -> Bool {
        return self.currentMediaPlayer.isPlaying
    }

    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
