import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

  const String baseURL = 'http://172.20.10.2:8000';
  const String publicDomainURL = '/story';
  const String recent = '$baseURL$publicDomainURL/recent';
  const String shortStory = '$baseURL$publicDomainURL/shortStory';
  const String sciFi = '$baseURL$publicDomainURL/sci-Fi';
  const String fantasy = '$baseURL$publicDomainURL/Fantasy';
  const String horror = '$baseURL$publicDomainURL/Horror';
  const String mystery = '$baseURL$publicDomainURL/Mystery';
  const String nonFiction = '$baseURL$publicDomainURL/Non-Fiction';
  const String historicalFiction = '$baseURL$publicDomainURL/Historical Fiction';
  const String multiGenre = '$baseURL$publicDomainURL/Multi-genre';
  const String adventure = '$baseURL$publicDomainURL/Adventure';
  const String biography = '$baseURL$publicDomainURL/Biography';
  const String science = '$baseURL$publicDomainURL/Science';
  const String selfHelp = '$baseURL$publicDomainURL/Self-Help';
  const String personalDevelopment = '$baseURL$publicDomainURL/Personal-development';


String getpopularUrl(WidgetRef ref) {
  final userData = ref.watch(userProvider);

  return '$baseURL$publicDomainURL/getAllStories/${userData!["interests"].join("+")}';
}
