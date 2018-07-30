import 'dart:async';

abstract class SubscriptionTracker {
  final _subscriptions = <StreamSubscription>[];

  void cancelSubscription() {
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  void track(StreamSubscription stream) {
    _subscriptions.add(stream);
  }
}
