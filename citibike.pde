// Font for hovering
PFont myFont=createFont("Arial", 18);

// List of CitiBike stations
ArrayList<Station> stations;
ArrayList<LinearAnimation> animations;

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

// Image for Map Background
PImage mapBg;

void setup() {
  loadStopData();
  loadMapAndBounds();
  prepareAnimations();
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
  animations = new ArrayList<LinearAnimation>();
  JSONArray stationsArr = stationsJson.getJSONArray("stationBeanList");
  double stationMinLat = 360;
  double stationMaxLat = -360;
  double stationMinLon = 360;
  double stationMaxLon = -360;
  for (int i=0; i<stationsArr.size(); i++) {
    Station station = new Station(stationsArr.getJSONObject(i));
    stations.add(station);
    stationMinLat = (station.latitude < minLat) ? station.latitude : minLat;
    stationMaxLat = (station.latitude > maxLat) ? station.latitude : maxLat;
    stationMinLon = (station.longitude < minLon) ? station.longitude : minLon;
    stationMaxLon = (station.longitude > maxLon) ? station.longitude : maxLon;
  }
  
  // Calculate Center
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
  mapBg = loadImage(mapBgUrl, "png");
  background(mapBg);
}

void prepareAnimations() {
  // Create Animation Objects
  for (Station station : stations) {
    Coord initialPos = new Coord(0, sHeight);
    Coord finalPos = new Coord(lonToX(station.longitude), latToY(station.latitude));
    float percentageAvailable = (float)station.availableDocks / (float)station.totalDocks;
    color col;
    int numSteps = 20;
    if (percentageAvailable > 0.67) {
      col = color(0, 255, 0, 255);
      numSteps = int(3 * numSteps);
    } else if (percentageAvailable > 0.33) {
      col = color(255, 255, 0, 255);
      numSteps = int(2 * numSteps); // slight delay
    } else {
      col = color(255, 0, 0, 255);
      numSteps = int(1 * numSteps); // more delay
    }
    LinearAnimation anim = new LinearAnimation(initialPos, finalPos, numSteps, col);
    anim.associatedText = station.stationName + "\n" + station.availableDocks + "/" + station.totalDocks + " Available (" + int(percentageAvailable*100) + "%)";
    animations.add(anim);
  }
}

void drawStops() {
  // Redraw the bg to clear previous frames
  background(mapBg);
  
  // Initialize text to display
  String text = null;
  
  // Initialize some variables to reuse
  for (LinearAnimation anim : animations) {
    fill(anim.shapeColor);
    if (!anim.isComplete) {
      noStroke(); 
    } else {
      stroke(color(0, 0, 0, 80));
    }
    int finalRad = 4;
    float percentComplete = (float)anim.currentPos.x / (float)(anim.finalPos.x - anim.initialPos.x);
    int currentRad = (int)((percentComplete > 0) ? 4 / percentComplete : 0);
    ellipse(anim.currentPos.x, anim.currentPos.y, currentRad, currentRad);
    if(dist(mouseX,mouseY,anim.currentPos.x,anim.currentPos.y)<=4){
      text = anim.associatedText;
    }
    anim.step();
  }
  
  // if there is text, draw it over the top of everything
  if (text != null) {
    fill(0, 80, 100);
    //text(station.stationName,mouseX-20,mouseY-10);
    text(text, mouseX-20, mouseY-10);
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

