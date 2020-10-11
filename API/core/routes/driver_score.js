const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const checks = require('../utility/database_checks');
const async = require('async');
const db_query = require('../utility/common_queries');
const { route } = require('./drivers');

router.get('/:driverid', async (req, res)=>{
    const driver_id = req.params.driverid;
    await checks.driverExistsCheck(driver_id,res);

    if(!res.writableEnded)
    {
        DB.pool.query('SELECT "name","surname","score" FROM public."driver" WHERE "id"=($1)',[driver_id],(err,results)=>{
            if(err)
            {
                DB.dbErrorHandler(results,err);
            }
            else
            {
                res.status(200).json({
                    "name": results.rows[0].name,
                    "surname": results.rows[0].surname,
                    "score": results.rows[0].score
                }).end();
            }
        });
    }
});

router.post('/all', async (req,res)=>{
    if(!req.body.token || !req.body.id)
    {
        res.status(400).end();
    }
    else
    {
        await checks.managerCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            DB.pool.query('SELECT "name","surname","score","id" FROM public."driver"', [],(err,results)=>{
                if(err)
                {
                    DB.dbErrorHandler(res,err);
                }
                else
                {
                    let drivers = [];
                    for(let k = 0; k < results.rowCount;k++)
                    {
                        drivers.push({
                            "id":results.rows[k].id,
                            "name":results.rows[k].name,
                            "surname":results.rows[k].surname,
                            "score":results.rows[k].score
                        });
                    }

                    res.status(200).json(drivers).end();
                }
            });
        }
    }
});

router.post('/recent', async (req, res) =>{
    if(!req.body.token || !req.body.id)
    {
        res.status(400).end();
    }
    else
    {
        await checks.driverCheck(req.body.id,req.body.token, res);
        if(!res.writableEnded)
        {
            let [abnormalities, deliveries,routes] = await Promise.all([
                db_query.getRecentDriverAbnormalities(req.body.id,res), 
                db_query.getRecentDriverDeliveries(req.body.id,res),
                db_query.getRecentCompletedRoutes(req.body.id,res)
            ]);

            if(!res.writableEnded)
            {
                let events = [];
                events.push.apply(events, abnormalities);
                events.push.apply(events, deliveries);
                events.push.apply(events, routes);
                
                events.sort((x, y)=>{
                    return new Date(y.datetime) - new Date(x.datetime);
                })

                let responseArray = [];
                let responseSizeLimit = 5;

                for(let k=0;k < events.length;k++)
                {
                    responseArray.push(events[k]);

                    if(k = (responseSizeLimit)-1)
                    {
                        break;
                    }
                }

                res.status(200).json(responseArray).end();
            }

        }
    }
});

module.exports = router;
