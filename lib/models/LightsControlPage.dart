import 'package:flutter/material.dart';

class LightsControlPage extends StatefulWidget {
  const LightsControlPage({super.key});

  @override
  _LightsControlPageState createState() => _LightsControlPageState();
}

class _LightsControlPageState extends State<LightsControlPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentRoomIndex = 0;

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

  Map<String, Map<String, dynamic>> roomSettings = {};

  @override
  void initState() {
    super.initState();
    for (var room in rooms) {
      roomSettings[room] = {
        'selectedLight': 1,
        'brightness': 50.0,
        'color': Colors.white,
      };
    }
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _updateLight(int lightNumber) {
    setState(() {
      roomSettings[rooms[_currentRoomIndex]]!['selectedLight'] = lightNumber;
    });
  }

  void _updateBrightness(double value) {
    setState(() {
      roomSettings[rooms[_currentRoomIndex]]!['brightness'] = value;
    });
  }

  void _updateColor(Color color) {
    setState(() {
      roomSettings[rooms[_currentRoomIndex]]!['color'] = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Colors.grey),
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
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Colors.grey),
                    onPressed: () => _moveRooms('right'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Light list', style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLightButton(1, 'Light 1'),
                  _buildLightButton(2, 'Light 2'),
                  _buildLightButton(3, 'Light 3'),
                ],
              ),
              SizedBox(height: 20),
              Text('Brightness', style: TextStyle(fontSize: 14)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove, size: 20),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value:
                          roomSettings[rooms[_currentRoomIndex]]!['brightness'],
                      min: 0,
                      max: 100,
                      onChanged: _updateBrightness,
                      activeColor: Colors.grey,
                      inactiveColor: Colors.grey[300],
                    ),
                  ),
                  Icon(Icons.add, size: 20),
                ],
              ),
              SizedBox(height: 20),
              Text('Color', style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorButton(Colors.white),
                  _buildColorButton(Colors.blue),
                  _buildColorButton(Colors.red),
                  _buildColorButton(Colors.green),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print(
                    'Turn on lights with settings: ${roomSettings[rooms[_currentRoomIndex]]}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[400],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('TURN ON', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightButton(int lightNumber, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () => _updateLight(lightNumber),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor:
              roomSettings[rooms[_currentRoomIndex]]!['selectedLight'] ==
                  lightNumber
              ? Colors.blue
              : Colors.grey[300],
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => _updateColor(color),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: roomSettings[rooms[_currentRoomIndex]]!['color'] == color
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
