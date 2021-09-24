//
//  ExerciseTimerView.swift
//  Elbow Saver
//
//  Created by Daniel Luo on 8/23/21.
//

import SwiftUI
import ComposableArchitecture

public struct ExerciseTimerView: View {
    private enum Parameters {
        static let arcStrokeWidth: CGFloat = 24.0
        static let arcPadding: CGFloat = 20.0
        static let timerArcRotation: Double = -90.0
    }
    
    let store: Store<ExerciseTimerState, ExerciseTimerAction>
    let viewStore: ViewStore<ExerciseTimerState, ExerciseTimerAction>
    
    public init() {
        store = Store<ExerciseTimerState, ExerciseTimerAction>(
            // Using temporary values for exercise session settings
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: ExerciseTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        )
        viewStore = ViewStore(store)
    }
    
    public var body: some View {
        // TODO: dluo- limit viewStore scope to only what is necessary to render the view?
        WithViewStore(store) { viewStore in
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
                    Text(ExerciseTimerStrings.repsCounter(currentRep: viewStore.currentRep, totalRepsInSet: ExerciseTimerState.repsPerSet))
                    Text(ExerciseTimerStrings.setsCounter(currentSet: viewStore.currentSet, totalSetsInSession: viewStore.totalNumberOfSets))
                }
                .foregroundColor(.white)
            }
            .onAppear {
                viewStore.send(.sessionStarted)
            }
        }
    }
    
    private var timeText: String {
        switch viewStore.currentTimerState {
        case .stopped:
            return ExerciseTimerStrings.stopped
        case .performingRep:
            return "\(viewStore.secondsRemainingForRep)"
        case .betweenReps:
            return ExerciseTimerStrings.reset.uppercased()
        case .betweenSets:
            return ExerciseTimerStrings.restWith(timeRemaining: viewStore.secondsRemainingInRestPeriod).uppercased()
        case .finished:
            return ExerciseTimerStrings.finished
        }
    }
    
    private var backgroundColor: Color {
        switch viewStore.currentTimerState {
        case .stopped, .finished:
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
        switch viewStore.currentTimerState {
        case .stopped, .finished:
            return 0
        case .performingRep, .betweenReps:
            return viewStore.secondsRemainingForRep
        case .betweenSets:
            return viewStore.secondsRemainingInRestPeriod
        }
    }
    
    // For calculation of arc
    private var totalSeconds: Int {
        switch viewStore.currentTimerState {
        case .stopped, .finished:
            return 1
        case .performingRep, .betweenReps:
            return ExerciseTimerState.secondsPerRep
        case .betweenSets:
            return viewStore.restPeriodInSeconds
        }
    }
    
}

struct ExerciseTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTimerView()
    }
}
