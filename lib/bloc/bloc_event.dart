abstract class FileEvent {}

class PickFile extends FileEvent {}

class DownloadFile extends FileEvent {
  final String filePath;

  DownloadFile(this.filePath);
}
