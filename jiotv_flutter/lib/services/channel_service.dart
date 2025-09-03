import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jiotv_flutter/models/channel_model.dart';

class ChannelService {
  final String _channelsUrl =
      'https://jiotvapi.cdn.jio.com/apis/v3.0/getMobileChannelList/get/?langId=6&devicetype=phone&os=android&usertype=JIO&version=343';
  final String _getChannelUrl =
      'https://tv.media.jio.com/apis/v2.0/getchannelurl/getchannelurl?langId=6&userLanguages=All';
  final _storage = const FlutterSecureStorage();

  Future<dynamic> getChannels() async {
    try {
      final response = await http.get(Uri.parse(_channelsUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> channelList = responseData['result'];
        return channelList.map((json) => Channel.fromJson(json)).toList();
      } else {
        return 'Failed to fetch channels';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<dynamic> getChannelUrl(int channelId) async {
    try {
      final headers = {
        'ssotoken': await _storage.read(key: 'ssoToken'),
        'userId': await _storage.read(key: 'userId'),
        'uniqueId': await _storage.read(key: 'uniqueId'),
        'crmid': await _storage.read(key: 'crmId'),
        'user-agent': 'plaYtv/7.1.5 (Linux;Android 9) ExoPlayerLib/2.11.7',
        'deviceid': await _storage.read(key: 'deviceId'),
        'devicetype': 'phone',
        'os': 'B2G',
        'osversion': '2.5',
        'versioncode': '353',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'channel_id': channelId,
        'stream_type': 'Seek',
      });

      final response = await http.post(
        Uri.parse(_getChannelUrl),
        headers: headers.map((key, value) => MapEntry(key, value ?? '')),
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['result'];
      } else {
        return 'Failed to get channel URL';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
