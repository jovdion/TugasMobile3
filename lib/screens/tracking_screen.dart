import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingLBSPage extends StatefulWidget {
  const TrackingLBSPage({super.key});

  @override
  State<TrackingLBSPage> createState() => _TrackingLBSPageState();
}

class _TrackingLBSPageState extends State<TrackingLBSPage> {
  String _infoLokasi = "Lokasi belum diperoleh";
  double? _lat;
  double? _lng;
  bool _sedangMemuat = false;

  final String _tomtomKey = 'tFrmWF0If1lscn3lGvAAoGAVUrIB2450'; // Ganti sesuai API key kamu

  Future<void> _ambilLokasiTerkini() async {
    setState(() => _sedangMemuat = true);

    bool layananAktif = await Geolocator.isLocationServiceEnabled();
    if (!layananAktif) {
      setState(() {
        _infoLokasi = "Layanan lokasi sedang tidak aktif.";
        _sedangMemuat = false;
      });
      return;
    }

    LocationPermission izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
      if (izin == LocationPermission.denied) {
        setState(() {
          _infoLokasi = "Akses lokasi ditolak.";
          _sedangMemuat = false;
        });
        return;
      }
    }

    if (izin == LocationPermission.deniedForever) {
      setState(() {
        _infoLokasi = "Akses lokasi ditolak permanen.";
        _sedangMemuat = false;
      });
      return;
    }

    try {
      Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lat = posisi.latitude;
        _lng = posisi.longitude;
        _infoLokasi =
            'Latitude: ${posisi.latitude.toStringAsFixed(8)}\nLongitude: ${posisi.longitude.toStringAsFixed(8)}';
        _sedangMemuat = false;
      });
    } catch (e) {
      setState(() {
        _infoLokasi = "Gagal memuat lokasi: $e";
        _sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Lacak Lokasi',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Temukan posisimu secara akurat',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Informasi lokasi
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.location_on,
                                size: 60, color: Colors.blue[700]),
                            const SizedBox(height: 16),
                            _sedangMemuat
                                ? CircularProgressIndicator(
                                    color: Colors.blue[700])
                                : Text(
                                    _infoLokasi,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      height: 1.5,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTombolAksi(
                            icon: Icons.my_location,
                            label: "Ambil Lokasi",
                            color: Colors.blue[700]!,
                            onPressed:
                                _sedangMemuat ? null : _ambilLokasiTerkini,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Peta jika lokasi tersedia
              if (_lat != null && _lng != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_lat!, _lng!),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$_tomtomKey",
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 60.0,
                                height: 60.0,
                                point: LatLng(_lat!, _lng!),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Jika belum ada lokasi
              if (_lat == null || _lng == null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "Ambil lokasi terlebih dahulu untuk melihat peta",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTombolAksi({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: onPressed == null ? Colors.grey[400] : color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.grey[400] : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
