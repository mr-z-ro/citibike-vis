class LatLon {
  double lat;
  double lon;

  LatLon(double lat, double lon) {
    this.lat = lat;
    this.lon = lon;
  }
  
  String toString() {
    return "LatLon: " + lat + "," + lon;
  }
}
