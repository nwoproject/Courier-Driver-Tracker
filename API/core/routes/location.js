const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const format = require('../utility/json_formatter');

// PUT /api/location/:driverid
router.put('/:driverid', (req, res)=>{
    if((!req.body.latitude || req.body.latitude.length==0)||(!req.body.longitude || req.body.longitude.length==0))
    {
        res.status(400).end();
    }
    const driverID = req.params.driverid;
    DB.pool.query('UPDATE public."driver" SET "latitude"=($1),"longitude"=($2) WHERE "id"=($3) AND "token"=($4)',[req.body.latitude,req.body.longitude,driverID,req.body.token],(updateError,updateResults)=>{
        if(updateError)
        {
            DB.dbErrorHandler(res,updateError);
        }
        else
        {
            if(updateResults.rowCount==1)
            {
                res.status(204).end();
            }
            else
            {
                res.status(400).end();
            }
        }
    });
});

// GET /api/location/driver
router.get('/driver', (req, res)=>{
    if(!req.query.id || req.query.id.length ==0) // search by name and surname
    {
        DB.pool.query('SELECT * FROM public."driver" WHERE "name"=($1) AND "surname"=($2)',[req.query.name,req.query.surname],(err,results)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            else
            {
                if(results.rowCount==0)
                {
                    res.status(404).end();
                }
                else
                {
                    res.status(200).json({"drivers": format.objectConverter(results)}).end();
                }
            }
        });
    }
    else // search by id
    {
        DB.pool.query('SELECT * FROM public."driver" WHERE "id"=($1)',[req.query.id],(err,results)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            else
            {
                if(results.rowCount==0)
                {
                    res.status(404).end();
                }
                else
                {
                    res.status(200).json({"drivers": format.objectConverter(results)}).end();
                }
            }
        });
    }
});

module.exports = router;
