const degreesToRadians = (degree)=>
{
    return degree * Math.PI / 180;
}

const distanceBetweenLocation = (lat1,lon1,lat2,lon2) =>
{
    let earthRadius = 6371;

    let dLat = degreesToRadians(lat2-lat1);
    let dLon = degreesToRadians(lon2-lon1);
  
    lat1 = degreesToRadians(lat1);
    lat2 = degreesToRadians(lat2);
  
    let a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 

    return earthRadius * c;
}

const averageCoords = (coords) =>
{
    let lat = 0;
    let lon = 0;

    for(let k=0; k < coords.length ; k++)
    {
        lat+=coords[k].latitude; 
        lon+=coords[k].longitude;
    }

    lat = lat / coords.length;
    lon = lon / coords.length;

    return {"latitude": lat, "longitude": lon};
}

module.exports = {degreesToRadians,distanceBetweenLocation,averageCoords};
