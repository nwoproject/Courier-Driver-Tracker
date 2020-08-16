import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Button from 'react-bootstrap/Button';


function DriverProfile(props){
    const [DriverName, setName] = useState("");
    const [DriverSurname, setSurname] = useState("");
    const [Loading, setL] = useState(true);

    useEffect(()=>{
        let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
        fetch("https://drivertracker-api.herokuapp.com/api/location/driver?id="+props.DriverID,{
            method : "GET",
            headers:{
                'authorization': Token,
                'Content-Type' : 'application/json',     
            }
        })
        .then(result=>{
            if(result.status===200){
                result.json()
                .then(response=>{
                    setName(response.drivers[0].name);
                    setSurname(response.drivers[0].surname);
                    setL(false);
                });
            }
        })
    },[]);

    return(
        <Card>
            {Loading ?
                <Card.Body> 
                    <Spinner animation="border" role="status">
                        <span className="sr-only">Loading...</span>
                    </Spinner>
                </Card.Body>
            : 
                <div>
                    <Card.Header>{DriverName + " " + DriverSurname}</Card.Header>
                    <Card.Body>
                        <Button>Change Center</Button>
                        <br /> <br />
                        <Button>Delete Driver</Button>
                    </Card.Body>
                </div>}
            
        </Card>
    )
}

export default DriverProfile;