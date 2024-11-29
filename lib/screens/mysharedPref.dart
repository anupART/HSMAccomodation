// import 'package:shared_preferences/shared_preferences.dart';
//
// class MySharedPref {
//   MySharedPref._();
//   static SharedPreferences? _sharedPreferences;
//
//   // STORING KEYS
//   static const String _login = 'login';
//   static const String _userName = 'userName';
//   static const String _userEmail = 'userEmail';
//   static const String _userContact = 'userContact';
//   static const String _userDepartment = 'userDepartment';
//   static const String _userGender = 'userGender';
//
//   static Future<void> init() async {
//     _sharedPreferences ??= await SharedPreferences.getInstance();
//   }
//
//   static setStorage(SharedPreferences sharedPreferences) {
//     _sharedPreferences = sharedPreferences;
//   }
//
//   static Future<bool> setLoginStatus(bool status) async {
//     await init();
//     return await _sharedPreferences!.setBool(_login, status);
//   }
//
//   static bool getLoginStatus() {
//     return _sharedPreferences?.getBool(_login) ?? false;
//   }
//
//   static Future<bool> setUserName(String name) async {
//     await init();
//     return await _sharedPreferences!.setString(_userName, name);
//   }
//
//   static String? getUserName() {
//     return _sharedPreferences?.getString(_userName);
//   }
//
//   static Future<bool> setUserEmail(String email) async {
//     await init();
//     return await _sharedPreferences!.setString(_userEmail, email);
//   }
//
//   static String? getUserEmail() {
//     return _sharedPreferences?.getString(_userEmail);
//   }
//
//   static Future<bool> setUserContact(String contact) async {
//     await init();
//     return await _sharedPreferences!.setString(_userContact, contact);
//   }
//
//   static String? getUserContact() {
//     return _sharedPreferences?.getString(_userContact);
//   }
//
//   static Future<bool> setUserDepartment(String department) async {
//     await init();
//     return await _sharedPreferences!.setString(_userDepartment, department);
//   }
//
//   static String? getUserDepartment() {
//     return _sharedPreferences?.getString(_userDepartment);
//   }
//
//   static Future<bool> setUserGender(String gender) async {
//     await init();
//     return await _sharedPreferences!.setString(_userGender, gender);
//   }
//
//   static String? getUserGender() {
//     return _sharedPreferences?.getString(_userGender);
//   }
//
//   static Future<void> clear() async {
//     await init();
//     await _sharedPreferences!.clear();
//   }
// }


import 'package:shared_preferences/shared_preferences.dart';

class MySharedPref {
  MySharedPref._();
  static SharedPreferences? _sharedPreferences;

  // STORING KEYS
  static const String _login = 'login';
  static const String _userName = 'userName';
  static const String _userEmail = 'userEmail';
  static const String _userContact = 'userContact';
  static const String _userDepartment = 'userDepartment';
  static const String _userGender = 'userGender';

  static Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  static void setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  static Future<bool> setLoginStatus(bool status) async {
    await init();
    return await _sharedPreferences!.setBool(_login, status);
  }

  static bool getLoginStatus() {
    return _sharedPreferences?.getBool(_login) ?? false;
  }

  static Future<bool> setUserName(String name) async {
    await init();
    return await _sharedPreferences!.setString(_userName, name);
  }

  static String? getUserName() {
    return _sharedPreferences?.getString(_userName);
  }

  static Future<bool> setUserEmail(String email) async {
    await init();
    return await _sharedPreferences!.setString(_userEmail, email);
  }

  static String? getUserEmail() {
    return _sharedPreferences?.getString(_userEmail);
  }

  static Future<bool> setUserContact(String contact) async {
    await init();
    return await _sharedPreferences!.setString(_userContact, contact);
  }

  static String? getUserContact() {
    return _sharedPreferences?.getString(_userContact);
  }

  static Future<bool> setUserDepartment(String department) async {
    await init();
    return await _sharedPreferences!.setString(_userDepartment, department);
  }

  static String? getUserDepartment() {
    return _sharedPreferences?.getString(_userDepartment);
  }

  static Future<bool> setUserGender(String gender) async {
    await init();
    return await _sharedPreferences!.setString(_userGender, gender);
  }

  static String? getUserGender() {
    return _sharedPreferences?.getString(_userGender);
  }

  static Future<void> clear() async {
    await init();
    await _sharedPreferences!.clear();
  }

  // Debug method to print all stored values
  static void printStoredValues() {
    print('Stored Values:');
    print('Login Status: ${getLoginStatus()}');
    print('User Name: ${getUserName()}');
    print('User Email: ${getUserEmail()}');
    print('User Contact: ${getUserContact()}');
    print('User Department: ${getUserDepartment()}');
    print('User Gender: ${getUserGender()}');
  }
}