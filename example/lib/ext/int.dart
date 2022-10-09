import 'package:sprintf/sprintf.dart';

extension IntExtension on int {

  String millisecondsToTimeString({bool ignoreHours = false}) {
    int totalSeconds = this ~/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = ((totalSeconds / 60) % 60).toInt();
    if (ignoreHours) {
      minutes = totalSeconds ~/ 60;
    }
    int hours = totalSeconds ~/ 3600;
    return (hours > 0 && !ignoreHours)
        ? sprintf.call("%02i:%02i:%02i", [hours, minutes, seconds])
        : sprintf.call("%02d:%02d", [minutes, seconds]);
  }

}
