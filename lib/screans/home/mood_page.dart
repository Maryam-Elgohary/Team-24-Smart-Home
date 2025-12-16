import 'package:flutter/material.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class MoodPage extends StatefulWidget {
  final String switchEntityId;

  const MoodPage({super.key, required this.switchEntityId});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? mood;
  String? activity;
  String? timeOfDay;
  String? isHoliday;
  String? atHome;

  bool isSaving = false;

  final List<String> moods = [
    'peaceful',
    'focused',
    'tired',
    'stressed',
    'happy',
    'calm',
    'energetic',
  ];
  final List<String> activities = [
    'sleeping',
    'at work',

    'getting ready',
    'awake',
  ];
  final List<String> times = ['morning', 'afternoon', 'evening', 'night'];
  final List<String> yesNo = ['yes', 'no'];

  // mappings
  final Map<String, int> moodMapping = {
    'peaceful': 0,
    'focused': 1,
    'tired': 2,
    'stressed': 3,
    'happy': 4,
    'calm': 5,
    'energetic': 6,
  };

  final Map<String, int> conditionMapping = {
    'sleeping': 0,
    'at work': 1,
    'at home': 2,
    'out': 3,
    'getting ready': 4,
    'awake': 5,
  };

  final Map<String, int> timeMapping = {
    'morning': 0,
    'afternoon': 1,
    'evening': 2,
    'night': 3,
  };

  final Map<String, int> yesNoMapping = {'yes': 1, 'no': 0};

  Future<void> saveMood() async {
    if (mood == null ||
        activity == null ||
        timeOfDay == null ||
        isHoliday == null ||
        atHome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // استخدم المابات لتحويل النصوص لأرقام
      int moodValue = moodMapping[mood!]!;
      int activityValue = conditionMapping[activity!]!;
      int timeValue = timeMapping[timeOfDay!]!;
      int isHolidayValue = yesNoMapping[isHoliday!]!;
      int atHomeValue = yesNoMapping[atHome!]!;

      // مثال: لو mood stressed (3) أو activity at_work (1) → نعمل switch ON
      bool turnOnSwitch = moodValue == 3 || activityValue == 1;

      await HomeAssistantApi.callService(
        domain: 'input_boolean',
        service: turnOnSwitch ? 'turn_on' : 'turn_off',
        entityId: widget.switchEntityId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving settings: $e")));
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Widget buildRadioGroup(
    String title,
    List<String> options,
    String? groupValue,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ...options.map(
          (option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mood Switch Control",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff5857aa),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildRadioGroup("Set your current state", moods, mood, (val) {
              setState(() => mood = val);
            }),
            buildRadioGroup("What are you doing now?", activities, activity, (
              val,
            ) {
              setState(() => activity = val);
            }),
            buildRadioGroup("Time of Day", times, timeOfDay, (val) {
              setState(() => timeOfDay = val);
            }),
            buildRadioGroup("Is it a holiday?", yesNo, isHoliday, (val) {
              setState(() => isHoliday = val);
            }),
            buildRadioGroup("Are you at home?", yesNo, atHome, (val) {
              setState(() => atHome = val);
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : saveMood,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
