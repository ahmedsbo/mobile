import 'dart:io';

import 'package:http/http.dart' as http; // Alias http to avoid conflicts
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  // Removed: ..get('/restcountries', _restCountriesHandler)
  ..get('/weather', _weatherHandler);

Future<Response> _weatherHandler(Request request) async {
  final client = http.Client(); // Use aliased http client
  final latitude = request.url.queryParameters['latitude'];
  final longitude = request.url.queryParameters['longitude'];
  if (latitude == null || longitude == null) {
    return Response.badRequest(body: 'Latitude and longitude are required');
  }
  final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
  final response = await client.get(Uri.parse(url));
  client.close();
  return Response.ok(response.body, headers: _corsHeaders);
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*'
};

void main() async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await serve(handler, ip, port);
  print('Proxy server listening on http://${ip.host}:$port');
}
