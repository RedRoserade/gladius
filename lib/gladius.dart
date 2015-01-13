
library gladius;

import 'dart:io';
import 'dart:async';
import 'dart:mirrors';
import 'dart:convert';
import 'package:logging/logging.dart';

part 'http_app.dart';
part 'http_router.dart';
part 'component.dart';
part 'context.dart';
part 'request.dart';
part 'response.dart';
part 'components/error_logger.dart';
part 'src/http_app_impl.dart';
part 'src/helpers.dart';

/// Defines a function that runs in an http application pipeline.
/// [next] can be called to run the next component in the pipeline.
typedef Future AppFunc(Context ctx, Future next());


