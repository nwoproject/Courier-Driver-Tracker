const DB = require('../../services/db_config');
const async = require('async');

const addRoute = async (req,res)=>
{
    return await new Promise((resolve)=>{
        const datetime = new Date();
        const assinged_Date = datetime.toISOString().slice(0,10);
        DB.pool.query('INSERT INTO route."route"("driver_id","completed","date_assigned")VALUES($1,$2,$3) RETURNING *',[req.body.driver_id,false,assinged_Date],(error,routeResult)=>{
            if(error)
            {
                DB.dbErrorHandler(res,error);
                resolve(error);
            }
            else
            {
                
               var series = [];
               for(var k=0; k < req.body.route.length;k++)
               {
                   series.push(k);
               }

               async.eachSeries(series,(i,callback)=>{
                    DB.pool.query('INSERT INTO route."location"("route_id","latitude","longitude")VALUES($1,$2,$3)',[routeResult.rows[0].route_id,req.body.route[i].latitude,req.body.route[i].longitude],(locationError,locationResult)=>{
                        if(locationError)
                        {
                            DB.dbErrorHandlerNoResponse(locationError);
                        }
                        callback(null);
                    });
               },(insertErr)=>{
                    if(insertErr)
                    {
                        DB.dbErrorHandler(res,insertErr);
                        resolve(insertErr);
                    }
                    else
                    {
                        res.status(201).end();
                        resolve();
                    }
               });
            }
        });
    }); 
}

module.exports = {addRoute};
