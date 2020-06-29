const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');

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
    if(!req.body.id || req.body.id.length ==0) // search by name and surname
    {
        DB.pool.query('SELECT * FROM public."driver" WHERE "name"=($1) AND "surname"=($2)',[req.body.name,req.body.surname],(err,results)=>{
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

                res.status(200).json({"drivers": objectConverter(results)}).end();
            }
        });
    }
    else // search by id
    {
        DB.pool.query('SELECT * FROM public."driver" WHERE "id"=($1)',[req.body.id],(err,results)=>{
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

                res.status(200).json({"drivers": objectConverter(results)}).end();
            }
        });
    }
});

module.exports = router;
