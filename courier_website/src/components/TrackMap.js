import React, {useState, useEffect} from 'react';
import {Map, GoogleApiWrapper, Marker} from 'google-maps-react';
import Card from 'react-bootstrap/Card';
import Alert from 'react-bootstrap/Alert';
import Spinner from 'react-bootstrap/Spinner';

import './style/style.css';

function TrackMap(props){
    const [FirstCall, setLocation] = useState(false);
    const [DriverName, setName] = useState("");
    const [DriverSurname, setSurname] = useState("");
    const [DriverLat, setLat] = useState(0);
    const [DriverLng, setLng] = useState(0);
    const [DriverNotFound, setDF] = useState(false);
    const [ServerError, setSE] = useState(false);
    const [Looking, setL] = useState(true);

    const mapStyles = {
        'width': '90%',
        'display': 'block',
        'marginLeft': 'auto',
        'marginRight' : 'auto'

    };


    useEffect(()=>{
        const interval = setInterval(()=>{
            setL(true);
            let Call = process.env.REACT_APP_API_SERVER+"/api/location/driver?id="+props.ID;
            let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
            fetch(Call,{
                method : 'GET',
                headers:{
                    'authorization': Token,
                    'Content-Type' : 'application/json'
                }
            })
            .then(response=>{
                if(response.status===404){
                    setDF(true);
                    setL(false);
                    return null;
                }
                else if(response.status===500){
                    setSE(true);
                    setL(false);
                    return null;
                }
                else{
                    response.json()
                    .then(result=>{
                        setName(result.drivers[0].name);
                        setSurname(result.drivers[0].surname);
                        setLat(result.drivers[0].latitude);
                        setLng(result.drivers[0].longitude);
                        setLocation(true);
                    })
                }
            });
        }, 10000);
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
            <div>
                {Looking ? <div><h4>Looking for that Driver</h4>
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>
                </div>:null}
                {DriverNotFound ? <Alert variant="danger">The Driver was not found.</Alert>:null}
                {ServerError ? <Alert variant="warning">There was an error on the Server. Please try again later</Alert>:null}
            </div>
            }
        </div>
    ); 
}

export default GoogleApiWrapper({
    apiKey : process.env.REACT_APP_GOOGLE_API
})(TrackMap);