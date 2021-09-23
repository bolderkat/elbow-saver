//
//  ExerciseTimerView.swift
//  Elbow Saver
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI

public struct ExerciseTimerView: View {
    private enum Parameters {
        static let arcStrokeWidth: CGFloat = 24.0
        static let arcPadding: CGFloat = 20.0
        static let timerArcRotation: Double = -90.0
    }
    
    // Using temporary values for exercise session settings
    @StateObject private var exerciseTimer = ExerciseTimerViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            TimerArc(secondsRemaining: secondsRemaining, totalSeconds: totalSeconds)
                .stroke(.white, lineWidth: Parameters.arcStrokeWidth)
                .rotationEffect(Angle(degrees: Parameters.timerArcRotation))
                .animation(.easeInOut)
                .padding(Parameters.arcPadding)
            VStack {
                Text(timeText)
                    .font(.largeTitle)
                    .padding()
                Text(ExerciseTimerStrings.repsCounter(currentRep: exerciseTimer.currentRep, totalRepsInSet: ExerciseTimerViewModel.repsPerSet))
                Text(ExerciseTimerStrings.setsCounter(currentSet: exerciseTimer.currentSet, totalSetsInSession: exerciseTimer.totalNumberOfSets))
            }
            .foregroundColor(.white)
        }
        .onAppear {
            exerciseTimer.startSession()
        }
    }
    
    private var timeText: String {
        switch exerciseTimer.currentTimerState {
        case .stopped:
            return ExerciseTimerStrings.stopped
        case .performingRep:
            return "\(exerciseTimer.secondsRemainingForRep)"
        case .betweenReps:
            return ExerciseTimerStrings.reset.uppercased()
        case .betweenSets:
            return ExerciseTimerStrings.restWith(timeRemaining: exerciseTimer.secondsRemainingInRestPeriod).uppercased()
        }
    }
    
    private var backgroundColor: Color {
        switch exerciseTimer.currentTimerState {
        case .stopped:
            return .red
        case .performingRep:
            return .green
        case .betweenReps:
            return .orange
        case .betweenSets:
            return .blue
        }
    }
    
    // For calculation of arc
    private var secondsRemaining: Int {
        switch exerciseTimer.currentTimerState {
        case .stopped:
            return 0
        case .performingRep, .betweenReps:
            return exerciseTimer.secondsRemainingForRep
        case .betweenSets:
            return exerciseTimer.secondsRemainingInRestPeriod
        }
    }
    
    // For calculation of arc
    private var totalSeconds: Int {
        switch exerciseTimer.currentTimerState {
        case .stopped:
            return 1
        case .performingRep, .betweenReps:
            return ExerciseTimerViewModel.secondsPerRep
        case .betweenSets:
            return exerciseTimer.restPeriodInSeconds
        }
    }
    
}

struct ExerciseTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTimerView()
    }
}
