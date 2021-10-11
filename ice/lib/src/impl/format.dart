part of ice;

enum FormatType {
  ///
  /// Indicates that no preference was specified.
  ///
  defaultFormat,

  ///
  /// A minimal format that eliminates the possibility for slicing unrecognized types.
  ///
  compactFormat,

  ///
  /// Allow slicing and preserve slices for unknown types.
  ///
  slicedFormat
}
