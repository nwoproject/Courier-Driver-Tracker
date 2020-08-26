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

const abnormalityDescription = (code) =>
{
    switch(code.toString())
    {
        case '100': 
            return 'Standing still for too long.'
        case '101':
            return 'Driver came to a sudden stop.'
        case '102':
            return 'Driver exceeded the speed limit.'
        case '103':
            return 'Driver took a diffrent route than what was prescribed.'
        case '104':
            return 'Driver was driving with the company car when no deliveries were scheduled.'
        case '105':
            return 'Driver never embarked on the route that was assigned to him.'
        case '106':
            return 'Driver skipped a delivery on his route.'
        default :
            return 'error';
    }
}

const missedRoute = (driver_id) =>
{
    return {
        "code": 105,
        "description": abnormalityDescription(105),
        "driver_description": '404',
        "timestamp" : new Date(new Date+'GMT').toISOString().slice(0,19).replace(/T/g," "), 
        "driver_id" : driver_id
    }
}

const missedDelivery = (driver_id,latitude,longitude) =>
{
    return {
        "code": 106,
        "description": abnormalityDescription(106),
        "driver_description": '404',
        "timestamp" : new Date(new Date+'GMT').toISOString().slice(0,19).replace(/T/g," "),
        "driver_id" : driver_id,
        "latitude": latitude,
        "longitude": longitude,
    }
}

const locationsToRouteArray = (results) =>
{
    let route = [];
    for(let k=0; k < results.rowCount;k++)
    {
        route.push({
            "latitude": results.rows[k].latitude,
            "longitude":results.rows[k].longitude,
            "address":results.rows[k].address,
            "name":results.rows[k].name
        });
    }
    return route;
}

const getAlldriversTojsonArray = (results) =>
{
    let drivers = [];
    for(let k=0; k < results.rowCount;k++)
    {
        drivers.push({
            "driver_id": results.rows[k].id,
            "name": results.rows[k].name,
            "surname": results.rows[k].surname
        });
    }
    return drivers;
}

module.exports = {routeFormatter,objectConverter,driverCenterPointConverter,sortObject,getAlldriversTojsonArray
    ,getDriverCentrePointResponse,abnormalityDescription,missedDelivery,missedRoute,locationsToRouteArray};
