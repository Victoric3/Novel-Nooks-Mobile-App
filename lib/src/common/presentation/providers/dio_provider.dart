import 'package:dio/dio.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) => AppDio.getInstance());
