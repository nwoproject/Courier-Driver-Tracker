const express = require('express');
const router = express.Router();
const DB = require('../services/db_config');
const { dbErrorHandler } = require('../services/db_config');

// GET /api/reports/drivers
router.get('/drivers', (req, res) => {
    DB.pool.query('SELECT "id", "name", "surname" FROM public."driver" ORDER BY "name" ASC', (err, result) => {
        if (err) {
            DB.dbErrorHandler(res, err);
        } else {
            if (result.rows[0] == 0||result.rowCount==0) {
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

// GET /api/reports/abnormality/:time
router.get('/abnormality/:time',(req, res)=>{
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
        else{
            res.status(400).end()
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

// GET /api/reports/locations/:time
router.get("/locations/:time",(req,res)=>{
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
        else{
            res.status(400).end()
        }
        let DeliveryArr = {"deliveries":[]};
        let TempDID = 0;
        let TempRID = 0;
        DB.pool.query('SELECT * FROM log."location_log" L JOIN log."route_log" R ON R."route_id" = L."route_id" WHERE "date_assigned">($1) ORDER BY "driver_id" ASC, L."route_id" ASC',[BackDate],(err, result)=>{
            if(err){
                dbErrorHandler(res,err);
            }
            else{
                if(result.rowCount == 0){
                    res.status(404).end();
                }
                else{
                    let DriverObj = {"driver_id":'',"routes":[]};
                    let RouteObj = {"route_id":'',"locations":[]};
                    for(i=0;i<result.rowCount;i++){
                        let thisRow = result.rows[i];
                        //Check if same driver to continue Driver object
                        if(thisRow.driver_id == TempDID){
                            //check if same route
                            if(thisRow.route_id == TempRID){
                                RouteObj.locations.push({"location_id":thisRow.location_id,"time_expected":null,"time_completed":thisRow.timestamp_completed});
                            }
                            else{
                                DriverObj.routes.push(RouteObj);
                                RouteObj = {"route_id":thisRow.route_id,"locations":[]};
                                RouteObj.locations.push({"location_id":thisRow.location_id,"time_expected":null,"time_completed":thisRow.timestamp_completed});
                                TempRID = thisRow.route_id;
                            }
                        }
                        else{
                            if(TempDID!=0){
                                DeliveryArr.deliveries.push(DriverObj);
                            }
                            DriverObj = {"driver_id":thisRow.driver_id,"routes":[]};
                            RouteObj = {"route_id":thisRow.route_id, "locations":[]};
                            RouteObj.locations.push({"location_id":thisRow.location_id,"time_expected":null,"time_completed":thisRow.timestamp_completed});
                            TempDID = thisRow.driver_id;
                            TempRID = thisRow.route_id;
                        }
                    }
                    res.status(200).json(DeliveryArr).end();
                }
            }
        });      
    }
});
module.exports = router;