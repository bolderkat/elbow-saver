//
//  ExerciseTimerStrings.swift
//  Strings
//
//  Created by Daniel Luo on 8/27/21.
//

import Foundation

enum ExerciseTimerStrings {
    static let stopped = NSLocalizedString(
        "ExerciseTimer.stopped",
        tableName: nil,
        bundle: Bundle.main,
        value: "Stopped",
        comment: "Timer is stopped, not currently running."
    )
    static let finished = NSLocalizedString(
        "ExerciseTimer.finished",
        tableName: nil,
        bundle: Bundle.main,
        value: "Finished",
        comment: "Timer has finished counting through the entire exercise session."
    )
    static let reset = NSLocalizedString(
        "ExerciseTimer.reset",
        tableName: nil,
        bundle: Bundle.main,
        value: "RESET",
        comment: "Cue for user to reset position between reps of exercise"
    )
    static func restWith(timeRemaining: Int) -> String {
        let formatString = NSLocalizedString(
            "ExerciseTimer.rest",
            tableName: nil,
            bundle: Bundle.main,
            value: "REST: %ld",
            comment: "Cues user to rest between sets, with time remaining in seconds."
        )
        return String.localizedStringWithFormat(formatString, timeRemaining)
    }
    static func repsCounter(currentRep: Int, totalRepsInSet: Int) -> String {
        let formatString = NSLocalizedString(
            "ExerciseTimer.repsCounter",
            tableName: nil,
            bundle: Bundle.main,
            value: "%ld/%ld Reps",
            comment: "Displays user's progress of reps in an exercise set"
        )
        return String.localizedStringWithFormat(formatString, currentRep, totalRepsInSet)
    }
    static func setsCounter(currentSet: Int, totalSetsInSession: Int) -> String {
        let formatString = NSLocalizedString(
            "ExerciseTimer.setsCounter",
            tableName: nil,
            bundle: Bundle.main,
            value: "%ld/%ld Sets",
            comment: "Displays user's progress of sets in an exercise session"
        )
        return String.localizedStringWithFormat(formatString, currentSet, totalSetsInSession)
    }
}
