import 'package:flutter/material.dart';
import 'package:jiotv_flutter/providers/channel_provider.dart';
import 'package:jiotv_flutter/screens/video_player_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
      ),
      body: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          if (channelProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (channelProvider.error != null) {
            return Center(child: Text('Error: ${channelProvider.error}'));
          }

          if (channelProvider.channels.isEmpty) {
            return const Center(child: Text('No channels found.'));
          }

          return ListView.builder(
            itemCount: channelProvider.channels.length,
            itemBuilder: (context, index) {
              final channel = channelProvider.channels[index];
              return ListTile(
                leading: Image.network(channel.logoUrl),
                title: Text(channel.channelName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(channelId: channel.channelId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
