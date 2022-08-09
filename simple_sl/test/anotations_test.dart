import 'package:simple_sl/simple_sl_annotations.dart';
import 'package:test/test.dart';

abstract class Message {
  final String message;
  const Message(this.message);
}

EMail getEmail() => EMail('Mail this');
WhatsUP getWhatsUP() => WhatsUP('WhatsUP this');
Future<SharedChanel> getSharedChanel() async =>
    SharedChanel(chanelName: await getChanelA(), message: 'SharedMessage this');
Future<SharedChanelEager> getSharedChanelEager() async => SharedChanelEager(
      chanelName: await getChanelB(),
      message: 'SharedMessageEager this',
    );
Future<String> getChanelA() async => await Future<String>.delayed(
      Duration(milliseconds: 10),
      (() => 'Chanel A'),
    );
Future<String> getChanelB() async => await Future<String>.delayed(
      Duration(milliseconds: 10),
      (() => 'Chanel B'),
    );

@Injectable(as: Message, sync: getEmail)
class EMail extends Message {
  EMail(String message) : super('Emailing: $message');
}

@Injectable(as: Message, name: 'whatsUp', sync: getWhatsUP)
class WhatsUP extends Message {
  WhatsUP(String message) : super('WhatsUP message: $message');
}

@Injectable(as: Message, name: 'sharedChannel', async: getSharedChanel)
class SharedChanel extends Message {
  final String chanelName;
  SharedChanel({required this.chanelName, String? message})
      : super(
          'Message: ${message ?? 'no message'} sent on chanel $chanelName.',
        );
}

@Injectable(
  as: Message,
  name: 'sharedChannelEager',
  async: getSharedChanelEager,
  lazy: false,
)
class SharedChanelEager extends Message {
  final String chanelName;
  SharedChanelEager({required this.chanelName, String? message})
      : super(
          'Message: ${message ?? 'no message'} sent on chanel $chanelName.',
        );
}

void main() {
  group('Group tests to register anotated ', () {
    final serviceLocator = SimpleSL.instance;

/*     setUp(() {
      // Additional setup goes here.
    }); */

    test('Register sync and lazy creations', () {
      final stopwatch = Stopwatch()..start();

      serviceLocator.registerAnnotated(EMail);
      serviceLocator.registerAnnotated(WhatsUP);

      expect(stopwatch.elapsed.inMilliseconds, lessThan(10));

      var email = serviceLocator.get<Message>();
      var whatsUp = serviceLocator.get<Message>(name: 'whatsUp');
      expect(email.message, 'Emailing: Mail this');
      expect(whatsUp.message, 'WhatsUP message: WhatsUP this');
    });

    test('Register async and lazy creations', () async {
      final stopwatch = Stopwatch()..start();

      serviceLocator.registerAnnotated(SharedChanel);

      expect(stopwatch.elapsed.inMilliseconds, lessThan(10));

      var sharedMessage =
          await serviceLocator.getAsync<Message>(name: 'sharedChannel');
      expect(
        sharedMessage.message,
        'Message: SharedMessage this sent on chanel Chanel A.',
      );
    });

    test('Register async and lazy=false creations', () async {
      final stopwatch = Stopwatch()..start();

      await serviceLocator.registerAnnotated(SharedChanelEager);

      expect(stopwatch.elapsed.inMilliseconds, greaterThanOrEqualTo(10));

      var sharedMessage =
          await serviceLocator.getAsync<Message>(name: 'sharedChannelEager');
      expect(
        sharedMessage.message,
        'Message: SharedMessageEager this sent on chanel Chanel B.',
      );
    });
  });
}
