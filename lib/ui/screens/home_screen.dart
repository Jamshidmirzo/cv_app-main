import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mycv_app/bloc/bloc.dart';
import 'package:mycv_app/bloc/bloc_event.dart';
import 'package:mycv_app/bloc/bloc_state.dart';
import 'package:open_file/open_file.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.menu,
          color: Colors.deepPurple,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<FileBloc>().add(PickFile());
            },
            icon: SvgPicture.asset(
              'assets/icons/pdf.svg',
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BlocBuilder<FileBloc, FileState>(
                builder: (context, state) {
                  if (state is FilePicked) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Selected File: ${state.fileName}'),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<FileBloc>()
                                .add(DownloadFile(state.filePath));
                          },
                          child: const Text('Download'),
                        ),
                      ],
                    );
                  } else if (state is FileDownloaded) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: PDFView(
                            filePath: state.filePath,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: false,
                            pageFling: false,
                            onRender: (pages) {
                              print('Pages: $pages');
                            },
                            onError: (error) {
                              print(error.toString());
                            },
                            onPageError: (page, error) {
                              print('Error on page: $page, $error');
                            },
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(343, 40),
                              backgroundColor: Colors.deepPurple),
                          onPressed: () {
                            _openFile(state.filePath);
                          },
                          child: const Text(
                            'Open',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else if (state is FileError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return const Text('No PDF chosen');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
