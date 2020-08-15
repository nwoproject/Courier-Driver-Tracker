import React from 'react';
import Card from 'react-bootstrap/Card';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col'; 

import './style/style.css';

function RouteListItem(props){

    function DeleteItem(){ 
        let Arr = JSON.parse(localStorage.getItem("Locations"));
        Arr = Arr.filter((value=>{return value.Name!==props.Name}));
        if(Arr.length===0){
            localStorage.removeItem("Locations");
        }
        else{
            localStorage.setItem("Locations",JSON.stringify(Arr));
        }
        window.location.reload(false);
    }

    return(
        <Col xs={2} className="DeleteCard">
            <Card>
                <Card.Header>{props.Name}</Card.Header>
                <Card.Body>
                    <Button variant="info" onClick={DeleteItem}>Delete from Route</Button>
                </Card.Body>
            </Card>
        </Col>
    )
}

export default RouteListItem;