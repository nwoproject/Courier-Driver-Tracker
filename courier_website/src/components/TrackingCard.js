import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';

import TrackMap from './TrackMap';

import './style/style.css';


function TrackingCard(){
    const [DriverID, setID] = useState();
    const [Searched, setSearch] = useState(false);
    
    function handleChange(event){
        setID(event.target.value);
        setSearch(false);
    }

    function SubmitID(event){
        event.preventDefault();   
        setSearch(true);
    }

    return(
        <Card className="TrackingCard">
            <Card.Header>Always On Tracking</Card.Header>
            <Card.Body>
                <Form inline onSubmit={SubmitID}>
                    <Form.Label srOnly>
                        Driver ID
                    </Form.Label>
                    <Form.Control 
                        className="mb-2 mr-sm-2"
                        id="DriverID"
                        placeholder="Enter Driver ID to track"
                        onChange={handleChange}/>
                    <Button type="submit" className="mb-2">
                        Submit
                    </Button>
                </Form>
                {Searched ? <TrackMap ID={DriverID}/> : <div></div>}
            </Card.Body>
        </Card>
    );
}

export default TrackingCard;