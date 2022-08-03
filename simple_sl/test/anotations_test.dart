import 'dart:mirrors';

import 'package:simple_sl/simple_sl_annotations.dart';
import 'package:test/test.dart';

abstract class Animal {
  void talk();
}

Animal getDog() => Dog(name: 'Rex');

@Injectable(as: Animal, sync: getDog)
class Dog implements Animal {
  final String name;
  const Dog({required this.name});
  @override
  void talk() {
    print('Auf-Auf, Im $name');
  }
}

@Injectable(as: Animal, name: 'person')
class Person implements Animal {
  @override
  void talk() {
    print('Hi there!');
  }
}

@Injectable()
class UseAnimal {
  final Animal animal;
  final String message;
  final String injectedMessage;

  const UseAnimal(@Inject(instanceName: 'person') this.animal,
      {this.message = 'message to you.',
      @Inject(instanceName: 'mensagem') this.injectedMessage =
          'fail to inject'});

  void show() {
    print(message);
    print(injectedMessage);
  }
}

void main() {
  group('A group of tests', () {
    final serviceLocator = SimpleSL.instance;

    setUp(() {
      // Additional setup goes here.
    });

    test('Register sync creations', () {
/*       ClassMirror classMirror = reflectClass(Dog);

      print(classMirror.declarations.entries.toString());
      var instanceMirror =
          classMirror.newInstance(Symbol(''), [], {Symbol('name'): 'To-to'});
      (instanceMirror.reflectee as Dog).talk(); */

/*       for (var metadata in classMirror.metadata) {
        if (metadata.reflectee is Injectable) {
          print('a');
          print(metadata.reflectee.name);
          print(metadata.reflectee.as.toString());
          print(classMirror.declarations.entries.toString());
        }
      }

      (classMirror as Dog).talk();
 */
      final stopwatch = Stopwatch()..start();

      //serviceLocator.registerAnnotated(Dog);
      serviceLocator.registerAnnotated(Person);

      //var animal = serviceLocator.get<Animal>();
      var animalPerson = serviceLocator.get<Animal>(name: 'person');

      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
      //animal.talk();
      animalPerson.talk();

/*       expect(enUSGreeting, 'Hello World!');
      expect(ptBRGreeting, 'Olá Mundo!'); */
    });

    test('Register inject', () {
/*       ClassMirror classMirror = reflectClass(UseAnimal);
      var methodMirror =
          (classMirror.declarations[Symbol('UseAnimal')]! as MethodMirror);

      for (var parameterMirror in methodMirror.parameters) {
        print(parameterMirror.metadata);
      }
      print(methodMirror.parameters); */

/*       for (var metadata in classMirror.metadata) {
        if (metadata.reflectee is Injectable) {
          print('a');
          print(metadata.reflectee.name);
          print(metadata.reflectee.as.toString());
          print(classMirror.declarations.entries.toString());
        }
      }

      (classMirror as Dog).talk();
 */

      final stopwatch = Stopwatch()..start();

      serviceLocator.register<String>(() => 'uma mensagem personalizada.',
          name: 'mensagem');
      serviceLocator.registerAnnotated(Dog);
      serviceLocator.registerAnnotated(Person);
      serviceLocator.registerAnnotated(UseAnimal);

      //var animal = serviceLocator.get<Animal>();
      var useAnimal = serviceLocator.get<UseAnimal>();

      expect(stopwatch.elapsed.inMilliseconds, lessThan(50));
      //animal.talk();
      useAnimal.animal.talk();
      useAnimal.show();

/*       expect(enUSGreeting, 'Hello World!');
      expect(ptBRGreeting, 'Olá Mundo!'); */
    });
  });
}
