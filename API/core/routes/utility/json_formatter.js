const routeFormatter = (locRes,routeRes,routeNum) =>
{
    var location = [];
    for(var k = 0; k < locRes.rowCount;k++)
    {
        location.push({
        "location_id":locRes.rows[k].location_id,
        "latitude":locRes.rows[k].latitude,
        "longitude":locRes.rows[k].longitude});
    }
    var route = {
                "route_id": routeRes.rows[routeNum].route_id,
                "locations": location};
    return route;
}

const objectConverter = (results) =>
{
    var drivers = [];
    for(var k = 0; k < results.rowCount;k++)
    {
        drivers.push({"id":results.rows[k].id,
        "name":results.rows[k].name,
        "surname":results.rows[k].surname,
        "latitude":results.rows[k].latitude,
        "longitude":results.rows[k].longitude});
    }
    return drivers;
}

module.exports = {routeFormatter,objectConverter};
