// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc_event.dart';
import 'bloc_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  FileBloc() : super(FileInitial()) {
    on<PickFile>(_onPickFile);
    on<DownloadFile>(_onDownloadFile);
    _checkDownloadedFile();
  }

  void _onPickFile(PickFile event, Emitter<FileState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        final filePath = result.files.single.path;
        final fileName = result.files.single.name;
        emit(FilePicked(fileName, filePath!));
      } else {
        emit(FileError('No file selected'));
      }
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  void _onDownloadFile(DownloadFile event, Emitter<FileState> emit) async {
    emit(FileDownloading());
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = event.filePath.split('/').last;
      final filePath = '${appDocDir.path}/$fileName';

      // Use compute to run the file copy in an isolate
      final resultPath = await compute(_copyFile, [event.filePath, filePath]);

      emit(FileDownloaded(resultPath));

      // Save the downloaded file path to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('downloaded_file', resultPath);
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> _checkDownloadedFile() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedFilePath = prefs.getString('downloaded_file');
    if (downloadedFilePath != null && File(downloadedFilePath).existsSync()) {
      emit(FileDownloaded(downloadedFilePath));
    } else {
      emit(FileInitial());
    }
  }

  static Future<String> _copyFile(List<String> paths) async {
    final sourcePath = paths[0];
    final destinationPath = paths[1];
    final file = File(sourcePath);
    await file.copy(destinationPath);
    return destinationPath;
  }
}
