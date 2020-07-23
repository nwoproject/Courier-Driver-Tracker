import React, {useState, useEffect} from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';

import LocationCard from './LocationCard';

function RouteCall(props){

    const [AllLocs, setLocs] = useState([]);
    const [BoolDone, setBool] = useState(false);
    useEffect(()=>{
        var URLtoSend = "https://drivertracker-api.herokuapp.com/api/google-maps/web?searchQeury="+props.Query
        try{
            fetch(encodeURI(URLtoSend),{
            method: 'GET',
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json' 
            }
            })
            .then(response=>response.json())
            .then(result=>{
                    let Location = {};
                    let geo = result.candidates[0].geometry.location;
                    let ForAdd = result.candidates[0].formatted_address;
                    let AddName = result.candidates[0].name;
                    let ImgSrc = result.photo;
                    setBool(false);
                    Location.Name = AddName;
                    Location.ForAdd = ForAdd;
                    Location.IMG = ImgSrc;
                    Location.geo = geo;
                    setLocs(prevState=>{return ([...prevState, Location])});
                    setBool(true);
                /*setBool(false);
                var ImgSrc = result.photo;
                console.log(ImgSrc);
                result.candidates.map(CurrentElement=>{
                    let Location = {};
                    let geo = CurrentElement.geometry.location;
                    let ForAdd = CurrentElement.formatted_address;
                    let AddName = CurrentElement.name;
                    
                    try{
                        let ImgSrcII = CurrentElement.photos[0].photo_reference;
                    }
                    catch(err){
                        ImgSrc = "../images/404.png";
                    }
                        setBool(false);
                        ImgSrc=CurrentElement.photo;
                        console.log(CurrentElement);
                        Location.Name = AddName;
                        Location.ForAdd = ForAdd;
                        console.log(ImgSrc);
                        Location.IMG = ImgSrc;
                        Location.geo = geo;
                        setLocs(prevState=>{return ([...prevState, Location])});
                        setBool(true);
                    
                    fetch("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+ImgSrc+"&key="+process.env.REACT_APP_GOOGLE_API,{
                        method: "GET"
                    })
                    .then(response=>{
                        setBool(false);
                        ImgSrc=response.url;
                        Location.Name = AddName;
                        Location.ForAdd = ForAdd;
                        Location.IMG = ImgSrc;
                        Location.geo = geo;
                        setLocs(prevState=>{return ([...prevState, Location])});
                        setBool(true);
                    });
                }); */
                })
            }
            catch(err){
                window.alert("lolz whoops");
            }
        },[]);

    return(
        <div>
            {BoolDone ? 
                <Container>
                    <Row>
                        {AllLocs.map((item, index)=> 
                            <LocationCard 
                                key={index}
                                IMGSrc={item.IMG}
                                LocName={item.Name}
                                FormatAdd={item.ForAdd}  
                                Geometry={item.geo}  
                            />
                        )}
                    </Row>
                </Container>
                :
                "Loading..."
                }
        </div>
    )
}

export default RouteCall;