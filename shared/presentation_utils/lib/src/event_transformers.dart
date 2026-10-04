import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// An [EventTransformer] that debounces events by [duration].
///
/// Any new event arriving within [duration] restarts the timer and cancels
/// any in-flight handler using `switchMap`.
EventTransformer<Event> debounce<Event>([
  Duration duration = const Duration(milliseconds: 300),
]) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// An [EventTransformer] that throttles events by [duration].
///
/// Ignores events that occur within [duration] of the first event,
/// forwarding only at most one event per duration interval.
EventTransformer<Event> throttle<Event>(Duration duration) {
  return (events, mapper) => events.throttle(duration).switchMap(mapper);
}
