// Font for hovering
PFont myFont=createFont("Arial", 12);

// List of CitiBike stations
ArrayList<Station> stations;

// Initialized list of citibike geo-extrema
// Note that these are initialized to intentionally ridiculous values 
// to guarantee they'll be overridden or fail [visually] loudly
double minLat = 360;
double maxLat = -360;
double minLon = 360;
double maxLon = -360;
double centerLat = 0;
double centerLon = 0;

// Initialized sketch bounds
int sWidth = 600;
int sHeight = 600;

// URL for Map Background
String mapBgUrl;

void setup() {
  loadStopData();
  loadMapAndBounds();
  textFont(myFont);
}

void draw() {
  drawStops();
}

void loadStopData() {
  // Load CitiBike Station Data
  JSONObject stationsJson = loadJSONObject("http://www.citibikenyc.com/stations/json");

  // Parse into native objects
  stations = new ArrayList<Station>();
  JSONArray stationsArr = stationsJson.getJSONArray("stationBeanList");
  double stationMinLat = 360;
  double stationMaxLat = -360;
  double stationMinLon = 360;
  double stationMaxLon = -360;
  for (int i=0; i<stationsArr.size (); i++) {
    Station station = new Station(stationsArr.getJSONObject(i));
    stations.add(station);
    stationMinLat = (station.latitude < minLat) ? station.latitude : minLat;
    stationMaxLat = (station.latitude > maxLat) ? station.latitude : maxLat;
    stationMinLon = (station.longitude < minLon) ? station.longitude : minLon;
    stationMaxLon = (station.longitude > maxLon) ? station.longitude : maxLon;
  }

  println("Station Lat Range: " + stationMinLat + " to " + stationMaxLat);
  centerLat = (stationMinLat + stationMaxLat) / 2;
  println("Station Lon Range: " + stationMinLon + " to " + stationMaxLon);
  centerLon = (stationMinLon + stationMaxLon) / 2;
}

void loadMapAndBounds() {
  // Set the size of the sketch
  size(sWidth, sHeight, JAVA2D);
  
  // Create the url to load the map from
  mapBgUrl = "https://maps.googleapis.com/maps/api/staticmap?";
  mapBgUrl += "center=" + centerLat + "," + centerLon; 
  mapBgUrl += "&zoom=12&size=" + (sWidth) + "x" + (sHeight);
  println("Map URL: " + mapBgUrl);

  // It's a pain in the butt to find bounds on static maps from google. For now, we'll get them
  // manually from http://www.w3schools.com/googleAPI/tryit.asp?filename=tryhtml_ref_getbounds
  // using zoom = 12 @ 40.71151351928711,-74.01575469970703 center and 600px x 600px map
  LatLon southWestLatLon = new LatLon(40.633395823284424, -74.1187515258789);
  LatLon northEastLatLon = new LatLon(40.78953967539047, -73.91275787353516);
  minLat = southWestLatLon.lat;
  maxLat = northEastLatLon.lat;
  minLon = southWestLatLon.lon;
  maxLon = northEastLatLon.lon;
  
  // TODO: Complete more complex method using Mercator - not currently functional
  // See http://stackoverflow.com/questions/12507274/how-to-get-bounds-of-a-google-static-map/12511820#12511820
  //LatLon latLon = new LatLon(centerLat, centerLon);
  //setCorners(latLon, 12, sWidth, sHeight);
  
  // Draw the static Google map
  background(loadImage(mapBgUrl, "png"));
}

void drawStops() {
  // Initialize some variables to reuse
  int x; // horizontal pixel location on sketch
  int y; // vertical pixel location on sketch
  float percentageAvailable; // percentage of bikes available at the location
  for (Station station : stations) {
    x = lonToX(station.longitude);
    y = latToY(station.latitude);
    percentageAvailable = (float)station.availableDocks / (float)station.totalDocks;
    if (percentageAvailable > 0.67) {
      fill(color(0, 255, 0, 255)); 
    } else if (percentageAvailable > 0.33) {
      fill(color(255, 255, 0, 255));
    } else {
      fill(color(255, 0, 0, 255));
    }
    noStroke();
    ellipse(x, y, 4, 4);
    if(dist(mouseX,mouseY,x,y)<=2){
      fill(0);
      text(station.stationName,mouseX-20,mouseY-10);
    }
  }
}

void setCorners(LatLon center, int zoom, int mapWidth, int mapHeight) {
  println(center);
  int scale = (int)Math.pow(2, zoom);
  MercatorProjection proj = new MercatorProjection(scale);
  Coord centerCoord = proj.fromLatLonToPoint(center);
  println("Center: " + centerCoord);
  Coord southWestCoord = new Coord(centerCoord.x - mapWidth/2/scale, centerCoord.y + mapHeight/2/scale);
  LatLon southWestLatLon = proj.fromPointToLatLon(southWestCoord);
  println("SW: " + southWestLatLon);
  Coord northEastCoord = new Coord(centerCoord.x + mapWidth/2/scale, centerCoord.y - mapHeight/2/scale);
  LatLon northEastLatLon = proj.fromPointToLatLon(northEastCoord);
  println("NE: "+ northEastLatLon);
}

int lonToX(double lon) {
  double percentageFromLeft = (lon-minLon)/(maxLon-minLon);
  return (int)Math.floor(Double.valueOf(sWidth) * percentageFromLeft);
}

int latToY(double lat) {
  double percentageFromTop = 1-(lat-minLat)/(maxLat-minLat);
  return (int)Math.floor(Double.valueOf(sHeight) * percentageFromTop);
}

