import React, {useState, useEffect} from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';

import LocationCard from './LocationCard';

function RouteCall(props){

    const [AllLocs, setLocs] = useState([]);
    const [BoolDone, setBool] = useState(false);
    useEffect(()=>{
        var URLtoSend = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input='+props.Query+'&inputtype=textquery&fields=formatted_address,photos,name,geometry&key='+process.env.REACT_APP_GOOGLE_API;
        fetch(encodeURI(URLtoSend),{
            method: 'GET',
        })
        .then(response=>response.json())
        .then(result=>{
            setBool(false);
            result.candidates.map(CurrentElement=>{
                let Location = {};
                let geo = CurrentElement.geometry.location;
                let ForAdd = CurrentElement.formatted_address;
                let AddName = CurrentElement.name;
                let ImgSrc = "";
                try{
                    ImgSrc = CurrentElement.photos[0].photo_reference;
                }
                catch(err){
                    ImgSrc = "../images/404.png";
                }
                
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
            }); 
            
        });
    });

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