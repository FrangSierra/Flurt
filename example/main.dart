import 'package:flurt/flurt.dart';

void main(List<String> arguments) {
  ActionA c = ActionC();
  print(c.tags());
}

class ActionA extends Action{

}

class ActionB extends ActionA{

}

class ActionC extends ActionB{

}