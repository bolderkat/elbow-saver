import XCTest
import ComposableArchitecture
@testable import ExerciseTimer


final class ExerciseTimerUnitTests: XCTestCase {
    // NB:- Syntax is a bit unusual if unfamilar with ComposableArchitecture.
    // TestStore handles actions and compares its mutated state against
    // the expected mutation passed in via the trailing closure.
    // Absence of a closure is an assertion that there should be no state changes.
    
    
    func testStartSession() {
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        
        // ComposableArchitecture requires all effects to finish/be handled in tests, so we have to stop the timer.
        // TODO: dluo - see if there is a way to cancel the timer without needing to send this action so this can be a true unit test
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testStopTimerDuringRep() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .performingRep
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testStopTimerBetweenReps() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .betweenReps
        initialState.secondsRemainingForRep = 0
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testStopTimerBetweenSets() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .betweenSets
        initialState.secondsRemainingForRep = 0
        initialState.currentRep = ExerciseTimerState.repsPerSet
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testStopTimerWhenStopped() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .stopped
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        // Pressing Stop when timer is already stopped should NOT mutate timer state.
        store.send(.stopButtonTapped)
    }
    
    func testStopTimerWhenFinished() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .finished
        initialState.secondsRemainingForRep = 0
        initialState.currentRep = ExerciseTimerState.repsPerSet
        initialState.currentSet = initialState.totalNumberOfSets
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        // Pressing Stop when timer is already finished should NOT mutate timer state.
        store.send(.stopButtonTapped)
    }
    
    func testTimerTickWithTimerStopped() {
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: .init(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        // No state changes expected
        store.send(.timerTicked)
    }
    
    func testTimerTickWithTimerFinished() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .finished
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        // No state changes expected
        store.send(.timerTicked)
    }
    
    func testTimerTickInRep() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .performingRep
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = ExerciseTimerState().secondsRemainingForRep - 1
        
        store.send(.timerTicked) { $0.secondsRemainingForRep = expected }
    }
    
    func testTimerTickToRepResetPeriod() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .performingRep
        initialState.secondsRemainingForRep = 0
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        
        store.send(.timerTicked) {
            $0.secondsRemainingForRep = ExerciseTimerState.secondsPerRep
            $0.currentTimerState = .betweenReps
        }
    }
    
    func testTimerTickToNewRep() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .betweenReps
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = initialState.currentRep + 1
        
        store.send(.timerTicked) {
            $0.currentRep = expected
            $0.currentTimerState = .performingRep
        }
    }
    
    func testTimerTickToRestPeriod() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .performingRep
        initialState.currentRep = ExerciseTimerState.repsPerSet
        initialState.secondsRemainingForRep = 0
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.timerTicked) { $0.currentTimerState = .betweenSets }
    }
    
    func testTimerTickInRestPeriod() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .betweenSets
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = initialState.restPeriodInSeconds - 1
        
        store.send(.timerTicked) { $0.secondsRemainingInRestPeriod = expected }
    }
    
    func testTimerTickToNewSet() {
        var initialState = ExerciseTimerState()
        initialState.currentTimerState = .betweenSets
        initialState.secondsRemainingInRestPeriod = 0
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = initialState.currentSet + 1
        
        store.send(.timerTicked) {
            $0.currentSet = expected
            $0.currentTimerState = .performingRep
            $0.secondsRemainingInRestPeriod = initialState.restPeriodInSeconds
        }
    }
    
    func testTimerTickToSessionEnd() {
        var initialState = ExerciseTimerState()
        initialState.currentRep = ExerciseTimerState.repsPerSet
        initialState.currentSet = initialState.totalNumberOfSets
        initialState.currentTimerState = .performingRep
        initialState.secondsRemainingForRep = 0
        
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: initialState,
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        store.send(.timerTicked) { $0.currentTimerState = .finished }
    }
    

}
