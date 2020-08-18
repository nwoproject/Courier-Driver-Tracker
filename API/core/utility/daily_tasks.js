const DB = require('../services/db_config');
const check =  require('./database_checks');

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
                            console.log("Today's routes has been successfully logged");
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




module.exports = {logTodaysRoutes,refreshTodaysRoutes};
