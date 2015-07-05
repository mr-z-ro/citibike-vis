class Station {
  int id;
  String stationName;
  int availableDocks;
  int totalDocks;
  float latitude;
  float longitude;
  String statusValue;
  int statusKey;
  String stAddress1;
  String stAddress2;
  String city;
  String postalCode;
  String location;
  String altitude;
  boolean testStation;
  String lastCommunicationTime;
  String landMark;

  public Station(JSONObject stationObj) {
    this.id = stationObj.getInt("id");
    this.stationName = stationObj.getString("stationName");
    this.availableDocks = stationObj.getInt("availableDocks");
    this.totalDocks = stationObj.getInt("totalDocks");
    this.latitude = stationObj.getFloat("latitude");
    this.longitude = stationObj.getFloat("longitude");
    this.statusValue = stationObj.getString("statusValue");
    this.statusKey = stationObj.getInt("statusKey");
    this.stAddress1 = stationObj.getString("stAddress1");
    this.stAddress2 = stationObj.getString("stAddress2");
    this.city = stationObj.getString("city");
    this.postalCode = stationObj.getString("postalCode");
    this.location = stationObj.getString("location");
    this.altitude = stationObj.getString("altitude");
    this.testStation = stationObj.getBoolean("testStation");
    this.lastCommunicationTime = stationObj.getString("lastCommunicationTime");
    this.landMark = stationObj.getString("landMark");
  }
}
