import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import FormControl from 'react-bootstrap/FormControl';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alert from 'react-bootstrap/Alert';

import RouteCall from './RouteCall';
import RouteListItem from './RouteListItem';
import ScreenOverlay from './ScreenOverlay';

import './style/style.css';

function AddRoutes(){
    const [SearchQuery, setQuery] = useState("");
    const [QueryRun, setQBool] = useState(false);
    const [RoutesToAdd, ChangeRoutes] = useState(false);
    const [LocArr, setLocs] = useState([]);
    const [RouteID, setID] = useState("");
    const [ServerError, setSE] = useState(false);
    const [InvalidTokens, setIT] = useState(false);
    const [RouteMade, setRM] = useState(false);

    function handleChange(event){
        if(event.target.name==="Query"){
            setQuery(event.target.value);
        }
        else{
            setID(event.target.value);
        }
        setQBool(false);
    }

    function SubmitQuery(event){
        event.preventDefault();
        setQBool(true);
    }

    useEffect(()=>{
        if(localStorage.getItem("Locations")===null){
            ChangeRoutes(false);
        }
        else{
            ChangeRoutes(true);
            var tempArr = JSON.parse(localStorage.getItem("Locations"));
            tempArr.map(item=>{
                setLocs(prevState=>{return([...prevState, item])});
            });
        }

    },[])

    function SubmitRoute(event){
        event.preventDefault();
        if(RouteID===""){
            alert("You have to enter a Driver ID");
        }
        else{
            let LocationArr = JSON.parse(localStorage.getItem("Locations"));
            let ToSend = {};
            ToSend.token = localStorage.getItem("Token");
            ToSend.id = localStorage.getItem("ID");
            ToSend.driver_id = RouteID;
            ToSend.route = [];
            LocationArr.map(Value=>{
                let RouteObject = {};
                RouteObject.latitude = Value.Location.lat;
                RouteObject.longitude = Value.Location.lng;
                ToSend.route = ([...ToSend.route, RouteObject]);
            });
            let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
            fetch("https://drivertracker-api.herokuapp.com/api/routes",{
                method : "POST",
                headers:{
                    'authorization': Token,
                    'Content-Type' : 'application/json',     
                },
                body: JSON.stringify({
                    token : ToSend.token,
                    id : ToSend.id,
                    driver_id : ToSend.driver_id,
                    route : ToSend.route
                })
            })
            .then((response)=>{
                if(response.status===201){
                    setRM(true);
                    localStorage.removeItem("Locations");
                    
                }
                else if(response.status===401 || response.status===404){
                    setIT(true);
                }
                else if(response.status===500){
                    setSE(true);
                }
            });
        }
        
    }

    return(
        <Card className="OuterCard">
            
            <Card.Header>Search For Location</Card.Header>
            <Card.Body>
                <Card.Title>Search for a Location to Add to the Drivers Route</Card.Title>
                <Form onSubmit={SubmitQuery}>
                    <Form.Group>
                        <Form.Label>Enter Location Search Query</Form.Label>
                        <FormControl type="text" placeholder="Search" onChange={handleChange} name="Query"/>
                    </Form.Group>
                    <Button variant="primary" type="submit">Submit Search</Button>
                </Form>
                <div>{QueryRun ? <RouteCall Query={SearchQuery}/>:""}</div>
            </Card.Body>
            {RoutesToAdd ? 
                <Container fluid>
                    <h2>Current Route Locations:</h2>
                    <Row>
                        {LocArr.map((item, index)=>
                            <RouteListItem 
                                Name={item.Name}
                                key={index}/>
                        )}
                    </Row>
                    <Form onSubmit={SubmitRoute}>
                        <Form.Group>
                            <Row>
                                <Col xs={4}><Form.Control 
                                    type="text" 
                                    placeholder="Input Driver ID" 
                                    name="Route"
                                    required={true}
                                    onChange={handleChange}></Form.Control></Col>
                                <Col xs={4}><Button variant="primary" type="submit">Submit Route</Button></Col>
                            </Row>
                        </Form.Group>
                    </Form>
                </Container>:
                null}
                {RouteMade ? <ScreenOverlay title="Routes" message="The Route has been made"/>:null}
                {ServerError ? <Alert variant="warning">An Error has occured on the Server, Please try again later</Alert>:null}
                {InvalidTokens ? <Alert variant="danger">An Invalid token has been used. This could be Driver or Manager</Alert>:null}
        </Card>
    );
}

export default AddRoutes;