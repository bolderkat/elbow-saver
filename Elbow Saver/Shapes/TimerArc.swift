//
//  TimerArc.swift
//  TimerArc
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI

struct TimerArc: Shape {
    var secondsRemaining: Double
    let totalSeconds: Double
    
    init(secondsRemaining: Int, totalSeconds: Int) {
        self.secondsRemaining = Double(secondsRemaining)
        self.totalSeconds = Double(totalSeconds)
    }
    
    var animatableData: Double {
        get { return secondsRemaining }
        set { secondsRemaining = newValue }
    }
    
    private var degreesPerSecond: Double {
        guard totalSeconds != 0 else {
            assertionFailure("Unable to divide by 0")
            return 0.0
        }
        let degreesInCircle = 360.0
        return degreesInCircle / totalSeconds
    }
    private var startAngle: Angle {
        Angle(degrees: 0)
    }
    
    private var endAngle: Angle {
        Angle(degrees: secondsRemaining * degreesPerSecond)
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
