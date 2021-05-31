import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_map/.env.dart';
import 'package:google_map/direction_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionRepository{
 static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';
 final Dio _dio;
 DirectionRepository({Dio dio}): _dio = dio ?? Dio();
 Future<Directions> getDirections({
 @required  LatLng origin,
 @required  LatLng destination,
 }) async{
  final response = await _dio.get(
  _baseUrl,
  queryParameters: {
    'origin': '${origin.latitude}, ${origin.longitude}',
   'destination': '${destination.latitude}, ${destination.longitude}',
   'key': googleAPIKey,
   }
  );
  if(response.statusCode == 200){
   return Directions.frommap(response.data);
  }
  return null;
 }
}