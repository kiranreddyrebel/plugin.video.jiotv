class Channel {
  final int channelId;
  final String channelName;
  final String logoUrl;
  final bool isCatchupAvailable;
  final int channelLanguageId;
  final int channelCategoryId;
  final int channelOrder;

  Channel({
    required this.channelId,
    required this.channelName,
    required this.logoUrl,
    required this.isCatchupAvailable,
    required this.channelLanguageId,
    required this.channelCategoryId,
    required this.channelOrder,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channelId: json['channel_id'],
      channelName: json['channel_name'],
      logoUrl: json['logoUrl'],
      isCatchupAvailable: json['isCatchupAvailable'],
      channelLanguageId: json['channelLanguageId'],
      channelCategoryId: json['channelCategoryId'],
      channelOrder: json['channel_order'],
    );
  }
}
