import React from 'react';
import Card from 'react-bootstrap/Card';
import Col from 'react-bootstrap/Col';

function ReportLocationCard(props){
    console.log(props.Location);
    return(
        <Col xs={4}>
            <Card>
                <Card.Header>Location ID: {props.Location.location_id}</Card.Header>
                <Card.Body>
                    <p><b>Name : </b>{props.Location.name}</p>
                    <p><b>Address : </b>{props.Location.address}</p>
                </Card.Body>
            </Card>
        </Col>
    )
}

export default ReportLocationCard;