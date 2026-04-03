import 'package:flutter_soloud/flutter_soloud.dart';

void main() async {
  var soloud = SoLoud.instance;
  try {
    soloud.filters.addGlobalFilter(FilterType.eqFilter);
    print("filters.addGlobalFilter works.");
  } catch (e) {
    print("Error 1: $e");
  }

  try {
    soloud.addGlobalFilter(FilterType.eqFilter);
    print("addGlobalFilter works.");
  } catch (e) {
    print("Error 2: $e");
  }
}
