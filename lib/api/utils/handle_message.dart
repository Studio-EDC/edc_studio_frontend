String extractEdcErrorMessage(Exception exception) {
  final errorString = exception.toString();
  final regex = RegExp(r'"message":"(.*?)"');
  final match = regex.firstMatch(errorString);

  if (match != null) {
    return match.group(1)!;
  } else {
    return 'Unexpected error occurred';
  }
}
