import React from 'react';
import Card from 'react-bootstrap/Card';

function Abnormality(props){
    return(
        <Card>
            <Card.Header>Abnormality {props.ID}</Card.Header>
            <Card.Body>
                <p><b>Description:</b> {props.Desc}</p>
                <p><b>Given Reason:</b> {props.Reason}</p>
                <p><b>Date:</b> {props.Date}</p>
            </Card.Body>
        </Card>
    )
}

export default Abnormality;