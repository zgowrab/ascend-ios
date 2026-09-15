import SwiftUI

/// Compatibility wrapper delegating to real human gym demonstration photography
public struct ExerciseKinematicAnimationView: View {
    let exerciseName: String
    let muscleGroup: MuscleGroup
    var height: CGFloat
    
    public init(exerciseName: String, muscleGroup: MuscleGroup, height: CGFloat = 260) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.height = height
    }
    
    public var body: some View {
        ExerciseDemonstrationView(
            exerciseName: exerciseName,
            muscleGroup: muscleGroup,
            height: height
        )
    }
}
