import 'package:shared_preferences/shared_preferences.dart';

class DialogueService {
  Future<int> getCurrentLevel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentLevel') ?? 1; // Default to level 1
  }

  Future<void> incrementLevel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentLevel = prefs.getInt('currentLevel') ?? 1;
    await prefs.setInt('currentLevel', currentLevel + 1);
  }

  Future<int> getRewardPoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('rewardPoints') ?? 0; // Default to 0 points
  }

  Future<void> addRewardPoints(int points) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt('rewardPoints') ?? 0;
    await prefs.setInt('rewardPoints', currentPoints + points);
  }

  Future<void> minusRewardPoints(int points) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt('rewardPoints') ?? 0;
    await prefs.setInt('rewardPoints', currentPoints - points);
  }
}
