import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import FormControl from 'react-bootstrap/FormControl';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alert from 'react-bootstrap/Alert';
import Dropdown from 'react-bootstrap/Dropdown';
import DropdownButton from 'react-bootstrap/DropdownButton';

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
    const [AutoCheck, setAC] = useState(false);
    const [DriverName, setDN] = useState("");
    const [OnceOff, setOO] = useState(true);
    const [Daily, setD] = useState(false);
    const [Weekly, setW] = useState(false);
    const [Montly, setM] = useState(false);

    function handleChange(event){
        if(event.target.name==="Query"){
            setQuery(event.target.value);
        }
        else if(event.target.name==="AutoRoute"){
            setAC(!AutoCheck);
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
        let occurance = "monthly";
        if(RouteID==="" && Alert===false){
            alert("You have to enter a Driver ID");
        }
        else{
            let LocationArr = JSON.parse(localStorage.getItem("Locations"));
            let ToSend = {};
            let URL = process.env.REACT_APP_API_SERVER+"/api/routes";
            ToSend.token = localStorage.getItem("Token");
            ToSend.id = localStorage.getItem("ID");
            if(OnceOff===true){
                ToSend.driver_id = RouteID;
            }
            else if(AutoCheck){
                URL = process.env.REACT_APP_API_SERVER+"/api/routes/auto-assig";
            }
            else{
                URL = process.env.REACT_APP_API_SERVER+"/api/routes/repeating";
                if(Daily===true){
                    occurance = "daily";
                }
                else if(Weekly===true){
                    occurance = "weekly";
                }
            }
            ToSend.route = [];
            LocationArr.map(Value=>{
                let RouteObject = {};
                RouteObject.latitude = Value.Location.lat;
                RouteObject.longitude = Value.Location.lng;
                RouteObject.address = Value.Address;
                RouteObject.name = Value.Name
                ToSend.route = ([...ToSend.route, RouteObject]);
            });
            let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
            fetch(URL,{
                method : "POST",
                headers:{
                    'authorization': Token,
                    'Content-Type' : 'application/json',     
                },
                body: JSON.stringify({
                    'token' : ToSend.token,
                    'id' : ToSend.id,
                    'driver_id' : ToSend.driver_id,
                    'route' : ToSend.route,
                    'occurrence' : occurance
                })
            })
            .then((response)=>{
                if(response.status===201){
                    if(AutoCheck===true){
                        response.json()
                        .then(result=>{
                            setDN(result.name + " " + result.surname);
                        });
                    }
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

    function ClearRoute(){
        localStorage.removeItem("Locations");
        window.location.reload(false);
    }

    function handleDropDown(event){
        if(event.target.name==="Once"){
            if(OnceOff!==true){
                setOO(true);
                setAC(false);
                setD(false);
                setW(false);
                setM(false);
            }
        }
        else if(event.target.name==="OnceAuto"){
            if(AutoCheck!==true){
                setOO(false);
                setAC(true);
                setD(false);
                setW(false);
                setM(false);
            }
        }
        else if(event.target.name==="PeriodD"){
            if(Daily!==true){
                setOO(false);
                setAC(false);
                setD(true);
                setW(false);
                setM(false);
            }
        }
        else if(event.target.name==="PeriodW"){
            if(Weekly!==true){
                setOO(false);
                setAC(false);
                setD(false);
                setW(true);
                setM(false);
            }   
        }
        else if(event.target.name==="PeriodM"){
            if(Montly!==true){
                setOO(false);
                setAC(false);
                setD(false);
                setW(false);
                setM(true);
            }    
        }
        else{
            window.alert("I don't know how you got here.....");
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
                                <Col xs={2}>
                                    <DropdownButton
                                        key="right"
                                        drop="right"
                                        title="Route Style"
                                    >
                                        <Dropdown.Item name="Once" onClick={handleDropDown}>Once Off</Dropdown.Item>
                                        <Dropdown.Item name="OnceAuto" onClick={handleDropDown}>Once Off Auto Selected</Dropdown.Item>
                                        <Dropdown.Item name="PeriodD" onClick={handleDropDown}>Daily</Dropdown.Item>
                                        <Dropdown.Item name="PeriodW" onClick={handleDropDown}>Weekly</Dropdown.Item>
                                        <Dropdown.Item name="PeriodM" onClick={handleDropDown}>Montly</Dropdown.Item>
                                    </DropdownButton>
                                </Col>
                                <Col xs={2}>
                                    {OnceOff ? <p>Currently Selected is an Assigned Once Off Route</p>:null}
                                    {AutoCheck ? <p>Currently Selected is an Auto Assigned Once Off Route</p>:null}
                                    {Daily ? <p>Currently Selected is an Auto Assigned Daily Route</p>:null}
                                    {Weekly ? <p>Currently Selected is an Auto Assigned Weekly Route</p>:null}
                                    {Montly ? <p>Currently Selected is an Auto Assigned Montly Route</p>:null}
                                </Col>
                                <Col xs={4}>
                                    {OnceOff ? <Form.Control 
                                        type="text" 
                                        placeholder="Input Driver ID" 
                                        name="Route"
                                        onChange={handleChange}/>:null}
                                </Col>
                                <Col xs={2}>
                                    <Button variant="primary" type="submit">Submit Route</Button>
                                </Col>
                                <Col xs={2}>
                                    <Button variant="primary" onClick={ClearRoute}>Clear Route</Button>
                                </Col>
                            </Row>
                        </Form.Group>
                    </Form>
                </Container>:
                null}
                {RouteMade ? <ScreenOverlay title="Routes" message={AutoCheck ? "The route has been assigned to "+DriverName:"The Route has been made"}/>:null}
                {ServerError ? <Alert variant="warning">An Error has occured on the Server, Please try again later</Alert>:null}
                {InvalidTokens ? <Alert variant="danger">An Invalid token has been used. This could be Driver or Manager</Alert>:null}
        </Card>
    );
}

export default AddRoutes;