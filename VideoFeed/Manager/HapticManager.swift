//
//  HapticManager.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/20/24.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func generateFeedback(of type: HapticFeedbackType, intensity: HapticIntensity = .medium) {
        switch type {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred(intensity: intensity.rawValue)
        case .notification(let feedbackType):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(feedbackType)
        }
    }
}

enum HapticFeedbackType {
    case selection
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(type: UINotificationFeedbackGenerator.FeedbackType)
}

enum HapticIntensity: CGFloat {
    case light = 0.1
    case medium = 0.5
    case strong = 1.0
}

