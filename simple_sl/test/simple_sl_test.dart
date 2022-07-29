import 'package:simple_sl/simple_sl.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final serviceLocator = SimpleSL.instance;

    setUp(() {
      // Additional setup goes here.
    });

    test('Register sync creations', () {
      final stopwatch = Stopwatch()..start();

      serviceLocator.register<String>(
        () => 'Hello World!',
      );
      serviceLocator.register<String>(() => 'Olá Mundo!',
          name: 'pt-BR_greenting');

      var enUSGreeting = serviceLocator.get<String>();
      var ptBRGreeting = serviceLocator.get<String>(name: 'pt-BR_greenting');

      expect(stopwatch.elapsed.inMilliseconds, lessThan(5));

      expect(enUSGreeting, 'Hello World!');
      expect(ptBRGreeting, 'Olá Mundo!');
    });

    test('Register async creations', () async {
      final stopwatch = Stopwatch()..start();
      final milliseconds = 100;

      //my way to simulate an async creation
      serviceLocator.registerAsync<String>(
        () async => Future<String>.delayed(
            Duration(milliseconds: milliseconds), () => 'Hello World!'),
      );
      // Assure that is lazy load
      expect(stopwatch.elapsed.inMilliseconds, lessThan(5));

      var enUSGreeting = await serviceLocator.getAsync<String>();

      //Assure that creation was triggered on getAsync call
      expect(stopwatch.elapsed.inMilliseconds, greaterThan(milliseconds));
      expect(enUSGreeting, 'Hello World!');
    });

    test('Register async creations with lazy=false', () async {
      final stopwatch = Stopwatch()..start();
      final milliseconds = 100;

      //my way to simulate an async creation
      await serviceLocator.registerAsync<String>(
        () async => Future<String>.delayed(
            Duration(milliseconds: milliseconds), () => 'Hello World!'),
        lazy: false,
      );
      // Assure that is eager load
      expect(
          stopwatch.elapsed.inMilliseconds, greaterThanOrEqualTo(milliseconds));

      stopwatch.reset();

      var enUSGreeting = await serviceLocator.getAsync<String>();

      //Assure that creation was triggered on getAsync call
      expect(stopwatch.elapsed.inMilliseconds, lessThan(5));
      expect(enUSGreeting, 'Hello World!');
    });

    test('Replace sync creations', () {
      serviceLocator.register<String>(
        () => 'Hello World!',
      );
      var greeting = serviceLocator.get<String>();
      expect(greeting, 'Hello World!');

      //overwrite 'default' string
      serviceLocator.register<String>(
        () => 'Olá Mundo!',
      );
      greeting = serviceLocator.get<String>();
      expect(greeting, 'Olá Mundo!');
    });

    test('Replace async creations', () async {
      final milliseconds = 10;

      //my way to simulate an async creation
      serviceLocator.registerAsync<String>(
        () async => Future<String>.delayed(
            Duration(milliseconds: milliseconds), () => 'Hello World!'),
      );
      var greeting = await serviceLocator.getAsync<String>();
      expect(greeting, 'Hello World!');

      //Replace default string
      serviceLocator.registerAsync<String>(
        () async => Future<String>.delayed(
            Duration(milliseconds: milliseconds), () => 'Olá Mundo!'),
      );
      greeting = await serviceLocator.getAsync<String>();
      expect(greeting, 'Olá Mundo!');
    });

    test('Unregister only default instance', () {
      serviceLocator.register<String>(
        () => 'Hello World!',
      );

      serviceLocator.register<String>(
        () => 'Olá Mundo!',
        name: 'pt-BR_greeting',
      );

      var greeting = serviceLocator.get<String>();
      expect(greeting, 'Hello World!');

      //remove only 'default' String
      serviceLocator.unregister<String>();
      expect(
          () => serviceLocator.get<String>(),
          throwsA(predicate(
            (p0) => p0 is BadStateException && p0.message.contains('default'),
          )));

      //named instance must remain
      greeting = serviceLocator.get<String>(name: 'pt-BR_greeting');
      expect(greeting, 'Olá Mundo!');
    });

    test('Unregister one by one instances', () {
      serviceLocator.register<String>(
        () => 'Hello World!',
      );

      serviceLocator.register<String>(
        () => 'Olá Mundo!',
        name: 'pt-BR_greeting',
      );

      var greeting = serviceLocator.get<String>();
      expect(greeting, 'Hello World!');

      //remove only 'default' String
      serviceLocator.unregister<String>();
      expect(
          () => serviceLocator.get<String>(),
          throwsA(predicate(
            (p0) => p0 is BadStateException && p0.message.contains('default'),
          )));

      //named instance must remain
      greeting = serviceLocator.get<String>(name: 'pt-BR_greeting');
      expect(greeting, 'Olá Mundo!');

      //remove only 'pt-BR_greeting' String
      serviceLocator.unregister<String>(name: 'pt-BR_greeting');
      expect(
          () => serviceLocator.get<String>(name: 'pt-BR_greeting'),
          throwsA(predicate(
            (p0) =>
                p0 is BadStateException &&
                p0.message.contains('pt-BR_greeting'),
          )));
    });

    test('Unregister all instances at once', () {
      serviceLocator.register<String>(
        () => 'Hello World!',
      );

      serviceLocator.register<String>(
        () => 'Olá Mundo!',
        name: 'pt-BR_greeting',
      );

      //remove only 'default' String
      serviceLocator.unregister<String>(all: true);

      expect(
          () => serviceLocator.get<String>(),
          throwsA(predicate(
            (p0) => p0 is BadStateException && p0.message.contains('String'),
          )));

      expect(
          () => serviceLocator.get<String>(name: 'pt-BR_greeting'),
          throwsA(predicate(
            (p0) => p0 is BadStateException && p0.message.contains('String'),
          )));
    });
  });
}
