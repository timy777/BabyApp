import 'package:shared_preferences/shared_preferences.dart';
import 'package:prueba/util/const/sharedpreferences_key.dart';

class SharedFunctions {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  deleteSharedPreferenceData() async {
    final SharedPreferences prefs = await _prefs;
    prefs.remove(SharedPreferencesKey.token);
    prefs.remove(SharedPreferencesKey.name);
    prefs.remove(SharedPreferencesKey.lastName);
  }
}
