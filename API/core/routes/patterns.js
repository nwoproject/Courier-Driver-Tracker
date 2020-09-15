const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const checks = require('../utility/database_checks');

router.post('/weekly/:driverid', async (req,res)=>{
    const driverID =  req.params.driverid;
    const datetime =  new Date(new Date() + 'GMT');
    const patternDate = datetime.toISOString().slice(0,10);
    
    await checks.driverExistsCheck(driverID,res);

    if(!res.writableEnded)
    {
        DB.pool.query('INSERT INTO ai."weekly_pattern"("pattern_detected","abnormality","day","date","driver_id")VALUES($1,$2,$3,$4,$5)',
        [req.body.patternsDetected,req.body.abnormalities,req.body.days,patternDate,driverID],(err,results)=>{
            if(err)
            {
                DB.dbErrorHandler(res,err);
            }
            else
            {
                res.status(200).end();
            }
        });
    }
});


module.exports = router;