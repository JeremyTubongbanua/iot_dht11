import 'dart:io';

import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_utils/at_utils.dart';
import 'package:version/version.dart';

String? getHomeDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'];
    case 'windows':
      return Platform.environment['USERPROFILE'];
    case 'android':
      // Probably want internal storage.
      return '/storage/sdcard0';
    case 'ios':
      // iOS doesn't really have a home directory.
      return null;
    case 'fuchsia':
      // I have no idea.
      return null;
    default:
      return null;
  }
}

String? getAtKeysFilePath(final String atSign) {
  final String formattedAtSign = AtUtils.fixAtSign(atSign);
  return '${getHomeDirectory()}/.atsign/keys/${formattedAtSign}_key.atKeys';
}

AtOnboardingPreference loadPreferences(String authenticator) {
  final String? homeDirectory = getHomeDirectory();

  final AtOnboardingPreference preference = AtOnboardingPreference()
    ..isLocalStoreRequired = true
    ..atProtocolEmitted = Version(2, 0, 0)
    ..namespace = 'dht11'
    ..hiveStoragePath =
        homeDirectory != null ? '$homeDirectory/temp/hive' : './temp/hive'
    ..commitLogPath =
        homeDirectory != null ? '$homeDirectory/temp/commit' : './temp/commit'
    ..downloadPath = homeDirectory != null
        ? '$homeDirectory/temp/download'
        : './temp/download'
    ..useAtChops = true
    ..rootDomain = 'root.atsign.org'
    ..rootPort = 64
    ..atKeysFilePath = getAtKeysFilePath(authenticator);

  return preference;
}

Future<void> main(List<String> arguments) async {
  const String atSign = '@jeremy_0';
  final AtOnboardingPreference preference = loadPreferences(atSign);
  final AtOnboardingService atOnboardingService =
      AtOnboardingServiceImpl(atSign, preference);
  final bool authSuccess = await atOnboardingService.authenticate();
  if (!authSuccess) {
    stdout.writeln('Authentication failed');
  }

  final AtClient atClient = atOnboardingService.atClient!;

  final NotificationService notificationService = atClient.notificationService;

  final Stream<AtNotification> stream = notificationService.subscribe(
	regex: 'dht11',
	shouldDecrypt: true
  );

  stream.listen((AtNotification atNotification) {
	if(atNotification.id != -1) {
		_printAtNotification(atNotification);
	}
  });
}

void _printAtNotification(AtNotification atNotification) {
    final String id = atNotification.id;
    final String key = atNotification.key;
    final String from = atNotification.from;
    final String to = atNotification.to;
    final int epochMillis = atNotification.epochMillis;
    final String status = atNotification.status;
    final String? value = atNotification.value;
    final String? operation = atNotification.operation;
    final String? messageType = atNotification.messageType;
    final bool? isEncrypted = atNotification.isEncrypted;
    final int? expiresAtInEpochMillis = atNotification.expiresAtInEpochMillis;
    final Metadata? metadata = atNotification.metadata;

    stdout.writeln();
    stdout.writeln('[NOTIFICATION RECEIVED] =>');
    stdout.writeln('\tid: $id');
    stdout.writeln('\tkey: $key');
    stdout.writeln('\tfrom: $from');
    stdout.writeln('\tto: $to');
    stdout.writeln('\tepochMillis: $epochMillis');
    stdout.writeln('\tstatus: $status');
    stdout.writeln('\tvalue: $value');
    stdout.writeln('\toperation: $operation');
    stdout.writeln('\tmessageType: $messageType');
    stdout.writeln('\tisEncrypted: $isEncrypted');
    stdout.writeln('\texpiresAtInEpochMillis: $expiresAtInEpochMillis');
    stdout.writeln('\tmetadata: $metadata');
}
