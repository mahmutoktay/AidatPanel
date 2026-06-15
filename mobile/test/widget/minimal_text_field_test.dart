import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aidatpanel/shared/widgets/minimal_form_widgets.dart';

void main() {
  testWidgets('MinimalTextField paired row does not overflow', (tester) async {
    final floors = TextEditingController();
    final units = TextEditingController();
    addTearDown(floors.dispose);
    addTearDown(units.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: MinimalTextField(
                      controller: floors,
                      label: 'Floor Count',
                      hint: '1–200',
                      icon: Icons.apartment_outlined,
                      required: true,
                      labelMinLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MinimalTextField(
                      controller: units,
                      label: 'Units per Floor',
                      hint: '1–50',
                      icon: Icons.door_front_door_outlined,
                      required: true,
                      labelMinLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('MinimalTextField single field in list scroll', (tester) async {
    final name = TextEditingController();
    addTearDown(name.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              MinimalTextField(
                controller: name,
                label: 'Building Name',
                hint: 'Ex: Example',
                icon: Icons.apartment_outlined,
                required: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
