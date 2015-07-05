class MercatorProjection {
  int MERCATOR_RANGE = 256;
  Coord pixelOrigin;
  double pixelsPerLonDegree;
  double pixelsPerLonRadian;

  MercatorProjection(int scale) {
    this.pixelOrigin = new Coord(MERCATOR_RANGE / 2, MERCATOR_RANGE / 2);
    this.pixelsPerLonDegree = MERCATOR_RANGE / 360;
    this.pixelsPerLonRadian = MERCATOR_RANGE / (2 * Math.PI);
  };

  double bound(double value, double min, double max) {
    value = Math.max(value, min);
    value = Math.min(value, max);
    return value;
  }

  Coord fromLatLonToPoint(LatLon latLon) {
    int x = this.pixelOrigin.x + (int)(latLon.lon * this.pixelsPerLonDegree);
    // NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
    // 89.189.  This is about a third of a tile past the edge of the world tile.
    double siny = bound(Math.sin(Math.toRadians(latLon.lat)), -0.9999, 0.9999);
    int y = this.pixelOrigin.y + (int)(0.5 * Math.log((1 + siny) / (1 - siny)) * -this.pixelsPerLonRadian);
    return new Coord(x, y);
  };

  LatLon fromPointToLatLon(Coord point) {
    Coord origin = this.pixelOrigin;
    double lon = (point.x - origin.x) / this.pixelsPerLonDegree;
    double latRadians = (point.y - origin.y) / -this.pixelsPerLonRadian;
    double lat = Math.toDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2);
    return new LatLon(lat, lon);
  };

  //pixelCoordinate = worldCoordinate * Math.pow(2,zoomLevel)
}
