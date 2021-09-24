//
//  ExerciseSessionSettings.swift
//  ExerciseSessionSettings
//
//  Created by Daniel Luo on 8/26/21.
//

import Foundation

public struct ExerciseSessionSettings: Equatable {
    /// Total number of sets of exercise to be performed in this session
    public let totalNumberOfSets: Int
    /// Amount of time user gets to rest between exercise sets
    public let restPeriodInSeconds: Int
    
    /**
    - Parameters:
       - totalNumberOfSets: The number of sets of exercise to be performed during the session.
       - restPeriodInSeconds: The length of the rest interval between each set.
     */
    public init(totalNumberOfSets: Int, restPeriodInSeconds: Int) {
        self.totalNumberOfSets = totalNumberOfSets
        self.restPeriodInSeconds = restPeriodInSeconds
    }
}
