const routeFormatter = (locRes,routeRes,routeNum) =>
{
    let location = [];
    for(let k = 0; k < locRes.rowCount;k++)
    {
        location.push({
        "location_id":locRes.rows[k].location_id,
        "latitude":locRes.rows[k].latitude,
        "longitude":locRes.rows[k].longitude,
        "address":locRes.rows[k].address,
        "name":locRes.rows[k].name,
    });
    }
    let route = {
                "route_id": routeRes.rows[routeNum].route_id,
                "locations": location};
    return route;
}

const objectConverter = (results) =>
{
    let drivers = [];
    for(let k = 0; k < results.rowCount;k++)
    {
        drivers.push({"id":results.rows[k].id,
        "name":results.rows[k].name,
        "surname":results.rows[k].surname,
        "latitude":results.rows[k].latitude,
        "longitude":results.rows[k].longitude});
    }
    return drivers;
}

const driverCenterPointConverter= (results) =>
{
    let centerPoints = [];
    for(let k=0 ; k < results.rowCount ; k++)
    {
        centerPoints.push({
            "driver_id": results.rows[k].driver_id,
            "lat": results.rows[k].latitude,
            "lon": results.rows[k].longitude,
            "radius": results.rows[k].radius
        });
    }
    return centerPoints;
}

const sortObject = (prop) => 
{    
    return (a, b) => {    
        if(a[prop] > b[prop])
        {    
            return 1;    
        } 
        else if(a[prop] < b[prop]) 
        {    
            return -1;    
        }    
        return 0;    
    }    
}

const getDriverCentrePointResponse = (centerpoint,driver) =>
{
    return {
        "driver_id":centerpoint.rows[0].driver_id,
        "name":driver.rows[0].name,
        "surname":driver.rows[0].surname,
        "centerpoint": {
            "latitude":centerpoint.rows[0].latitude,
            "longitude":centerpoint.rows[0].longitude,
            "radius":centerpoint.rows[0].radius + "km"
        }
    };
}

module.exports = {routeFormatter,objectConverter,driverCenterPointConverter,sortObject,getDriverCentrePointResponse};
