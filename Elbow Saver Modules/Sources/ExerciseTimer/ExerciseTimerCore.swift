//
//  ExerciseTimerCore.swift
//  
//
//  Created by Daniel Luo on 9/23/21.
//

import Foundation
import ComposableArchitecture

public struct ExerciseTimerState: Equatable {
    // Fixed values, not user-adjustable
    /// The number of eccentric repetitions per set of exercise.
    static let repsPerSet: Int = 3
    /// The duration over which each rep is to be performed.
    static let secondsPerRep: Int = 4
    /// The duration between reps during which user returns to the exercise start position
    static let secondsBetweenReps: Int = 1
    
    /// Settings for session including total number of sets, rest period between sets.
    private let sessionSettings: ExerciseSessionSettings
    public var totalNumberOfSets: Int {
        sessionSettings.totalNumberOfSets
    }
    public var restPeriodInSeconds: Int {
        sessionSettings.restPeriodInSeconds
    }
    
    /**
     Initialize a new exercise timer, guiding the user through exercise sesssion.
     
     Currently initializes sessionSettings with sample values, eventually will pull settings from persistent store.
     */
    init() {
        self.sessionSettings = ExerciseSessionSettings(totalNumberOfSets: 3, restPeriodInSeconds: 8)
        secondsRemainingInRestPeriod = sessionSettings.restPeriodInSeconds
    }
    
    /// The current set of exercise session
    public var currentSet: Int = 1
    /// The current repetition in the current set
    public var currentRep: Int = 1
    /// The number of seconds remaining for performance of each rep.
    public var secondsRemainingForRep = secondsPerRep
    /// The number of seconds remaining that the user has to return to the exercise start position
    public var secondsRemainingBetweenReps = secondsBetweenReps
    /// The number of seconds remaining for the rest period
    public var secondsRemainingInRestPeriod: Int
    
    /// The  possible states of the exercise timer.
    public enum TimerState {
        /// Timer is not running.
        case stopped
        /// Timer is counting time for a rep.
        case performingRep
        /// Timer is counting time in between two reps.
        case betweenReps
        /// Timer is counting time in between two sets.
        case betweenSets
        /// Timer has completed the entire session.
        case finished
    }
    public var currentTimerState: TimerState = .stopped
    
    public mutating func update() {
        switch currentTimerState {
        case .stopped:
            return
        case .performingRep:
            if secondsRemainingForRep <= 0,
               currentRep < Self.repsPerSet {
                // Finished a rep, but still have reps to go in the set
                currentTimerState = .betweenReps
                secondsRemainingForRep = Self.secondsPerRep
            } else if secondsRemainingForRep <= 0,
                      currentRep == Self.repsPerSet {
                // Finished the final rep of the set
                finishSet()
            } else {
                secondsRemainingForRep -= 1
            }
        case .betweenReps:
            // Condition triggered at 1 to shorten reset period between reps
            if secondsRemainingBetweenReps <= 1 {
                startNewRep()
            } else {
                secondsRemainingBetweenReps -= 1
            }
        case .betweenSets:
            if secondsRemainingInRestPeriod <= 0 {
                startNewSet()
            } else {
                secondsRemainingInRestPeriod -= 1
            }
        case .finished:
            return
        }
    }
    
    private mutating func startNewRep() {
        currentTimerState = .performingRep
        secondsRemainingForRep = Self.secondsPerRep
        secondsRemainingBetweenReps = Self.secondsBetweenReps
        currentRep += 1
    }
    
    private mutating func finishSet() {
        if currentSet == sessionSettings.totalNumberOfSets {
            currentTimerState = .finished
        } else {
            currentTimerState = .betweenSets
        }
    }
    
    private mutating func startNewSet() {
        currentSet += 1
        currentRep = 0
        secondsRemainingInRestPeriod = sessionSettings.restPeriodInSeconds
        startNewRep()
    }
}

public enum ExerciseTimerAction: Equatable {
    /// Starts timer at beginning of session
    case sessionStarted
    case timerPaused
    /// Resumes timer in the middle of a session (i.e., unpaused).
    case timerResumed
    case timerTicked
    case stopButtonTapped
}

public struct ExerciseTimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let exerciseTimerReducer = Reducer<ExerciseTimerState, ExerciseTimerAction, ExerciseTimerEnvironment> { state, action, environment in
    struct TimerId: Hashable {}
    let timerFrequency: DispatchQueue.SchedulerTimeType.Stride = 1
    let timer = Effect.timer(id: TimerId(), every: timerFrequency, on: environment.mainQueue)
        .map { _ in ExerciseTimerAction.timerTicked }
    
    switch action {
    case .sessionStarted:
        state.currentTimerState = .performingRep
        return timer
        
    case .timerPaused:
        return .none // placeholder
        
    case .timerResumed:
        return timer
        
    case .timerTicked:
        state.update()
        if state.currentTimerState == .finished ||
            state.currentTimerState == .stopped {
            return .cancel(id: TimerId())
        } else {
            return .none
        }
        
    case .stopButtonTapped:
        state.currentTimerState = .stopped
        return .cancel(id: TimerId())
    }
}
