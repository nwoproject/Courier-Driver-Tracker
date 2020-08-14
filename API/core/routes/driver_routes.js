const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const async = require('async');
const checks = require('./utility/database_checks');

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

// POST api/routes
router.post('/', (req, res)=>{
    var datetime = new Date();
    var assinged_Date = datetime.toISOString().slice(0,10);
    if(!req.body.id || !req.body.token || !req.body.driver_id || !req.body.route)
    {
        res.status(400).end();
    }
    else
    {
        DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."manager" WHERE "token"=($1) AND "id"=($2))',[req.body.token,req.body.id],(err,managerCheck)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            else
            {
                if(managerCheck.rows[0].exists)
                {
                    DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "id"=($1))',[req.body.driver_id],(driverCheckError,driverCheck)=>{
                        if(driverCheckError)
                        {
                            DB.dbErrorHandler(res,driverCheckError);
                        }
                        else
                        {
                            if(driverCheck.rows[0].exists)
                            {
                                DB.pool.query('INSERT INTO route."route"("driver_id","completed","date_assigned")VALUES($1,$2,$3) RETURNING *',[req.body.driver_id,false,assinged_Date],(error,routeResult)=>{
                                    if(error)
                                    {
                                        DB.dbErrorHandler(res,error);
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
                                                    DB.dbErrorHandler(res,locationError);
                                                }
                                                callback(null);
                                            });
                                       },(insertErr)=>{
                                            if(insertErr)
                                            {
                                                DB.dbErrorHandler(res,insertErr);
                                            }
                                            else
                                            {
                                                res.status(201).end();
                                            }
                                       });
                                    }
                                });
                            }
                            else
                            {
                                res.status(404).end();
                            }
                        }
                    });
                }
                else
                {
                    res.status(401).end();
                }
            }
        });
    }
});

// GET api/routes/:driverid
router.get('/:driverid', (req,res)=>{
    const driver_id = req.params.driverid;
    var routes = [];
    DB.pool.query('SELECT * FROM route."route" WHERE "driver_id"=($1) AND "completed"=($2)',[driver_id,false],(err,result)=>{
        if(err)
        {
            DB.dbErrorHandler(res,err);
        }
        else
        {
            if(result.rowCount == 0)
            {
                res.status(404).end();
            }
            else
            {
                var series = [];
                for(var k=0; k < result.rowCount;k++)
                {
                    series.push(k);
                }
                async.eachSeries(series,(i,callback)=>{
                    DB.pool.query('SELECT * FROM route."location" WHERE "route_id"=($1)',[result.rows[i].route_id],(locationError,locationResult)=>{
                        if(locationError)
                        {
                            DB.dbErrorHandler(res,locationError);
                        }
                        routes.push(routeFormatter(locationResult,result,i));
                        callback(null);
                    });
               },(queryError)=>{
                    if(queryError)
                    {
                        DB.dbErrorHandler(res,queryError);
                    }
                    else
                    {
                        res.status(200).json({"driver_id":driver_id,"active_routes: ": routes}).end();
                    }
               });
            }
        }
    });
});

// PUT api/routes/completed/:routeid
router.put('/completed/:routeid',async(req,res)=>{
    const route_id = req.params.routeid;
    if(!req.body.timestamp || !req.body.id || !req.body.token)
    {
        req.status(400).end();
    }
    else
    {
        await checks.driverCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded) // driver is valid
        {
            DB.pool.query('UPDATE route."route" SET "completed"=($1),"timestamp_completed"=($2) WHERE "route_id"=($3) AND "driver_id"=($4)',
            [true,req.body.timestamp,route_id,req.body.id], async (err,results)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(results.rowCount == 0)// No route with that route_id OR driver was not assigned to that route
                    {
                        res.status(404).end();
                    }
                    else
                    {
                        const completed = await checks.routeLocationsCheck(route_id,res);
                        if(!res.writableEnded)
                        {
                            if(completed)
                            {
                                res.status(204).end();
                            }
                            else // TODO Log that driver potentially missed a delivery
                            {
                                res.status(206).end();
                            }   
                        }
                    }
                }
            });
        }
    }
});

// PUT api/routes/location/:locationid

module.exports = router;
