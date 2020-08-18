import React from 'react';
import Card from 'react-bootstrap/Card';
import Row from 'react-bootstrap/Row';

import ReportLocationCard from './ReportLocationCard';

import './style/style.css'

function ReportRouteCard(props){
    return(
        <div>
            <Card className="InnerCard">
                <Card.Header>Route ID : {props.Location.route_id}</Card.Header>
                <Card.Body>
                    <Row>
                        {props.Location.locations.map((item, index)=>
                        <ReportLocationCard Location={item} key={index}/>)}
                    </Row>
                </Card.Body>        
            </Card>
            <br />
        </div>
    )
}

export default ReportRouteCard;