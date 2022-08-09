import 'exceptions/bad_state_exception.dart';
import 'dart:mirrors';

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
  void register<T>(
    T Function() f, {
    bool lazy = true,
    String name = 'default',
  }) {
//    _services[T] = {...?_services[T], name: lazy ? null : f(), '${name}_f': f};
    _registerItern(T, name, f, lazy);
  }

  void _registerItern(Type type, String name, dynamic Function() f, bool lazy) {
    _services[type] = {
      ...?_services[type],
      name: lazy ? null : f(),
      '${name}_f': f,
    };
  }

  void _registerInstance(Type type, String name, dynamic instance) {
    _services[type] = {...?_services[type], name: instance};
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
  Future<void> registerAsync<T>(
    Future<T> Function() fa, {
    bool lazy = true,
    String name = 'default',
  }) async {
    await _registerInterAsync(T, name, fa, lazy);
  }

  Future<void> _registerInterAsync(
    Type type,
    String name,
    dynamic Function() fa,
    bool lazy,
  ) async {
    _services[type] = {
      ...?_services[type],
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

    //if instance doesnt exist and i cant create it
    if (!_services[T]!.keys.contains(name) &&
        !_services[T]!.keys.contains('${name}_f')) {
      throw BadStateException('$name instance does not exist');
    }

    _services[T]![name] = _services[T]![name] ?? _services[T]!['${name}_f']();

    return _services[T]![name];
  }

  dynamic _getInternal(Type type, String name) {
    _services[type]![name] =
        _services[type]![name] ?? _services[type]!['${name}_f']();

    return _services[type]![name];
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

    //if instance doesnt exist and i cant create it
    if (!_services[T]!.keys.contains(name) &&
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

class Injectable<T> {
  final T? as;
  final String? name;
  final T Function()? sync;
  final Future<T> Function()? async;
  final bool lazy;

  const Injectable({
    this.as,
    this.name = 'default',
    this.sync,
    this.async,
    this.lazy = true,
  });
}

class Inject {
  final String? instanceName;

  const Inject({this.instanceName = 'default'});
}

extension AnnotationProcessor on SimpleSL {
  Future<void> registerAnnotated(Type type) async {
    ClassMirror classMirror = reflectClass(type);

    if (classMirror.metadata.isNotEmpty) {
      // Select all occurrences of Injectable annotation
      var injectables = classMirror.metadata
          .where((metadata) => metadata.reflectee is Injectable)
          .map((metadata) => metadata.reflectee as Injectable)
          .toList();

      for (var injectable in injectables) {
        // If Injectable doesnt have creation functions annoted, then it will be
        // created at this time by reflection using default contructor.
        if (injectable.sync == null && injectable.async == null) {
          //Get the default constructor mirror
          var constructorMirror = (classMirror
              .declarations[Symbol(type.toString())]! as MethodMirror);

          //Auxiliary variables to store constructor parameters [ordered and named]
          var orderedParameters = <dynamic>[];
          var namedParameters = <Symbol, dynamic>{};

          //Get all parameters
          List<Map<String, dynamic>> parameters =
              _getAllParameters(constructorMirror);

          for (var parameter in parameters) {
            Inject? inject = parameter['inject'];
            var value = inject != null
                ? _getInternal(
                    parameter['type'].reflectedType,
                    inject.instanceName!,
                  )
                : parameter['defaultValue']?.reflectee;
            if (parameter['isNamed']) {
              namedParameters[parameter['simpleName']] = value;
            } else {
              orderedParameters.add(value);
            }
          }

          var instanceMirror = classMirror.newInstance(
            Symbol(''),
            orderedParameters,
            namedParameters,
          );
          _registerInstance(
            injectable.as ?? type,
            injectable.name!,
            instanceMirror.reflectee,
          );
        } else {
          await _registerInjectable(type, injectable);
        }
      }
    } else {
      throw BadStateException('Class $type must be annotated as @Injectable');
    }
  }

  //Rgister an injectable anotated class. if injectable.as is null, type will be
  //usede to register.
  Future<void> _registerInjectable(Type type, Injectable injectable) async {
    if (injectable.async != null) {
      await _registerInterAsync(
        injectable.as ?? type,
        injectable.name!,
        injectable.async!,
        injectable.lazy,
      );
    } else if (injectable.sync != null) {
      _registerItern(
        injectable.as ?? type,
        injectable.name!,
        injectable.sync!,
        injectable.lazy,
      );
    } else {
      throw BadStateException(
        'Can cont register $type as @Injectable: Must have sync or async '
        'constructor functions',
      );
    }
  }

  List<Map<String, dynamic>> _getAllParameters(MethodMirror constructorMirror) {
    var parameters = constructorMirror.parameters.map((element) {
      var injects = element.metadata
          .where((element) => element.reflectee is Inject)
          .toList();
      var parameter = <String, dynamic>{
        'isNamed': element.isNamed,
        'defaultValue': element.hasDefaultValue ? element.defaultValue : null,
        'simpleName': element.simpleName,
        'type': element.type,
        'inject': injects.isNotEmpty ? injects.first.reflectee : null,
      };

      return parameter;
    }).toList();

    return parameters;
  }
}
