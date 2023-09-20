import 'package:logger/logger.dart';

final _prettyLogger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(),
  level: Level.all,
);

Logger get logg => _prettyLogger;
