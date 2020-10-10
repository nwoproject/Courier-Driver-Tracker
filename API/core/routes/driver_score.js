const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const checks = require('../utility/database_checks');
const async = require('async');

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

router.post('/recent', async (req,res)=>{
    if(!req.body.id || !req.body.token)
    {
        res.status(400).end()
    }
    else
    {
        await checks.driverCheck(req.body.id,req.body.token,res);
        if(!res.writableEnded)
        {
            
        }
    }
});

module.exports = router;
