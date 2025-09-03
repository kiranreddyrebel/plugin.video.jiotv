import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('https://api.jio.com/v3/dip/user/unpw/verify');
    final headers = {
      'User-Agent': 'JioTV',
      'x-api-key': 'l7xx75e822925f184370b2e25170c5d5820a',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'identifier': username.contains('@') ? username : '+91$username',
      'password': password,
      'rememberUser': 'T',
      'upgradeAuth': 'Y',
      'returnSessionDetails': 'T',
      'deviceInfo': {
        'consumptionDeviceName': 'ZUK Z1',
        'info': {
          'type': 'android',
          'platform': {'name': 'ham', 'version': '8.0.0'},
          'androidId': _uuid.v4(),
        },
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData.containsKey('ssoToken')) {
        await _storeCredentials(responseData);
        return null;
      } else {
        return responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendOtp(String mobile) async {
    final url = Uri.parse('https://jiotvapi.media.jio.com/userservice/apis/v1/loginotp/send');
    final headers = {
      'user-agent': 'okhttp/4.2.2',
      'os': 'android',
      'host': 'jiotvapi.media.jio.com',
      'devicetype': 'phone',
      'appname': 'RJIL_JioTV',
    };
    final body = jsonEncode({
      'number': base64.encode(utf8.encode('+91$mobile')),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 204) {
        return null;
      } else {
        final responseData = jsonDecode(response.body);
        return responseData['errors']?[0]?['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyOtp(String mobile, String otp) async {
    final url = Uri.parse('https://jiotvapi.media.jio.com/userservice/apis/v1/loginotp/verify');
    final headers = {
      'User-Agent': 'okhttp/4.2.2',
      'devicetype': 'phone',
      'os': 'android',
      'appname': 'RJIL_JioTV',
    };
    final body = jsonEncode({
      'number': base64.encode(utf8.encode('+91$mobile')),
      'otp': otp,
      'deviceInfo': {
        'consumptionDeviceName': 'unknown sdk_google_atv_x86',
        'info': {
          'type': 'android',
          'platform': {'name': 'generic_x86'},
          'androidId': _uuid.v4(),
        },
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData.containsKey('ssoToken')) {
        await _storeCredentials(responseData);
        return null;
      } else {
        return responseData['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _storeCredentials(Map<String, dynamic> data) async {
    await _storage.write(key: 'ssoToken', value: data['ssoToken']);
    await _storage.write(key: 'userId', value: data['sessionAttributes']['user']['uid']);
    await _storage.write(key: 'uniqueId', value: data['sessionAttributes']['user']['unique']);
    await _storage.write(key: 'crmId', value: data['sessionAttributes']['user']['subscriberId']);
    await _storage.write(key: 'authToken', value: data['authToken']);
    await _storage.write(key: 'jToken', value: data['jToken']);
    await _storage.write(key: 'deviceId', value: data['deviceId'].toString());
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'ssoToken');
    return token != null;
  }
}
