library test.flurt;

import 'flux/action_test.dart' as action_test;
import 'flux/dispatcher_test.dart' as dispatcher_test;
import 'flux/interceptor_test.dart' as interceptor_test;

void main() {
  action_test.main();
  dispatcher_test.main();
  interceptor_test.main();
}