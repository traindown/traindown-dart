class Performance {
  int load = 0;
  int repeat = 1;
  int reps = 1;
  String unit = "";

  @override String toString() {
    if (unit.isNotEmpty) {
      return "$load $unit for $repeat sets of $reps reps.";
    } else {
      return "$load for $repeat sets of $reps reps.";
    }
  }
}
