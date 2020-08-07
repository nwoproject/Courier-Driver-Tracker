import React, {useState, useEffect} from 'react';
import {Map, GoogleApiWrapper, Marker} from 'google-maps-react';
import Card from 'react-bootstrap/Card';

import './style/style.css';

function TrackMap(props){
    const [FirstCall, setLocation] = useState(false);
    const [DriverName, setName] = useState("");
    const [DriverSurname, setSurname] = useState("");
    const [DriverLat, setLat] = useState(0);
    const [DriverLng, setLng] = useState(0);

    const mapStyles = {
        'width': '90%',
        'display': 'block',
        'marginLeft': 'auto',
        'marginRight' : 'auto'

    };


    useEffect(()=>{
        const interval = setInterval(()=>{
            let Call = "https://drivertracker-api.herokuapp.com/api/location/driver?id="+props.ID;
            let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
            fetch(Call,{
                method : 'GET',
                headers:{
                    'authorization': Token,
                    'Content-Type' : 'application/json'
                }
            })
            .then(response=>response.json())
            .then(result=>{
                setName(result.drivers[0].name);
                setSurname(result.drivers[0].surname);
                setLat(result.drivers[0].latitude);
                setLng(result.drivers[0].longitude);
                setLocation(true);
            });
        }, 5000);
    });

    return(
        <div>
        {FirstCall ? 
            <Card>
                <Card.Header>
                    {"Tracking "+DriverName + " " + DriverSurname}
                </Card.Header>
                <Card.Body>
                    <div className="MapDiv">
                        <Map
                            google={props.google}
                            zoom={14}
                            style={mapStyles}
                            initialCenter={{
                                lat : DriverLat,
                                lng : DriverLng
                            }}
                            center={{
                                lat : DriverLat,
                                lng : DriverLng
                            }}
                        >
                            <Marker
                                name="Driver"
                                position={{lat:DriverLat, lng:DriverLng}}
                            />
                        </Map>
                    </div>       
                </Card.Body>
            </Card> 
        :
        <div><h4>We are searching for the Driver</h4></div>}
        </div>
    ); 
}

export default GoogleApiWrapper({
    apiKey : process.env.REACT_APP_GOOGLE_API
})(TrackMap);