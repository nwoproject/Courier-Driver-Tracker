const routeFormatter = (locRes,routeRes,routeNum) =>
{
    let location = [];
    for(let k = 0; k < locRes.rowCount;k++)
    {
        location.push({
        "location_id":locRes.rows[k].location_id,
        "latitude":locRes.rows[k].latitude,
        "longitude":locRes.rows[k].longitude});
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
    for(let k ; k < results.rowCount ; k++)
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

//Integer sort only. Sorts from low to high. Strings will be sorted from high to low
const sortObject = (prop) => 
{    
    return (a, b) => {    
        if(a[prop] < b[prop])
        {    
            return 1;    
        } 
        else if(a[prop] > b[prop]) 
        {    
            return -1;    
        }    
        return 0;    
    }    
}

module.exports = {routeFormatter,objectConverter,driverCenterPointConverter,sortObject};
