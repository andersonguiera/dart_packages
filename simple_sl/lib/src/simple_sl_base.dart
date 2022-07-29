import 'exceptions/bad_state_exception.dart';

/// This is a simple service locator
class SimpleSL {
  /// Services will lay here as
  /// ``` dart
  /// {
  ///   Type: {
  ///     name: Instance,
  ///     name_f: Type function(),
  ///     name_fa: Future<Type> function()
  ///   }
  /// }
  /// ```
  /// _f is a synchronous function whitch create the instancea.
  /// _fa is an asyncrhonous function with create the instance.
  /// Notice that _f and _fa are mutual exclusives, we dont have both at same time.
  // ignore: prefer_final_fields
  Map<Type, Map<String, dynamic>> _services = {};

  /// A global instance form [SimpleSL]
  static SimpleSL? _instance;

  SimpleSL._();

  /// Give an unique instace of SimpleSL
  static SimpleSL get instance {
    _instance ??= SimpleSL._();
    return _instance!;
  }

  /// Register and object of T type through function [f].
  ///
  /// By default [lazy] creation is used. Set it to false when instance must be
  /// created at the time of registration.
  /// [name] instances is a good way to have more objects of same type.
  ///
  ///Example of use:
  /// ``` dart
  /// //Register one string
  /// SimpleSL.instance.register<String>(() => 'Hello World!');
  ///
  /// //Register a named instance of String
  /// SimpleSL.instance.register<String>(
  ///   () => 'http://www.myawesomeurl.com',
  ///   name: 'address_prod');
  ///
  /// SimpleSL.instance.register<String>(
  ///   () => 'http://localhost:8080',
  ///   name: 'address_dev',
  ///   lazy: false);
  ///
  /// ```
  void register<T>(T Function() f,
      {bool lazy = true, String name = 'default'}) {
    _services[T] = {...?_services[T], name: lazy ? null : f(), '${name}_f': f};
  }

  /// Register objects whose creation depends of asyncronous execution code.
  ///
  /// By default [lazy] creation is used. Set it to false when instance must be
  /// created at the time of registration.
  /// [name] instances is a good way to have more objects of same type.
  ///
  ///Example of use:
  /// ``` dart
  /// //Register an asyncronous creation
  /// SimpleSL.instance.registerAsync<String>(
  ///   () async => await getAppDirectory(),
  ///   name: 'appDirectory');
  ///
  /// //Don't forget to await eager registrations
  /// await SimpleSL.instance.registerAsync<String>(
  ///   () async => await getDataDirectory(),
  ///   lazy = false,
  ///   name: 'dataDirectory');
  /// ```
  Future<void> registerAsync<T>(Future<T> Function() fa,
      {bool lazy = true, String name = 'default'}) async {
    _services[T] = {
      ...?_services[T],
      name: lazy ? null : await fa(),
      '${name}_fa': fa,
    };
  }

  /// Get instances whose creation is syncronous.
  ///
  /// Use [name] to retrieve a named instance.
  /// An exception is throwed if none instance was found.
  ///
  ///Example of use:
  /// ``` dart
  /// //Register a syncronous creation
  /// SimpleSL.instance.register<String>(
  ///   () => 'Hello World!');
  /// SimpleSL.instance.register<String>(
  ///   () => 'Olá Mundo!',
  /// name: 'pt-BR_greeting');
  ///
  /// //This will print 'Hello World!'
  /// print(SimpleSL.instance.get<String>());
  /// //This will print 'Olá Mundo!'
  /// print(SimpleSL.instance.get<String>(name: 'pr-BR_greeting'));
  /// ```
  T get<T>({String name = 'default'}) {
    if (_services[T] == null) {
      throw BadStateException('No instance register to ${T.toString()}');
    }
    if (!_services[T]!.keys.contains(name) ||
        !_services[T]!.keys.contains('${name}_f')) {
      throw BadStateException('$name instance does not exist');
    }

    _services[T]![name] = _services[T]![name] ?? _services[T]!['${name}_f']();
    return _services[T]![name];
  }

  /// Get instances whose creation is asyncronous.
  ///
  /// Use [name] to retrieve a named instance.
  /// An exception is throwed if none instance was found.
  ///
  ///Example of use:
  /// ``` dart
  /// //Register an asyncronous creation
  /// SimpleSL.instance.registerAsync<String>(
  ///   () async => await getAppDirectory(),
  ///   name: 'appDirectory');
  ///
  /// //This will print the app directory
  /// print(await SimpleSL.instance.getAsync<String>(name: 'appDirectory'));
  /// ```
  Future<T> getAsync<T>({String name = 'default'}) async {
    if (_services[T] == null) {
      throw BadStateException('No instance register to ${T.toString()}');
    }
    if (!_services[T]!.keys.contains(name) ||
        !_services[T]!.keys.contains('${name}_fa')) {
      throw BadStateException('$name instance does not exist');
    }

    _services[T]![name] =
        _services[T]![name] ?? await _services[T]!['${name}_fa']();
    return _services[T]![name];
  }

  /// Unregister instances of [T] type.
  ///
  /// Use [name] to unregister named instances.
  /// To remove all occurrences set [all] true.
  ///
  ///Example of use:
  /// ``` dart
  /// //Unregister default instance
  /// SimpleSL.instance.unregister<String>();
  ///
  /// //Unregister named instance
  /// SimpleSL.instance.unregister<String>(name: 'pt-BR_greeting');
  ///
  /// //Unregister all instances
  /// SimpleSL.instance.unregister<String>(all: true);
  /// ```
  void unregister<T>({String name = 'default', bool all = false}) {
    if (all) {
      _services.remove(T);
    } else if (_services.containsKey(T) && _services[T]!.containsKey(name)) {
      _services[T]!.remove(name);
      _services[T]!.remove('${name}_f');
      _services[T]!.remove('${name}_fa');
    }
  }
}
