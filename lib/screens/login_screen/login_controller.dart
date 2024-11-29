import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'login_model.dart';
import '../mysharedPref.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  Future<bool> loginUser() async {
    await MySharedPref.init();

    var url = "https://beds-accomodation.vercel.app/api/empLogin";
    var data = {
      "email": email.value,
      "password": password.value
    };
    var body = json.encode(data);
    var urlParse = Uri.parse(url);

    try {
      var response = await http.post(
        urlParse,
        body: body,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var loginModel = LoginModel.fromJson(responseData);

        if (loginModel.success == 1 && loginModel.data != null) {
          await MySharedPref.setLoginStatus(true);
          await MySharedPref.setUserName(loginModel.data!.name ?? 'No Name');
          await MySharedPref.setUserEmail(loginModel.data!.email ?? 'No Email');
          await MySharedPref.setUserContact(
              loginModel.data!.contact ?? 'No Contact');
          await MySharedPref.setUserDepartment(
              loginModel.data!.deptName ?? 'No Department');
          await MySharedPref.setUserGender(
              loginModel.data!.gender ?? 'No Gender');
          return true;
        }
      }
      // Get.snackbar('Login Failed', 'Please try again');
      return false;
    } catch (e) {
      print("error value $e");
      // Get.snackbar('Error', 'Error during login: $e');
      return false;
    }
  }
}
