// bloc_state.dart
abstract class FileState {}

class FileInitial extends FileState {}

class FilePicked extends FileState {
  final String fileName;
  final String filePath;

  FilePicked(this.fileName, this.filePath);
}

class FileDownloading extends FileState {}

class FileDownloaded extends FileState {
  final String filePath;

  FileDownloaded(this.filePath);
}

class FileError extends FileState {
  final String message;

  FileError(this.message);
}
