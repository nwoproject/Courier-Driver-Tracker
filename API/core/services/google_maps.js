const express = require('express');
const router = express.Router();
const https = require('https');
const async = require('async');

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

module.exports = router;
