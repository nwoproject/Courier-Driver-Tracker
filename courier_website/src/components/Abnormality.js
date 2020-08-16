import React from 'react';
import Card from 'react-bootstrap/Card';

function Abnormality(props){
    return(
        <Card>
            <Card.Header>Abnormality {props.ID}</Card.Header>
            <Card.Body>
                <p>Description: {props.Desc}</p>
                <p>Given Reason: {props.Reason}</p>
                <p>Date: {props.Date}</p>
            </Card.Body>
        </Card>
    )
}

export default Abnormality;