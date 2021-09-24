import XCTest
import ComposableArchitecture
@testable import ExerciseTimer


final class ExerciseTimerTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    let store = TestStore(
        initialState: ExerciseTimerState(),
        reducer: exerciseTimerReducer,
        environment: .init(mainQueue: DispatchQueue.test.eraseToAnyScheduler())
    )
    
    func testStartSession() {
        store.send(.sessionStarted) { $0.currentTimerState = .performingRep }
    }
    
    func testStartStopTimer() {
        let timerStore = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let expected = ExerciseTimerState().secondsRemainingForRep - 1
        
        timerStore.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        scheduler.advance(by: .seconds(1))
        timerStore.receive(.timerTicked) { $0.secondsRemainingForRep = expected }
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testOneRepAndReset() {
        let timerStore = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let secondsPerRep = ExerciseTimerState.secondsPerRep
        
        timerStore.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        for currentSecond in 1...secondsPerRep {
            scheduler.advance(by: .seconds(1))
            timerStore.receive(.timerTicked) { $0.secondsRemainingForRep = secondsPerRep - currentSecond }
        }
        
        scheduler.advance(by: .seconds(1))
        timerStore.receive(.timerTicked) {
            $0.currentTimerState = .betweenReps
            $0.secondsRemainingForRep = secondsPerRep
        }
        
        scheduler.advance(by: .seconds(1))
        timerStore.receive(.timerTicked) {
            $0.currentTimerState = .performingRep
            $0.currentRep = 2
        }
        
        store.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
    
    func testOneSet() {
        let timerStore = TestStore(
            initialState: ExerciseTimerState(),
            reducer: exerciseTimerReducer,
            environment: .init(mainQueue: scheduler.eraseToAnyScheduler())
        )
        
        let reps = ExerciseTimerState.repsPerSet
        let secondsPerRep = ExerciseTimerState.secondsPerRep
        
        timerStore.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        
        // Do every rep up to the last one
        for currentRep in 1..<reps {
            // Do a rep
            for currentSecond in 1...secondsPerRep {
                scheduler.advance(by: .seconds(1))
                timerStore.receive(.timerTicked) {
                    $0.secondsRemainingForRep = secondsPerRep - currentSecond
                }
            }
            // Reset to next rep
            scheduler.advance(by: .seconds(1))
            timerStore.receive(.timerTicked) {
                $0.currentTimerState = .betweenReps
                $0.secondsRemainingForRep = secondsPerRep
            }
            
            scheduler.advance(by: .seconds(1))
            timerStore.receive(.timerTicked) {
                $0.currentTimerState = .performingRep
                $0.currentRep = currentRep + 1
            }
        }
        
        // Do final rep in set
        for currentSecond in 1...secondsPerRep {
            scheduler.advance(by: .seconds(1))
            timerStore.receive(.timerTicked) {
                $0.secondsRemainingForRep = secondsPerRep - currentSecond
            }
        }
        
        scheduler.advance(by: .seconds(1))
        timerStore.receive(.timerTicked) {
            $0.currentTimerState = .betweenSets
        }
        
        timerStore.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }

    
    func testRunEntireSession() {
        let timerStore = TestStore(
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
                timerStore.receive(.timerTicked) {
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
                timerStore.receive(.timerTicked) {
                    $0.currentTimerState = .betweenReps
                    $0.secondsRemainingForRep = secondsPerRep
                }
                
                // Reset to next rep
                scheduler.advance(by: .seconds(1))
                timerStore.receive(.timerTicked) {
                    $0.currentTimerState = .performingRep
                    $0.currentRep = currentRep + 1
                }
            }
            
            // Do final rep in set
            performRep()
        }
        
        timerStore.send(.sessionStarted) { $0.currentTimerState = .performingRep }
        
        // Do every set up to the last one
        for currentSet in 1..<sets {
           performSet()
            
            // Rest between sets
            for currentSecond in 0...secondsBetweenSets {
                scheduler.advance(by: .seconds(1))
                timerStore.receive(.timerTicked) {
                    $0.currentTimerState = .betweenSets
                    $0.secondsRemainingInRestPeriod = secondsBetweenSets - currentSecond
                }
            }
            
            // Reset to next set
            scheduler.advance(by: .seconds(1))
            timerStore.receive(.timerTicked) {
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
        timerStore.receive(.timerTicked) {
            $0.currentTimerState = .finished
        }
        
        timerStore.send(.stopButtonTapped) { $0.currentTimerState = .stopped }
    }
}
