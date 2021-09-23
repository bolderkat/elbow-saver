//
//  ExerciseTimerViewModel.swift
//  ExerciseTimerViewModel
//
//  Created by Daniel Luo on 8/23/21.
//

import Foundation

class ExerciseTimerViewModel: ObservableObject {
    
    // Fixed values, not user-adjustable
    /// The number of eccentric repetitions per set of exercise.
    static let repsPerSet: Int = 3
    /// The duration over which each rep is to be performed.
    static let secondsPerRep: Int = 4
    /// The duration between reps during which user returns to the exercise start position
    static let secondsBetweenReps: Int = 1
    
    /// Settings for session including total number of sets, rest period between sets.
    private let sessionSettings: ExerciseSessionSettings
    var totalNumberOfSets: Int {
        sessionSettings.totalNumberOfSets
    }
    var restPeriodInSeconds: Int {
        sessionSettings.restPeriodInSeconds
    }
    
    /**
     Initialize a new exercise timer, guiding the user through exercise sesssion.
     Call `startSession()` to begin timing the session.
     
     Currently initializes sessionSettings with sample values, eventually will pull settings from persistent store.
     */
    init() {
        self.sessionSettings = ExerciseSessionSettings(totalNumberOfSets: 3, restPeriodInSeconds: 8)
        secondsRemainingInRestPeriod = sessionSettings.restPeriodInSeconds
    }
    
    /// The current set of exercise session
    @Published private(set) var currentSet: Int = 1
    /// The current repetition in the current set
    @Published private(set) var currentRep: Int = 1
    /// The number of seconds remaining for performance of each rep.
    @Published private(set) var secondsRemainingForRep = secondsPerRep
    /// The number of seconds remaining that the user has to return to the exercise start position
    @Published private(set) var secondsRemainingBetweenReps = secondsBetweenReps
    /// The number of seconds remaining for the rest period
    @Published private(set) var secondsRemainingInRestPeriod: Int
    
    /// The  possible states of the exercise timer.
    enum TimerState {
        /// Timer is not running.
        case stopped
        /// Timer is counting time for a rep.
        case performingRep
        /// Timer is counting time in between two reps.
        case betweenReps
        /// Timer is counting time in between two sets.
        case betweenSets
    }
    @Published private(set) var currentTimerState: TimerState = .stopped
    
    private var timer: Timer?
    private var frequency: TimeInterval = 1.0
    private var setsCompleted = 0
    
    
    /// Start the exercise session and timer
    func startSession() {
        guard setsCompleted < sessionSettings.totalNumberOfSets else { return }
        currentTimerState = .performingRep
        
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.update()
        }
    }
    
    /// Stop the exercise session and timer
    func stopSession() {
        timer?.invalidate()
        timer = nil
        currentTimerState = .stopped
    }
    
    private func update() {
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
        }
    }
    
    private func startNewRep() {
        currentTimerState = .performingRep
        secondsRemainingForRep = Self.secondsPerRep
        secondsRemainingBetweenReps = Self.secondsBetweenReps
        currentRep += 1
    }
    
    private func finishSet() {
        setsCompleted += 1
        if setsCompleted == sessionSettings.totalNumberOfSets {
            stopSession()
        } else {
            currentTimerState = .betweenSets
        }
    }
    
    private func startNewSet() {
        currentSet += 1
        currentRep = 0
        secondsRemainingInRestPeriod = sessionSettings.restPeriodInSeconds
        startNewRep()
    }
}
