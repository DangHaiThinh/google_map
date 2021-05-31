import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map/direction_models.dart';
import 'package:google_map/direction_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bruh Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MapScreen(),
    );
  }
}


class MapScreen extends StatefulWidget{
  @override
  _MapScreenState createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen>{
  static const _initialCameraPosition = CameraPosition(target: LatLng(10.870065900954058, 106.80381882600682),zoom: 11.5,);
  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Directions _info;

  @override
  void dispose(){
    _googleMapController.dispose();
    super.dispose();
  }
  //Variable

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Bruh Maps'),
        actions: [
          if(_origin != null)
          TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: _origin.position,
                      zoom: 14.5,
                      tilt: 50.0,
                  )
                )
              ),
              style: TextButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600)
              ),
              child: const Text('ORIGIN')),
          if(_destination != null)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _destination.position,
                          zoom: 14.5,
                          tilt: 50.0,
                        )
                    )
                ),
                style: TextButton.styleFrom(
                    primary: Colors.cyan,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600)
                ),
                child: const Text('DESTINATION')),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children:[
      GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        markers: {
          if (_origin != null) _origin,
          if (_destination != null) _destination
        },
        polylines: {
          if(_info != null)
            Polyline(
                polylineId: const PolylineId('overview_polyline'),
              color: Colors.indigo,
              width: 5,
              points: _info.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
            )
        },
        onLongPress: _addMarker,
      ),
          if(_info != null)
            Positioned(
              top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration:  BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const[
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ],
                  ),
                  child: Text(
                    '${_info.totalDistance}, ${_info.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ),
     ],
    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
            onPressed:() => _googleMapController.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_initialCameraPosition),
            ),
            child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
  void _addMarker(LatLng pos) async{
    if(_origin == null || (_origin != null && _destination != null)){
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        //reset
        _destination = null;
        _info = null;
      });
    }else{
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          position: pos,
        );
      });
      //get Directions
      final directions = await DirectionRepository().getDirections(origin: _origin.position, destination: pos);
      setState( () => _info = directions);
    }
  }
}