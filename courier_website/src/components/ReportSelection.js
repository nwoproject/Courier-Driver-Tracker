import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Button from 'react-bootstrap/Button';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

import ReportAbnormalities from "./ReportAbnormalities";
import ReportRoutes from './ReportRoutes';
import SendReport from './SendReport';

function ReportSelection(props){
    
    const [Loading, setL] = useState(true);
    const [DriverName, setDN] = useState("");
    const [DriverSurname, setDS] = useState("");
    const [ToggleAbnor, setTA] = useState(false);
    const [RoutesReport, setRR] = useState(false);
    const [SendReportB, setSR] = useState(false);

    function handleButton(event){
        if(event.target.name==="Abnor"){
            setTA(!ToggleAbnor);
            setRR(false);
            setSR(false);
        }
        else if(event.target.name==="Routes"){
            setTA(false);
            setRR(!RoutesReport);
            setSR(false);
        }
        else if(event.target.name==="SendReport"){
            setTA(false);
            setRR(false);
            setSR(!SendReportB);
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
                        <Row>
                            <Col xs={4}>
                                <Button name="Abnor" onClick={handleButton}>See Abnormalities</Button>
                            </Col>
                            <Col xs={4}>
                                <Button name="Routes" onClick={handleButton}>See Routes</Button>
                            </Col>
                            
                        </Row>
                        {ToggleAbnor ? <div><br /><ReportAbnormalities DriverID={props.DriverID}/></div>:null}
                        {RoutesReport ? <div><br /><ReportRoutes DriverID={props.DriverID}/></div>:null}
                        {SendReportB ? <div><br /><SendReport DriverID={props.DriverID}/></div>:null}
                    </Card.Body>
                </Card>
            }
        </div>
    );
}

export default ReportSelection;