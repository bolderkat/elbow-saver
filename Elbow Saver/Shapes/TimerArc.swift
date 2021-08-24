//
//  TimerArc.swift
//  TimerArc
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI

struct TimerArc: Shape {
    let secondsRemaining: Int
    let totalSeconds: Int
    
    private var degreesPerSecond: Double {
        360.0 / Double(totalSeconds)
    }
    private var startAngle: Angle {
        Angle(degrees: 0)
    }
    
    private var endAngle: Angle {
        Angle(degrees: Double(secondsRemaining) * degreesPerSecond)
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height)
        let radius = diameter / 2
        let center = CGPoint(
            x: rect.origin.x + rect.size.width / 2.0,
            y: rect.origin.y + rect.size.height / 2.0
        )
        return Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
    }
}
