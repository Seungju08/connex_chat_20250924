import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> saveImage(String url, String imageName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$imageName');

  if (await file.exists()) {
    return file;
  }

  final res = await http.get(Uri.parse(url));

  if (res.statusCode == 200) {
    file.writeAsBytes(res.bodyBytes);
    return file;
  } else {
    throw Exception();
  }
}