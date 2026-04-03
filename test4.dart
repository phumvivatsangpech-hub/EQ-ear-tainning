import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var soloud = SoLoud.instance;
  await soloud.init();
  print("Init successful");
  
  soloud.addGlobalFilter(FilterType.eqFilter);
  print("Filter added.");
  
  try {
    soloud.removeGlobalFilter(FilterType.eqFilter);
    print("Filter removed.");
  } catch(e) {
    print("Error removing: $e");
  }
  
  soloud.addGlobalFilter(FilterType.eqFilter);
  print("Filter added again.");
}
