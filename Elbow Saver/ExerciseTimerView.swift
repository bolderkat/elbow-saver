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
        static let arcPadding: CGFloat = 20.0
    }
    
    @StateObject private var exerciseTimer = ExerciseTimer(totalNumberOfSets: 3, restPeriodInSeconds: 8)
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            TimerArc(secondsRemaining: secondsRemaining, totalSeconds: totalSeconds)
                .stroke(.white, lineWidth: Parameters.arcStrokeWidth)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut)
                .padding(Parameters.arcPadding)
            VStack {
                Text(timeText)
                    .font(.largeTitle)
                    .padding()
                Text("\(exerciseTimer.currentRep)/\(ExerciseTimer.repsPerSet) Reps")
                Text("\(exerciseTimer.currentSet)/\(exerciseTimer.totalNumberOfSets) Sets")
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
            return ExerciseTimer.secondsPerRep
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
