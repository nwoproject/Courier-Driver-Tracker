import React, {useState} from 'react';
import ListGroup from 'react-bootstrap/ListGroup';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Card from 'react-bootstrap/Card';

import DriverProfile from "./DriverProfile";

//import Drivers from '../MockData/Drivers.json';

import './style/style.css'

function DriverList(){

    const [DriverSelected, ToggleSelected] = useState(false);
    const [DriverID, setID] = useState("");

    function Clicked(event){
        ToggleSelected(false);
        setID("");
        setID(event.target.id)
        console.log("CLICKED");
        console.log(DriverID);
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
    return(<div>
        <p>whoops</p>
    </div>)
}
export default DriverList;