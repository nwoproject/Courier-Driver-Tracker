const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');

// GET /api/reports/drivers
router.get('/drivers', (req, res) => {
    DB.pool.query('SELECT "id", "name", "surname" FROM public."driver"', (err, result) => {
        if (err) {
            DB.dbErrorHandler(res, err);
        } else {
            if (result.rows[0] == 0) {
                res.status(404).end();
            } else {
                let DriverArr = { "drivers": [] };
                for (let i=0;i<result.rowCount;i++){
                    DriverArr.drivers[i] = {"id": result.rows[i].id, "name": result.rows[i].name, "surname": result.rows[i].surname}
                }
                res.status(200).json(DriverArr).end();
            }
        }
    });
});

// GET /api/reports/:time
router.get('/:time',(req, res)=>{
    if(!req.params.time){
        res.status(400).end(); 
    }
    else{
        const Time = req.params.time;
        let BackDate = new Date();
        if(Time=="week"){
            BackDate.setDate(BackDate.getDate() - 7);
        }
        else if(Time=="month"){
            BackDate.setDate(BackDate.getDate() - 30);
        }
        DB.pool.query('SELECT "abnormality_code", "description", "driver_id", "datetime", "latitude", "longitude" FROM public."abnormality" WHERE "datetime">($1)',[BackDate],(err,result)=>{
            if(err){
                DB.dbErrorHandler(res,err);
            }
            else{
                if(result.rowCount==0){
                    res.status(204).end();
                }
                else{
                    let AbnormalityArr = {"abnormalities":{"types":[
                        {"code":100,"description":"Standing Still for too long","Cases":[]},
                        {"code":101,"description":"Driver came to a sudden stop","Cases":[]},
                        {"code":102,"description":"Driver exceeded the speed limit","Cases":[]},
                        {"code":103,"description":"Driver took a diffrent route than what prescribed","Cases":[]},
                        {"code":104,"description":"Driver was driving with the company car when no deliveries were scheduled","Cases":[]},
                        {"code":105,"description":"Driver never embarked on the route that was assigned to him","Cases":[]},
                        {"code":106,"description":"Driver skipped a delivery on his route","Cases":[]}
                    ]}};
                    for(let i=0;i<result.rowCount;i++){
                        let thisRow = result.rows[i];
                        let type = thisRow.abnormality_code - 100;
                        let toAdd = {
                            "driver_id": thisRow.driver_id,
                            "latitude" : thisRow.latitude,
                            "longitude": thisRow.longitude,
                            "timestamp": thisRow.datetime
                        };
                        AbnormalityArr.abnormalities.types[type].Cases.push(toAdd);
                    }
                    res.status(200).json(AbnormalityArr).end();
                }
            }
        });
    }    
});
module.exports = router;