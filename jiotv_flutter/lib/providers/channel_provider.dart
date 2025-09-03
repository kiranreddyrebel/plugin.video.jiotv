import 'package:flutter/material.dart';
import 'package:jiotv_flutter/models/channel_model.dart';
import 'package:jiotv_flutter/services/channel_service.dart';

class ChannelProvider with ChangeNotifier {
  final ChannelService _channelService = ChannelService();
  List<Channel> _channels = [];
  bool _isLoading = false;
  String? _error;

  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChannelProvider() {
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _channelService.getChannels();
    if (result is List<Channel>) {
      _channels = result;
    } else {
      _error = result.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
