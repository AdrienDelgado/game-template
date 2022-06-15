abstract class LevelDesignConstants {
  /// The minimum margin on the left side of the max play area, in screen width
  /// percentage. This margin might be higher depending on the play area format,
  /// as the horizontal position of the matrix area will be centered around free
  /// space let by the right and laft margins.
  static const double leftMarginPercentage = 0.1;


  /// The minimum margin on the right side of the max play area, in screen width
  /// percentage. This margin might be higher depending on the play area format,
  /// as the horizontal position of the matrix area will be centered around free
  /// space let by the right and laft margins.
  static const double rightMarginPercentage = 0.1;


  /// The minimum margin on the top side of the max play area, in screen width
  /// percentage. This margin might be higher depending on the play area format,
  /// as the vertical position of the matrix area will stick to the bottom
  /// margin.
  static const double topMarginPercentage = 0.1;


  /// The margin on the bottom side of the max play area, in screen width
  /// percentage. The matrix will sit on it exactly.
  static const double bottomMarginPercentage = 0.1;
}
