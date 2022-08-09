import 'package:simple_sl/simple_sl.dart';

abstract class Output {
  void say(String message);
}

class Console implements Output {
  @override
  void say(String message) {
    print(message);
  }
}

class File implements Output {
  @override
  void say(String message) {
    print('Writing...: $message');
  }
}

abstract class Animal {
  final Output method;

  Animal(this.method);
  void talk();
}

class Person extends Animal {
  Person(super.method);

  @override
  void talk() {
    method.say('Hi there!');
  }
}

class Dog extends Animal {
  Dog(super.method);

  @override
  void talk() {
    method.say('Auf-Auf');
  }
}

void main() {
  // Geting the instance of SimpleSL
  var locator = SimpleSL.instance;

  //Register instances of output
  locator.register<Output>(() => Console());
  locator.register<Output>(() => File(), name: 'file');

  //Register some concrete instances of animal, and inject its dependencies.
  locator.register<Animal>(() => Person(locator.get<Output>(name: 'file')));
  locator.register<Animal>(() => Dog(locator.get<Output>()), name: 'Skip');

  var animal = locator.get<Animal>(name: 'Skip');
  //Skip is a dog so it barks
  animal.talk(); //print Auf-Auf

  animal = locator.get<Animal>();
  //Default animal is Person, so Person register talk in a file
  animal.talk(); //print Writing...: Hi there!
}
