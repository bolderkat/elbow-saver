//
//  ExerciseTimerView.swift
//  Elbow Saver
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI

struct ExerciseTimerView: View {
    @StateObject private var exerciseTimer = ExerciseTimer(totalNumberOfSets: 3, restPeriodInSeconds: 10)
    var timeText: String {
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
    
    var backgroundColor: Color {
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
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack {
            Text(timeText)
                .font(.largeTitle)
                .padding()
                .onAppear {
                    exerciseTimer.startSession()
                }
                Text("Reps: \(exerciseTimer.currentRep)/\(ExerciseTimer.repsPerSet)")
                Text("Sets: \(exerciseTimer.currentSet)/\(exerciseTimer.totalNumberOfSets)")
                
            }
            .foregroundColor(.white)
        }
    }
}

struct ExerciseTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTimerView()
    }
}
