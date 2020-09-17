import React, {useEffect, useState} from 'react';
import {Map, GoogleApiWrapper, Marker} from 'google-maps-react';
import Card from 'react-bootstrap/Card';

function AIMap(){
    const [HeatmapList, setHL] = useState();

    useEffect(()=>{

    },[]);

    const mapStyles = {
        'width': '90%',
        'display': 'block',
        'marginLeft': 'auto',
        'marginRight' : 'auto'

    };

    return(
        <Card>
            <Card.Header>Heatmap</Card.Header>
            <Card.Body>
                <Map
                google={props.google}
                zoom={14}
                style={mapStyles}>

                </Map>
            </Card.Body>
        </Card>    
    )
}