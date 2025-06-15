//
//  Extensions.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 13/06/25.
//

import SwiftUI
import UIKit
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF) / 255.0
        b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: CGFloat
        r = CGFloat((int >> 16) & 0xFF) / 255.0
        g = CGFloat((int >> 8) & 0xFF) / 255.0
        b = CGFloat(int & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0) // Default alpha to 1
    }
}

extension TimeInterval {
    func stringFormatted() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
