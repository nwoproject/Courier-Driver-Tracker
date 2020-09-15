import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Button from 'react-bootstrap/Button';
import Dropdown from 'react-bootstrap/Dropdown';
import DropdownButton from 'react-bootstrap/DropdownButton';
import Spinner from 'react-bootstrap/Spinner';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

import TrackMap from './TrackMap';

import './style/style.css';


function TrackingCard(){
    const [DriverID, setID] = useState();
    const [Searched, setSearch] = useState(false);
    const [DriverName, setDN] = useState("None");
    const [DriverList, setDL] = useState();
    const [LoadingList, setLL] = useState(false);

    useEffect(()=>{
        fetch(process.env.REACT_APP_API_SERVER+"/api/reports/drivers",{
            method: 'GET',
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'    
            }
        })
        .then(response=>response.json())
        .then(result=>{
            setDL(result.drivers);
            setLL(true);
        });
    },[]);

    function handleChange(event){
        let Index = event.target.id;
        setID(DriverList[Index].id);
        setDN(DriverList[Index].name + " " + DriverList[Index].surname);
        setSearch(false);
    }

    function SubmitID(event){
        if(DriverID!==""){
            setSearch(true);
        }    
    }

    return(
        <Card className="TrackingCard">
            <Card.Header>Always On Tracking</Card.Header>
            <Card.Body>
                {LoadingList ? 
                <Row>
                    <Col xs={1}>
                        <DropdownButton 
                            key="right"
                            drop="right"
                            title="Drivers">
                            {DriverList.map((item,index)=>
                                <Dropdown.Item name="DriverID" id={index} onClick={handleChange} key={index}>{item.name + " " + item.surname}</Dropdown.Item>
                            )}     
                        </DropdownButton>
                    </Col>
                    <Col xs={4}>
                            <p>Currently Selected Driver : {DriverName}</p>
                    </Col>
                    <Col xs={2}>
                        <Button onClick={SubmitID}>
                            Submit
                        </Button>
                    </Col>
                </Row>
                :
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>}
                {Searched ? <TrackMap ID={DriverID}/> : null}
            </Card.Body>
        </Card>
    );
}

export default TrackingCard;