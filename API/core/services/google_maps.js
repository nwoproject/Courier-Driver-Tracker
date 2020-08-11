const express = require('express');
const router = express.Router();
const https = require('https');
const async = require('async');
const DB = require('./db_config');

const startingPoint = process.env.ROUTE_STARTING_POINT; //Place_id

const mapsStringQeuryConstructor = (results) =>
{
    let query = `origin=place_id:${startingPoint}&destination=place_id:${startingPoint}&waypoints=optimize:true|`;
    for(let k=0;k<results.rowCount;k++)
    {
        query+=results.rows[k].latitude;
        query+= '%2C'
        query+=results.rows[k].longitude;
        if((k+1) < results.rowCount)
        {
            query+= '%7C';
        }
    }
    query+=`&key=${process.env.MOBILE_APP_GOOGLE_API_KEY}`   ;
    return  query;
}

const objectCleaner = (mapData) =>
{
    delete mapData.geocoded_waypoints;
    for(let k=0; k < mapData.routes.length;k++)
    {
        delete mapData.routes[k].copyrights;
    }
    return mapData;
}

router.get('/web', (req, res) => {
    var searchQeury = req.query.searchQeury;
    var searchQueryResults = '';
    if(!searchQeury)
    {
        res.status(400).end()
    }
    else
    {
        https.get(`https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${searchQeury}&inputtype=textquery&fields=formatted_address,photos,name,geometry,place_id&key=${process.env.REACT_APP_GOOGLE_API}`, (resp)=>{
            let data = ' ';
            resp.on('data', (chunk) => {
                data += chunk;
              });
            resp.on('end', () => {
                searchQueryResults = JSON.parse(data);
                if(searchQueryResults.status === "OK")
                {
                    var series = [];
                    for(let k=0; k < searchQueryResults.candidates.length; k++)
                    {
                        series.push(k);
                    }
                    async.eachSeries(series,(k,callback)=>{
                        if(searchQueryResults.candidates[k].photos)
                        {
                            https.get(`https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${searchQueryResults.candidates[k].photos[0].photo_reference}&key=${process.env.REACT_APP_GOOGLE_API}`, (photoresp)=>{
                                let photodata = ' ';
                                photoresp.on('data', (chunk) => {
                                    photodata += chunk;
                                  });
                                photoresp.on('end', () => {
                                    if(photoresp.statusCode==302)
                                    {
                                        searchQueryResults.candidates[k].photo = photoresp.rawHeaders[9];
                                    }   
                                    else
                                    {
                                        searchQueryResults.candidates[k].photo = '404';
                                    }
                                   delete searchQueryResults.candidates[k].photos;
                                    callback(null);
                                });
                            });
                        }
                        else
                        {
                            searchQueryResults.candidates[k].photo = '404';
                            callback(null);
                        }
                    },(mapsError)=>{
                        if(mapsError)
                        {
                            DB.dbErrorHandler(res,mapsError);
                        }
                        else
                        {
                            res.status(200).json(searchQueryResults).end();
                        }
                   });
                }
                else
                {
                    res.status(404).end();
                }
            });
        });
    }
});

router.post('/navigation', (req, res) => {
    if(!req.body.token || !req.body.id || !req.body.route_id)
    {
        res.status(400).end();
    }
    else
    {
        DB.pool.query('SELECT EXISTS(SELECT 1 FROM public."driver" WHERE "id"=($1) AND "token"=($2))',[req.body.id,req.body.token],(driverCheckError,driverCheck)=>{
            if(driverCheckError)
            {
                DB.dbErrorHandler(res,driverCheckError);
            }
            else
            {
                if(!driverCheck.rows[0].exists)
                {
                    res.status(401).end();
                }
                else
                {
                    DB.pool.query('SELECT EXISTS(SELECT 1 FROM route."route" WHERE "route_id"=($1) AND "driver_id"=($2))',[req.body.route_id,req.body.id],(routeCheckError,routeCheck)=>{
                        if(routeCheckError)
                        {
                            DB.dbErrorHandler(res,routeCheckError);
                        }
                        else
                        {
                            if(!routeCheck.rows[0].exists)
                            {
                                res.status(404).end();
                            }
                            else
                            {
                                DB.pool.query('SELECT "location_id","latitude","longitude" FROM route."location" WHERE "route_id"=($1)',[req.body.route_id],(locationErr, locationRes)=>{
                                    if(locationErr)
                                    {
                                        DB.dbErrorHandler(res,locationErr);
                                    }
                                    else
                                    {
                                        if(locationRes.rowCount==0)
                                        {
                                            res.status(204).end();
                                        }
                                        else
                                        {
                                            const mapsApiQeury = mapsStringQeuryConstructor(locationRes);
                                            https.get(`https://maps.googleapis.com/maps/api/directions/json?${mapsApiQeury}`, (mapResp)=>{
                                                let mapData = ' ';
                                                mapResp.on('data', (chunk) => {
                                                    mapData += chunk;
                                                  });
                                                mapResp.on('end', () => {
                                                    mapData = JSON.parse(mapData);
                                                    if(mapData.status != 'OK')
                                                    {
                                                        //Something went wrong when calculating route
                                                        res.status(500).end();
                                                    }
                                                    else
                                                    {
                                                        mapData = objectCleaner(mapData);
                                                        res.status(200).json(mapData).end();
                                                    }
                                                });
                                            });
                                            
                                        }
                                    }
                                });
                            }   
                        }
                    });
                }
            }
        });
    }
});
module.exports = router;
