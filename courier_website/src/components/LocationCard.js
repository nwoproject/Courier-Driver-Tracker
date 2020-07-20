import React,{useState} from 'react';
import Card from 'react-bootstrap/Card';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import "./style/style.css";

function LocationCard(props){
    const [BoolAdded, setBool] = useState(false);
    function AddLocationToRoute(){
        let LocationArray = [];
        let ToSave = {};
        ToSave.Location = props.Geometry;
        ToSave.Name = props.LocName;
        console.log(ToSave);
        if(localStorage.getItem("Locations")===null){
            LocationArray[0] = ToSave;
            localStorage.setItem("Locations",JSON.stringify(LocationArray));
        }
        else{
            LocationArray = ([...JSON.parse(localStorage.getItem("Locations")), ToSave]);
            localStorage.setItem("Locations", JSON.stringify(LocationArray));
        }
        setBool(true);
        window.location.reload(false);
    }

    return(
        <Col xs={4}>
            <Card className="LocationCard">
                <Card.Img variant="top" src={props.IMGSrc}/>
                <Card.Body>
                    <Card.Title>{props.LocName}</Card.Title>
                    <Card.Text>{props.FormatAdd}</Card.Text>
                    {BoolAdded ? <Button variant="primary" disabled={true}>Already Added</Button> : <Button variant="primary" onClick={AddLocationToRoute}>Add Location</Button>}
                    
                </Card.Body>
            </Card>
        </Col>
    )
}

export default LocationCard;