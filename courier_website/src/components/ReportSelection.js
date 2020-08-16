import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Button from 'react-bootstrap/Button';

import ReportAbnormalities from "./ReportAbnormalities";

function ReportSelection(props){
    
    const [Loading, setL] = useState(true);
    const [DriverName, setDN] = useState("");
    const [DriverSurname, setDS] = useState("");
    const [ToggleAbnor, setTA] = useState(false);

    function handleButton(event){
        if(event.target.name==="Abnor"){
            setTA(!ToggleAbnor);
        }
    }

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
                    setDN(response.drivers[0].name);
                    setDS(response.drivers[0].surname);
                    setL(false);
                });
            }
        })
    },[]);

    return(
        <div>
            {Loading ? 
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>
                :
                <Card>
                    <Card.Header>{DriverName + " " + DriverSurname}</Card.Header>
                    <Card.Body>
                        <Button name="Abnor" onClick={handleButton}>See Abnormalities</Button><br />
                        <br />
                        {ToggleAbnor ? <ReportAbnormalities DriverID={props.DriverID}/>:null}
                    </Card.Body>
                </Card>
            }
        </div>
    );
}

export default ReportSelection;