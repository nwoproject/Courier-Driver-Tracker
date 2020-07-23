const express = require('express');
const router = express.Router();
const https = require('https');

router.get('/web', (req, res) => {
    var searchQeury = req.query.searchQeury;
    var searchQueryResults = '';
    if(!searchQeury)
    {
        res.status(400).end()
    }
    else
    {
        https.get(`https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${searchQeury}&inputtype=textquery&fields=formatted_address,photos,name,geometry&key=${process.env.REACT_APP_GOOGLE_API}`, (resp)=>{
            let data = ' ';
            resp.on('data', (chunk) => {
                data += chunk;
              });
            resp.on('end', () => {
                searchQueryResults = JSON.parse(data);
                if(searchQueryResults.status === "OK" && searchQueryResults.photos)
                {
                    https.get(`https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${searchQueryResults.candidates[0].photos[0].photo_reference}&key=${process.env.REACT_APP_GOOGLE_API}`, (photoresp)=>{
                        let photodata = ' ';
                        photoresp.on('data', (chunk) => {
                            photodata += chunk;
                          });
                        photoresp.on('end', () => {
                            if(photoresp.statusCode==302)
                            {
                                searchQueryResults.photo = photoresp.rawHeaders[9];;
                                res.status(200).json(searchQueryResults).end();
                            }   
                            else
                            {
                                res.status(206).json(searchQueryResults).end();
                            }
                        });
                    });
                }   
                else
                {
                    if(searchQueryResults.status==="OK")
                    {
                        res.status(206).json(searchQueryResults).end();
                    }
                    else
                    {
                        res.status(404).end();
                    }
                }
            });
        });
    }
});

module.exports = router;
