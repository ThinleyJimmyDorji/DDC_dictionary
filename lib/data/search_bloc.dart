import 'dart:async';

import 'bloc_provider.dart';
import 'package:ddc_dictionary/models/SearchResponse.dart';
import 'package:ddc_dictionary/database.dart';

class ResultBloc implements BlocBase {
  final _notesController =
      StreamController<List<DzoSearchResponse>>.broadcast();

  StreamSink<List<DzoSearchResponse>> get _inNotes => _notesController.sink;
  Stream<List<DzoSearchResponse>> get resultStream => _notesController.stream;

  void dispose() {
    _notesController.close();
  }

  getNotes(word) async {
    print('search block Called');
    List<DzoSearchResponse> result = await DBProvider.db.getResult(word);

    _inNotes.add(result);
    print(result);
  }
}
