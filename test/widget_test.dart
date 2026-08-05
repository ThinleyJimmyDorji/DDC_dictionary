// Replaces the default `flutter create` counter-app smoke test, which
// referenced a `MyApp`/counter widget that no longer exists in this app.
//
// This boots the real app -- real bundled database asset, real SQLite via
// sqflite_common_ffi -- with only `path_provider` swapped out (it's a
// platform-channel plugin with no implementation under plain
// `flutter test`; DatabaseHelper.forTesting lets us hand it a temp
// directory directly instead). Because installing the database involves
// real file I/O and native FFI calls rather than just Flutter's fake test
// clock, the boot sequence runs inside `tester.runAsync` -- see
// https://api.flutter.dev/flutter/flutter_test/WidgetTester/runAsync.html --
// so `pumpAndSettle` observes it actually finishing instead of just the
// widget tree's synchronous rebuilds.
import 'dart:io';

import 'package:ddc_dictionary/app.dart';
import 'package:ddc_dictionary/data/database_helper.dart';
import 'package:ddc_dictionary/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('app boots and shows the search field', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('ddc_dictionary_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseHelperProvider.overrideWithValue(DatabaseHelper.forTesting(tempDir)),
          ],
          child: const DdcDictionaryApp(),
        ),
      );
      await tester.pumpAndSettle();
    });

    // The search tab is the default/home destination.
    expect(find.text('Search Dzongkha or English...'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Bottom nav has all three destinations.
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
