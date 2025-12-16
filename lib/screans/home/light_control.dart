import 'package:flutter/material.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class LightsControlPage extends StatefulWidget {
  const LightsControlPage({super.key});

  @override
  _LightsControlPageState createState() => _LightsControlPageState();
}

class _LightsControlPageState extends State<LightsControlPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentRoomIndex = 0;
  bool _isPlusPressed = false;
  bool _isMinusPressed = false;

  final List<String> rooms = [
    'MASTER BEDROOM',
    'CHILD BEDROOM',
    'LIVING ROOM',
    'GUEST ROOM',
    'KITCHEN',
    'OFFICE',
    'BATHROOM',
    'WASHING ROOM',
  ];


  Map<String, Map<int, Map<String, dynamic>>> roomSettings = {};

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    for (var room in rooms) {
      int lightCount = await HomeAssistantApi.getLightCountForRoom(room) ?? 0; // الديفولت 0 لو مفيش أضواء
      roomSettings[room] = {};
      for (int i = 1; i <= lightCount; i++) {
        // جلب الإعدادات الحالية من الـ API
        Map<String, dynamic> settings = await HomeAssistantApi.getLightSettings(room, i) ?? {
          'brightness': 50.0,
          'color': Colors.white,
          'isSelected': i == 1,
          'state': false,
        };
        roomSettings[room]![i] = settings;
      }
    }
    setState(() {});
  }

  Future<void> _updateLightState(String room, int lightNumber, bool state) async {
    try {
      await HomeAssistantApi.updateLightState(room, lightNumber, state);
      setState(() {
        roomSettings[room]![lightNumber]!['state'] = state;
      });
    } catch (e) {
      print("Error updating light state: $e");
    }
  }

  Future<void> _updateBrightness(String room, int lightNumber, double value) async {
    try {
      await HomeAssistantApi.updateLightSettings(room, lightNumber, {'brightness': value});
      setState(() {
        roomSettings[room]![lightNumber]!['brightness'] = value;
      });
    } catch (e) {
      print("Error updating brightness: $e");
    }
  }

  Future<void> _updateColor(String room, int lightNumber, Color color) async {
    try {
      await HomeAssistantApi.updateLightSettings(room, lightNumber, {'color': color.value});
      setState(() {
        roomSettings[room]![lightNumber]!['color'] = color;
      });
    } catch (e) {
      print("Error updating color: $e");
    }
  }

  Future<void> _saveLightSettings(String room, int lightNumber) async {
    Map<String, dynamic> settings = roomSettings[room]![lightNumber]!;
    await HomeAssistantApi.saveLightSettings(room, lightNumber, settings);
  }

  int _getSelectedLight() {
    return roomSettings[rooms[_currentRoomIndex]]!.keys.firstWhere(
      (light) => roomSettings[rooms[_currentRoomIndex]]![light]!['isSelected'] == true,
      orElse: () => 1,
    );
  }

  void _selectLight(int lightNumber) {
    setState(() {
      roomSettings[rooms[_currentRoomIndex]]!.forEach((key, value) {
        value['isSelected'] = false;
      });
      roomSettings[rooms[_currentRoomIndex]]![lightNumber]!['isSelected'] = true;
    });
  }

  void _moveRooms(String direction) {
    setState(() {
      if (direction == 'left' && _currentRoomIndex < rooms.length - 1) {
        _currentRoomIndex++;
      } else if (direction == 'right' && _currentRoomIndex > 0) {
        _currentRoomIndex--;
      }
      _scrollController.animateTo(
        _currentRoomIndex * 200.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int lightCount = roomSettings[rooms[_currentRoomIndex]]?.length ?? 0;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 0),
                child: Container(
                  width: 160,
                  height: 185,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color.fromARGB(255, 247, 255, 255),
                  ),
                  child: const Icon(
                    Icons.light,
                    size: 140,
                    color: Color.fromARGB(255, 126, 134, 155),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, color: Colors.grey),
                      onPressed: () => _moveRooms('left'),
                    ),
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200,
                            alignment: Alignment.center,
                            child: Text(
                              rooms[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _currentRoomIndex == index
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF333333),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, color: Colors.grey),
                      onPressed: () => _moveRooms('right'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Light list',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    lightCount == 0
                        ? const Text(
                            'No lights added. Add devices from the Devices page.',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          )
                        : Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            children: List.generate(
                              lightCount,
                              (index) => _buildLightButton(index + 1, 'Light ${index + 1}'),
                            ),
                          ),
                    const SizedBox(height: 20),
                    if (lightCount > 0) ...[
                      const Row(
                        children: [
                          Text(
                            'Brightness',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 20,
                              color: _isMinusPressed ? const Color.fromARGB(255, 126, 134, 155) : Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isMinusPressed = true;
                                _isPlusPressed = false;
                                double currentBrightness = roomSettings[rooms[_currentRoomIndex]]![_getSelectedLight()]!['brightness'];
                                if (currentBrightness > 0) {
                                  _updateBrightness(rooms[_currentRoomIndex], _getSelectedLight(), currentBrightness - 10);
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                _isMinusPressed = false;
                              });
                            },
                          ),
                          Container(
                            width: 230,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Slider(
                              value: roomSettings[rooms[_currentRoomIndex]]![_getSelectedLight()]!['brightness'],
                              min: 0,
                              max: 100,
                              onChanged: (value) {
                                _updateBrightness(rooms[_currentRoomIndex], _getSelectedLight(), value);
                              },
                              activeColor: Colors.grey,
                              inactiveColor: Colors.grey[300],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 20,
                              color: _isPlusPressed ? const Color.fromARGB(255, 126, 134, 155) : Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPlusPressed = true;
                                _isMinusPressed = false;
                                double currentBrightness = roomSettings[rooms[_currentRoomIndex]]![_getSelectedLight()]!['brightness'];
                                if (currentBrightness < 100) {
                                  _updateBrightness(rooms[_currentRoomIndex], _getSelectedLight(), currentBrightness + 10);
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                _isPlusPressed = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildColorButton(Colors.white, 'White', Colors.grey),
                                const SizedBox(width: 20),
                                _buildColorButton(const Color.fromARGB(255, 0, 119, 255), 'Blue', const Color.fromARGB(255, 0, 119, 255)),
                                const SizedBox(width: 20),
                                _buildColorButton(const Color.fromARGB(255, 255, 17, 0), 'Red', const Color.fromARGB(255, 255, 17, 0)),
                                const SizedBox(width: 20),
                                _buildColorButton(const Color.fromARGB(255, 0, 255, 8), 'Green', const Color.fromARGB(255, 0, 255, 8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            int selectedLight = _getSelectedLight();
                            await _updateLightState(rooms[_currentRoomIndex], selectedLight, true);
                            await _saveLightSettings(rooms[_currentRoomIndex], selectedLight);
                            print('Turn on light $selectedLight with settings: ${roomSettings[rooms[_currentRoomIndex]]![selectedLight]}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Turn on',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightButton(int lightNumber, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ElevatedButton(
        onPressed: () => _selectLight(lightNumber),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: roomSettings[rooms[_currentRoomIndex]]![lightNumber]!['isSelected'] == true
              ? Colors.blue
              : Colors.grey[300],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildColorButton(Color color, String colorName, Color borderColor) {
    bool isSelected = roomSettings[rooms[_currentRoomIndex]]![_getSelectedLight()]!['color'] == color;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _updateColor(rooms[_currentRoomIndex], _getSelectedLight(), color);
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[400] : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          colorName,
          style: TextStyle(
            fontSize: 12,
            color: borderColor == Colors.grey ? Colors.black : borderColor,
          ),
        ),
      ],
    );
  }
}