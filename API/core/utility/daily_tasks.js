const DB = require('../services/db_config');
const check =  require('./database_checks');
const db_query = require('./common_queries');
const format = require('./json_formatter')
const coords = require('./co-ords_calculations');

const logTodaysRoutes = async () =>
{   
    await check.CheckDeliveries();

    DB.pool.query(`INSERT INTO log."route_log"("route_id","driver_id","date_assigned","completed","timestamp_completed") 
    SELECT "route_id","driver_id","date_assigned","completed","timestamp_completed" FROM route."route"`, [], (err,routes)=>{ 
        if(err)
        {
            DB.dbErrorHandlerNoResponse(err);
        }
        else
        {
            if(routes.rowCount != 0)
            {
                DB.pool.query(`INSERT INTO log."location_log"("location_id","route_id","latitude","longitude","address","name","timestamp_completed") 
                SELECT "location_id","route_id","latitude","longitude","address","name","timestamp_completed" FROM route."location"`,[],(locErr,locRes)=>{
                    if(locErr)
                    {
                        DB.dbErrorHandlerNoResponse(locErr);
                    }
                    else
                    {
                        if(locRes.rowCount > 0)
                        {
                            console.log(`Today's routes has been successfully logged, 
                            routes logged: ${routes.rowCount}
                            locations logged: ${locRes.rowCount}`);
                            refreshTodaysRoutes();
                        }
                    }
                });
            }
        }
    });
}

const refreshTodaysRoutes = async () =>
{
    DB.pool.query('TRUNCATE route."route" CASCADE;',[], (err,results)=>{
        if(err)
        {
            DB.dbErrorHandlerNoResponse(err);
        }
        else
        {
            console.log('Routes sucessfully refreshed');
        }
    });
}

const assignReaptingRoutes = async (occurrence) =>
{
    let drivers =  await db_query.getAllDrivers();
    drivers = format.getAlldriversTojsonArray(drivers);
    const dailyRoutes = await db_query.getRepeatingRoute(occurrence);

    for(let k=0; k<drivers.length;k++)
    {
        let centerpoint = await db_query.getDriverCenterPoint(drivers[k].driver_id);
        if(centerpoint.rowCount === 0) //driver has no centerpoint
        {
            drivers[k].centerpoint = false;
        }
        else 
        {
            drivers[k].centerpoint = true;
            drivers[k].latitude = centerpoint.rows[0].latitude;
            drivers[k].longitude = centerpoint.rows[0].longitude;
        }
    }
    
    let backupDrivers = drivers;    

    if(drivers.length > 0)
    {
        for(let k=0; k<dailyRoutes.rowCount;k++)
        {
            let locations =  await db_query.getRepeatingLocations(dailyRoutes.rows[k].repeating_route_id);
            locations = format.locationsToRouteArray(locations);
            let routeCenter = coords.averageCoords(locations);

            //All drivers have been assigned atleast one route, restores the drivers array so that
            // the automatic route assignment can start assigning second routes to drivers etc
            if(drivers.length == 0)
            {
                drivers = backupDrivers; 
            }

            for(let i=0; i<drivers.length;i++)
            {
                if(drivers[i].centerpoint)
                {
                    drivers[i].distance = coords.distanceBetweenLocation(routeCenter.latitude,routeCenter.longitude,drivers[i].latitude,drivers[i].longitude);
                }
                else
                {
                    drivers[i].distance = Number.MAX_SAFE_INTEGER;
                }
            }

            drivers.sort(format.sortObject('distance'));
            db_query.addRoute(locations,drivers[0].driver_id,false,false);
            console.log(`Repeating route: ${dailyRoutes.rows[k].repeating_route_id} assigned to driver ${drivers[0].driver_id}.`);
            await db_query.updateTimeLastAssignedRepeatingRoute(dailyRoutes.rows[k].repeating_route_id);
            drivers.shift();
        }
    }
    else
    {
        console.log('No drivers to assign the routes to.');
    }
}


module.exports = {logTodaysRoutes,refreshTodaysRoutes,assignReaptingRoutes};
