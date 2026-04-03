import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var soloud = SoLoud.instance;
  try {
    await soloud.init();
    print("Init successful");
  } catch (e) {
    print("Init error: $e");
  }

  try {
    soloud.filters.addGlobalFilter(FilterType.eqFilter);
    print("filters.addGlobalFilter works.");
  } catch (e) {
    print("filters.addGlobalFilter Error: $e");
  }

  try {
    soloud.addGlobalFilter(FilterType.eqFilter);
    print("addGlobalFilter works.");
  } catch (e) {
    print("addGlobalFilter Error: $e");
  }
}
