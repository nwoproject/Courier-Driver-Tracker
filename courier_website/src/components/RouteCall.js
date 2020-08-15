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
                console.log(result);
                result.candidates.map(CurrentElement=>{
                    let Location = {};
                    let ImgSrc = "";                  
                    try{
                        ImgSrc = CurrentElement.photo;
                    }
                    catch(err){
                        ImgSrc = "../images/404.png";
                    }
                        setBool(false);
                        Location.Name = CurrentElement.name;
                        Location.ForAdd = CurrentElement.formatted_address;
                        Location.IMG = ImgSrc;
                        Location.geo = CurrentElement.geometry.location;
                        setLocs(prevState=>{return ([...prevState, Location])});
                        setBool(true);
                }); 
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