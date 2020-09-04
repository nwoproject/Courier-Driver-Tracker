class Route
{
  String routeID;
  List<Location> locations = List<Location>();

  Route(this.routeID);
  Route.fromJson(Map<String,dynamic> json)
  {
    routeID = json['route_id'];
  }

  void addLocation(location)
  {
    locations.add(location);
  }
}

class Location
{
  String locationID;
  String latitude;
  String longitude;
  String address;
  String name;

  Location(this.locationID,this.latitude,this.longitude,this.address,this.name);

  Location.fromJson(Map<String,dynamic> json)
  {
    locationID = json['Location_'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    if(json['address']!=null)
    {
      address = json['address'];
    }
    else
    {
      address = 'N/A';
    }
    if(json['name']!=null)
    {
      name = json['name'];
    }
    else
    {
      name = 'N/A';
    }
  }
}
