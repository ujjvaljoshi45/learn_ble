import 'package:logger/logger.dart';

logEvent(String str) => Logger(printer: PrettyPrinter(colors: true,)).d(str);