import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const SatelliteApp());
}

class SatelliteApp extends StatelessWidget {
  const SatelliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SATELLITE IPTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05090F),
      ),
      home: const PlayerScreen(),
    );
  }
}

class Channel {
  final String number;
  final String name;

  const Channel(this.number, this.name);
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final Player player = Player();
  late final VideoController videoController =
      VideoController(player);

  int selected = 0;
  String playlistUrl = '';
  String search = '';
  bool sortAZ = false;
  final Set<int> favorites = {};

  final List<Channel> channels = const [
    Channel('001', 'Al Iraqiya'),
    Channel('002', 'Al Sharqiya'),
    Channel('003', 'MBC 1'),
    Channel('004', 'MBC 2'),
    Channel('005', 'MBC Action'),
    Channel('006', 'Al Arabiya'),
    Channel('007', 'Al Jazeera'),
    Channel('008', 'Rotana Cinema'),
    Channel('009', 'BBC News'),
    Channel('010', 'National Geographic'),
    Channel('011', 'Spacetoon'),
    Channel('012', 'Abu Dhabi TV'),
    Channel('013', 'Dubai TV'),
    Channel('014', 'OSN Movies'),
    Channel('015', 'Cartoon Network'),
  ];

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  List<int> get visibleChannels {
    List<int> result = List.generate(channels.length, (i) => i);

    result = result.where((i) =>
      channels[i].name.toLowerCase().contains(search.toLowerCase())
    ).toList();

    if (sortAZ) {
      result.sort((a, b) =>
        channels[a].name.compareTo(channels[b].name));
    }

    return result;
  }

  Future<void> openPlaylist() async {
    final input = TextEditingController(text: playlistUrl);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10243A),
        title: const Text('رابط قائمة القنوات'),
        content: TextField(
          controller: input,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/playlist.m3u',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = input.text.trim();
              Navigator.pop(context);
              if (value.isNotEmpty) {
                setState(() => playlistUrl = value);
                player.open(Media(value));
              }
            },
            child: const Text('تشغيل'),
          ),
        ],
      ),
    );

    input.dispose();
  }

  Future<void> playSelected(int index) async {
    setState(() => selected = index);

    if (playlistUrl.isNotEmpty) {
      await player.open(Media(playlistUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 600 ||
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _MoveIntent(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _MoveIntent(-1),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _SelectIntent(),
        const SingleActivator(LogicalKeyboardKey.select):
            const _SelectIntent(),
      },
      child: Actions(
        actions: {
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (intent) {
              setState(() {
                selected = (selected + intent.delta + channels.length)
                    % channels.length;
              });
              return null;
            },
          ),
          _SelectIntent: CallbackAction<_SelectIntent>(
            onInvoke: (_) {
              playSelected(selected);
              return null;
            },
          ),
        },
        child: Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: width * (wide ? 0.40 : 0.46),
                  child: channelPanel(),
                ),
                Expanded(child: videoPanel()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget channelPanel() {
    final items = visibleChannels;

    return Container(
      color: const Color(0xFF071D35),
      child: Column(
        children: [
          Container(
            height: 58,
            color: const Color(0xFF0B3156),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.keyboard_double_arrow_left,
                    color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'القنوات',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_double_arrow_right,
                    color: Colors.white70),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final id = items[index];
                final channel = channels[id];
                final active = selected == id;

                return InkWell(
                  onTap: () => playSelected(id),
                  child: Container(
                    height: 49,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF79D8F2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 39,
                          child: Text(
                            channel.number,
                            style: TextStyle(
                              color: active
                                  ? const Color(0xFF063B55)
                                  : const Color(0xFF51E68A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            channel.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: active
                                  ? const Color(0xFFD51E28)
                                  : const Color(0xFF55E58B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        roundTag('\$', const Color(0xFF198C56)),
                        const SizedBox(width: 4),
                        roundTag('HD', const Color(0xFF176EAD)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 57,
            padding: const EdgeInsets.all(5),
            color: const Color(0xFF06172A),
            child: Row(
              children: [
                actionButton('نوع', Colors.blue, () {}),
                actionButton('البحث', Colors.green, searchDialog),
                actionButton('A-Z', Colors.orange, () {
                  setState(() => sortAZ = !sortAZ);
                }),
                actionButton('المفضلات', Colors.red, () {
                  setState(() {
                    if (favorites.contains(selected)) {
                      favorites.remove(selected);
                    } else {
                      favorites.add(selected);
                    }
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget roundTag(String text, Color color) {
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget actionButton(
      String label, Color color, VoidCallback action) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 39,
          child: ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: FittedBox(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget videoPanel() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: Video(
              controller: videoController,
              controls: NoVideoControls,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: Text(
              'SATELLITE IPTV',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (playlistUrl.isEmpty)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv,
                      size: 58, color: Color(0xFF31516D)),
                  SizedBox(height: 12),
                  Text(
                    'SATELLITE IPTV',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'أضف رابط قائمة M3U للبدء',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: IconButton(
              onPressed: openPlaylist,
              icon: const Icon(
                Icons.playlist_add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> searchDialog() async {
    final input = TextEditingController(text: search);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF10243A),
        title: const Text('البحث عن قناة'),
        content: TextField(
          controller: input,
          decoration: const InputDecoration(
            hintText: 'اسم القناة',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => search = '');
              Navigator.pop(context);
            },
            child: const Text('مسح'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => search = input.text);
              Navigator.pop(context);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );

    input.dispose();
  }
}

class _MoveIntent extends Intent {
  final int delta;
  const _MoveIntent(this.delta);
}

class _SelectIntent extends Intent {
  const _SelectIntent();
}
