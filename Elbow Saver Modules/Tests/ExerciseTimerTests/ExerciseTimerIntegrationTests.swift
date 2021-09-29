import XCTest
import ComposableArchitecture
@testable import ExerciseTimer


final class ExerciseTimerIntegrationTests: XCTestCase {
    // NB:- Syntax is a bit unusual if unfamilar with ComposableArchitecture.
    // TestStore handles actions and compares its mutated state against
    // the expected mutation passed in via the trailing closure.
    // Absence of a closure is an assertion that there should be no state changes.
    
    let scheduler = DispatchQueue.test
    
    
    
    func testStartStopTimer() {
        let store = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = ExerciseTimerState().secondsRemainingForRep - 1
        
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        scheduler.advance(by: .seconds(1))
        store.receive(.timerTicked) { $0.secondsRemainingForRep = expected }
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testOneRepAndReset() {
        let store = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let secondsPerRep = ExerciseTimerState.secondsPerRep
        
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        for currentSecond in 1...secondsPerRep {
            scheduler.advance(by: .seconds(1))
            store.receive(.timerTicked) { $0.secondsRemainingForRep = secondsPerRep - currentSecond }
        }
        
        scheduler.advance(by: .seconds(1))
        store.receive(.timerTicked) {
            $0.currentTimerState = .betweenReps
            $0.secondsRemainingForRep = secondsPerRep
        }
        
        scheduler.advance(by: .seconds(1))
        store.receive(.timerTicked) {
            $0.currentTimerState = .performingRep
            $0.currentRep = 2
        }
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testOneSet() {
        let store = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let reps = ExerciseTimerState.repsPerSet
        let secondsPerRep = ExerciseTimerState.secondsPerRep
        
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        
        // Do every rep up to the last one
        for currentRep in 1..<reps {
            // Do a rep
            for currentSecond in 1...secondsPerRep {
                scheduler.advance(by: .seconds(1))
                store.receive(.timerTicked) {
                    $0.secondsRemainingForRep = secondsPerRep - currentSecond
                }
            }
            // Reset to next rep
            scheduler.advance(by: .seconds(1))
            store.receive(.timerTicked) {
                $0.currentTimerState = .betweenReps
                $0.secondsRemainingForRep = secondsPerRep
            }
            
            scheduler.advance(by: .seconds(1))
            store.receive(.timerTicked) {
                $0.currentTimerState = .performingRep
                $0.currentRep = currentRep + 1
            }
        }
        
        // Do final rep in set
        for currentSecond in 1...secondsPerRep {
            scheduler.advance(by: .seconds(1))
            store.receive(.timerTicked) {
                $0.secondsRemainingForRep = secondsPerRep - currentSecond
            }
        }
        
        scheduler.advance(by: .seconds(1))
        store.receive(.timerTicked) {
            $0.currentTimerState = .betweenSets
        }
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }

    
    func testRunEntireSession() {
        let store = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let sets = ExerciseTimerState().totalNumberOfSets
        let reps = ExerciseTimerState.repsPerSet
        let secondsPerRep = ExerciseTimerState.secondsPerRep
        let secondsBetweenSets = ExerciseTimerState().restPeriodInSeconds
        
        func performRep() {
            // Loop through all seconds for duration of rep
            for currentSecond in 1...secondsPerRep {
                scheduler.advance(by: .seconds(1))
                store.receive(.timerTicked) {
                    $0.secondsRemainingForRep = secondsPerRep - currentSecond
                }
            }
        }
        
        func performSet() {
            // Do every rep up to the last one
            for currentRep in 1..<reps {
                // Do a rep
                performRep()
                
                // Begin reset sequence
                scheduler.advance(by: .seconds(1))
                store.receive(.timerTicked) {
                    $0.currentTimerState = .betweenReps
                    $0.secondsRemainingForRep = secondsPerRep
                }
                
                // Reset to next rep
                scheduler.advance(by: .seconds(1))
                store.receive(.timerTicked) {
                    $0.currentTimerState = .performingRep
                    $0.currentRep = currentRep + 1
                }
            }
            
            // Do final rep in set
            performRep()
        }
        
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        
        // Do every set up to the last one
        for currentSet in 1..<sets {
           performSet()
            
            // Rest between sets
            for currentSecond in 0...secondsBetweenSets {
                scheduler.advance(by: .seconds(1))
                store.receive(.timerTicked) {
                    $0.currentTimerState = .betweenSets
                    $0.secondsRemainingInRestPeriod = secondsBetweenSets - currentSecond
                }
            }
            
            // Reset to next set
            scheduler.advance(by: .seconds(1))
            store.receive(.timerTicked) {
                $0.currentTimerState = .performingRep
                $0.currentSet = currentSet + 1
                $0.currentRep = 1
                $0.secondsRemainingInRestPeriod = secondsBetweenSets
                $0.secondsRemainingForRep = secondsPerRep
            }
        }
        
        // Do final set
        performSet()
        
        scheduler.advance(by: .seconds(1))
        store.receive(.timerTicked) {
            $0.currentTimerState = .finished
        }
        
        // ComposableArchitecture requires all effects to finish/be handled in tests, so we have to stop the timer.
        // TODO: dluo - see if there is a way to cancel the timer so we don't have to send this at the end.
        store.send(.stopButtonTapped) { $0.currentTimerState = .finished }
    }
}
