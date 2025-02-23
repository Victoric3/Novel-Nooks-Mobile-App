import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final cookieJarProvider = Provider<Future<CookieJar>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return PersistCookieJar(
    storage: FileStorage(
      "${dir.path}/.cookies/",
    ),
  );
});