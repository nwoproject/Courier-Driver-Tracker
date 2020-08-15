const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const async = require('async');
const checks = require('./utility/database_checks');
const format = require('./utility/json_formatter');
const db_query = require('./utility/common_queries');

// POST api/routes
router.post('/', async (req, res)=>{
    if(!req.body.id || !req.body.token || !req.body.driver_id || !req.body.route)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            await checks.driverExistsCheck(req.body.driver_id,res);
            if(!res.writableEnded)
            {
                await db_query.addRoute(req,res);
                if(!res.writableEnded)
                {
                    res.status(500).end();
                }
            }
        }
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
                        routes.push(format.routeFormatter(locationResult,result,i));
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

// PUT api/routes/location/:locationid
router.put('/location/:locationid',async(req,res)=>{
    const location_id = req.params.locationid;
    if(!req.body.timestamp || !req.body.id || !req.body.token)
    {
        res.status(400).end();
    }
    else
    {
        await checks.driverCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            DB.pool.query('UPDATE route."location" SET "timestamp_completed"=($1) WHERE "location_id"=($2)',[req.body.timestamp,location_id], (err,results)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    if(results.rowCount == 0) // No location with that location_id
                    {
                        res.status(404).end();
                    }
                    else
                    {
                        res.status(204).end();
                    }
                }
            });
        }
    }
});

// PUT api/routes/completed/:routeid
router.put('/completed/:routeid',async(req,res)=>{
    const route_id = req.params.routeid;
    if(!req.body.timestamp || !req.body.id || !req.body.token)
    {
        res.status(400).end();
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

module.exports = router;
