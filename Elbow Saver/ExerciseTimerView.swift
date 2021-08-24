//
//  ExerciseTimerView.swift
//  Elbow Saver
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI

struct ExerciseTimerView: View {
    private enum Parameters {
        static let arcStrokeWidth: CGFloat = 24.0
    }
    
    @StateObject private var exerciseTimer = ExerciseTimer(totalNumberOfSets: 3, restPeriodInSeconds: 10)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            TimerArc(secondsRemaining: secondsRemaining, totalSeconds: totalSeconds)
                .stroke(.white, lineWidth: Parameters.arcStrokeWidth)
                .rotationEffect(Angle(degrees: -90))
                .padding()
            VStack {
                Text(timeText)
                    .font(.largeTitle)
                    .padding()
                Text("Reps: \(exerciseTimer.currentRep)/\(ExerciseTimer.repsPerSet)")
                Text("Sets: \(exerciseTimer.currentSet)/\(exerciseTimer.totalNumberOfSets)")
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
            return "Stopped"
        case .performingRep:
            return "\(exerciseTimer.secondsRemainingForRep)"
        case .betweenReps:
            return "RESET"
        case .betweenSets:
            return "REST: \(exerciseTimer.secondsRemainingInRestPeriod)"
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
        case .performingRep:
            return exerciseTimer.secondsRemainingForRep
        case .betweenReps:
            return ExerciseTimer.secondsBetweenReps // always show full circle for reset phase
        case .betweenSets:
            return exerciseTimer.secondsRemainingInRestPeriod
        }
    }
    
    // For calculation of arc
    private var totalSeconds: Int {
        switch exerciseTimer.currentTimerState {
        case .stopped:
            return 1
        case .performingRep:
            return ExerciseTimer.secondsPerRep
        case .betweenReps:
            return ExerciseTimer.secondsBetweenReps
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
