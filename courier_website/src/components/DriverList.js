import React, {useState, useEffect} from 'react';
import ListGroup from 'react-bootstrap/ListGroup';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';

import DriverProfile from "./DriverProfile";

import './style/style.css'

function DriverList(){

    const [DriverSelected, ToggleSelected] = useState(false);
    const [DriverID, setID] = useState("");
    const [DriverList, setDL] = useState([]);
    const [Loading, setL] = useState(true);

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
            setL(false);    
        });
    },[]);

    function handleClick(event){
        ToggleSelected(false);
        let someID = event.target.name;
        setTimeout(function(){ShowDriver(someID);},100);
    }

    function ShowDriver(someID){
        setID(DriverList[someID].id);
        ToggleSelected(true);
    }

    return(
        <Card className="OuterCard">
            <Card.Header>Manage Drivers</Card.Header>
            <Card.Body>
                {Loading ? 
                    <Spinner animation="border" role="status">
                        <span className="sr-only">Loading...</span>
                    </Spinner>
                :
                    <Row>
                        <Col xs={4}>
                        <ListGroup>
                            {DriverList.map((item,index)=><ListGroup.Item action name={index} key={index} onClick={handleClick}>{item.name + " "+item.surname}</ListGroup.Item>)}    
                        </ListGroup>    
                        </Col>
                        <Col xs={8}>
                            {DriverSelected ? <DriverProfile DriverID={DriverID}/>: null}
                        </Col>
                    </Row>
                }
            </Card.Body>
        </Card>
    );
}
export default DriverList;