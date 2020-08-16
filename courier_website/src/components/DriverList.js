import React, {useState} from 'react';
import ListGroup from 'react-bootstrap/ListGroup';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';

import DriverProfile from "./DriverProfile";

//import Drivers from '../MockData/Drivers.json';

import './style/style.css'
import Button from 'react-bootstrap/Button';

function DriverList(){

    const [DriverSelected, ToggleSelected] = useState(false);
    const [DriverID, setID] = useState("");

    function handleChange(event){
        ToggleSelected(false);
        if(event.target.name==="DriverID"){
            setID(event.target.value);
        }
    }

    function SubmitID(event){
        event.preventDefault();
        ToggleSelected(true);
    }

    /*return(
        <Card className="OuterCard">
            <Card.Body>
                <Row>
                    <Col xs={3}>
                        <ListGroup>
                            {Drivers.Drivers.map((item)=>                   
                                <ListGroup.Item key={item.id} id={item.id} action onClick={Clicked}>{item.name + " " + item.surname}</ListGroup.Item>               
                            )}   
                        </ListGroup>
                    </Col>
                    {DriverSelected ? <DriverProfile DriverID={DriverID}/>: null}
                </Row>
            </Card.Body>
        </Card>
    );*/
    return(
        <Card className="OuterCard">
            <Card.Body>
                <Row>
                    <Col xs={3}>
                        <Form onSubmit={SubmitID}>
                            <Form.Label>Driver ID</Form.Label>
                            <Form.Control
                                name="DriverID"
                                placeholder="Enter Driver ID"
                                onChange={handleChange}
                            />
                            <br />
                            <Button type="submit">Submit</Button>
                        </Form> 
                    </Col>
                    {DriverSelected ? <DriverProfile DriverID={DriverID}/>: null}
                </Row>
            </Card.Body>
        </Card>

    );
}
export default DriverList;