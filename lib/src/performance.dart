class Performance {
  int load;
  int repeat;
  int reps;
  String unit;

  Performance({this.load = 0, this.repeat = 1, this.reps = 1, this.unit = ""});

  @override String toString() {
    if (unit.isNotEmpty) {
      return "$load $unit for $repeat sets of $reps reps.";
    } else {
      return "$load for $repeat sets of $reps reps.";
    }
  }
}
