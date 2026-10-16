import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pembantu/tema.dart';
import 'package:flutter_application_1/tampilan/masuk.dart';

void main() {
  testWidgets('Layar masuk ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buatTema(),
      home: const Masuk(),
    ));
    await tester.pump();

    expect(find.byType(Masuk), findsOneWidget);
  });
}
