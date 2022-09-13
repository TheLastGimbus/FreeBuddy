import 'package:logger/logger.dart';

final _prettyLogger = Logger(
  printer: PrettyPrinter(),
);

Logger get logg => _prettyLogger;
