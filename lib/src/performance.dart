class Performance {
  int load = 0;
  int repeat = 1;
  int reps = 1;
  String unit = "";

  @override String toString() => "$load $unit for $repeat sets of $reps reps.";
}
