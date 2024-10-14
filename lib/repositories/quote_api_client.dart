import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class QuoteApiClient {
  final _baseUrl = 'https://quote-garden.herokuapp.com';
  final http.Client httpClient;
  QuoteApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);
}