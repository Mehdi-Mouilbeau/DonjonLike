/// Injectable time service for testability.
/// Override [now] in tests to control the clock.
class TimeService {
  DateTime Function() _clock;

  TimeService({DateTime Function()? clock})
      : _clock = clock ?? (() => DateTime.now());

  DateTime get now => _clock();

  /// Replace the clock (useful for tests).
  void setClock(DateTime Function() clock) {
    _clock = clock;
  }

  /// Check if at least [days] have passed since [date].
  bool hasCooldownExpired(DateTime? date, {int days = 5}) {
    if (date == null) return true;
    return now.difference(date).inDays >= days;
  }
}
