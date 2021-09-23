//
//  ExerciseTimerCore.swift
//  
//
//  Created by Daniel Luo on 9/23/21.
//

import Foundation
import ComposableArchitecture

public struct ExerciseTimerState: Equatable {
    public init() {}
}

public enum ExerciseTimerAction: Equatable {
    case someAction
}

public struct ExerciseTimerEnvironment {
    public init() {}
}

let exerciseTimerReducer = Reducer<ExerciseTimerState, ExerciseTimerAction, ExerciseTimerEnvironment> { state, action, environment in
    switch action {
    case .someAction:
        return .none
    }
}
