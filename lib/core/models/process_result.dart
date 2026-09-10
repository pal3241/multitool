class ProcessResult {
  const ProcessResult({
    required this.success,
    required this.cancelled,
    required this.message,
    this.outputName,
  });

  final bool success;
  final bool cancelled;
  final String message;
  final String? outputName;
}
