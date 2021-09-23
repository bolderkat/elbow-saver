//
//  ExerciseSessionSettings.swift
//  ExerciseSessionSettings
//
//  Created by Daniel Luo on 8/26/21.
//

import Foundation

struct ExerciseSessionSettings {
    /// Total number of sets of exercise to be performed in this session
    let totalNumberOfSets: Int
    /// Amount of time user gets to rest between exercise sets
    let restPeriodInSeconds: Int
    
    /**
    - Parameters:
       - totalNumberOfSets: The number of sets of exercise to be performed during the session.
       - restPeriodInSeconds: The length of the rest interval between each set.
     */
    init(totalNumberOfSets: Int, restPeriodInSeconds: Int) {
        self.totalNumberOfSets = totalNumberOfSets
        self.restPeriodInSeconds = restPeriodInSeconds
    }
}
