import React, {useState} from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Alert from 'react-bootstrap/Alert';

function CreateDriver(){
    const [email, setMail] = useState("");
    const [name, setName] = useState("");
    const [surname, setSurname] = useState("");
    const [requestSent, setRequest] = useState(false);
    const [validEmail, setValid] = useState(true);
    const [CenterPoint, setCenter] = useState({Lat:"", Lng:""});
    const [useCenter, toggleCenter] = useState(false);
    const [SearchQuery, setQuery] = useState("");
    const [Searched, setSearched] = useState(false);
    const [Location, setLocation] = useState({Geo:"", AddName:"",ImgSrc:""});
    const [ServerError, setServerErr] = useState(false);
    const [InvalidEmail, setInEmail] = useState(false);
    const [CenterPointError, setCPE] = useState(false);
    const [LatCo, setLatC] = useState("");
    const [LngCo, setLngCo] = useState("");
    const [Radius, setR] = useState("");
    const [CenterError, setCR] = useState(false);
    
    function handleChange(event){
        setRequest(false);
        setCPE(false);
        setValid(true);
        setInEmail(false);
        if(event.target.name==="email"){
            setMail(event.target.value);
        }
        else if(event.target.name==="name"){
            setName(event.target.value);
        }
        else if(event.target.name==="surname"){
            setSurname(event.target.value);
        }
        else if(event.target.name==="LocSearch"){
            setQuery(event.target.value);
        }
        else if(event.target.name==="LatCo"){
            setLatC(event.target.value);
        }
        else if(event.target.name==="LngCo"){
            setLngCo(event.target.value);
        }
        else if(event.target.name==="Radius"){
            setR(event.target.value);
        }
    }

    function changeCenter(){
        toggleCenter(!useCenter);
    }

    function Search(){
        setSearched(false);
        if(SearchQuery===""){
            window.alert("No Search Query Entered");
        }
        else{
            var URL = process.env.REACT_APP_API_SERVER+"/api/google-maps/web?searchQeury="+SearchQuery;
            fetch(encodeURI(URL),{
                method: 'GET',
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json'    
                }
            })
            .then(response=>response.json())
            .then(result=>{
                let TempLoc = {Geo:"", AddName:"",ImgSrc:""};
                TempLoc.AddName = result.candidates[0].name;
                TempLoc.Geo = result.candidates[0].geometry.location;
                TempLoc.ImgSrc = result.candidates[0].photo;
                setLocation(TempLoc);
                setSearched(true); 
            });
        }
    }

    function AddLocationAsCenter(){
        setLatC(Location.Geo.lat);
        setLngCo(Location.Geo.lng);
    }


    function CreateDriver(){
        fetch(process.env.REACT_APP_API_SERVER+"/api/drivers",{
            method : "POST",
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json' 
            },
            body : JSON.stringify({
                email : email,
                name : name,
                surname: surname
            })
        })
        .then(response=>{
            if(response.status===201){
                if(useCenter===true){
                    response.json()
                    .then(result=>{
                        fetch(process.env.REACT_APP_API_SERVER+"/api/drivers/centerpoint",{
                            method : "POST",
                            headers:{
                                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                                'Content-Type' : 'application/json' 
                                },
                            body : JSON.stringify({
                                "id" : localStorage.getItem("ID"),
                                "driver_id" : result.id,
                                "token" : localStorage.getItem("Token"),
                                "latitude" : LatCo,
                                "longitude" : LngCo,
                                "radius" : Radius
                            })
                        })
                        .then(response=>{
                            if(response.status===201){
                                setRequest(true);
                            }
                            else{
                                setCR(true);
                            }
                        })   
                    })    
                }
                
            }
            else if(response.status===500){
                setServerErr(true);
            }
            else{
                setInEmail(true);
            }
                        
        })
    }

    function handleSubmit(event){
        event.preventDefault();
        var EmailRegex = /\S+@\S+\.\S+/;
        if(EmailRegex.test(email)){
            if(useCenter===true){
                if(LatCo!==""&&LngCo!==""&&Radius!==""){
                    CreateDriver();
                }
                else{
                    setCPE(true);    
                }
            }
            else{
                CreateDriver();  
            }

        }
        else{
            setValid(false);
        }
        
    }

    return(
        <Card className="InnerCard">
            <Card.Header>Create New Driver</Card.Header>
            <Card.Body>
                <Container>
                    <Form onSubmit={handleSubmit}>
                        <Form.Group>
                            <Row>
                                <Col xs={12}>
                                    <Form.Control
                                        type="email"
                                        placeholder="Enter New Driver Email"
                                        name="email"
                                        required={true}
                                        onChange={handleChange} />
                                </Col>
                            </Row> <br />
                            <Row>
                                <Col xs={4}>
                                    <Form.Control 
                                    type="text"
                                    placeholder="First Name"
                                    name="name"
                                    required={true}
                                    onChange={handleChange}/>
                                </Col>
                                <Col xs={4}>
                                    <Form.Control 
                                    type="text"
                                    placeholder="Last Name"
                                    name="surname"
                                    required={true}
                                    onChange={handleChange}/>
                                </Col>
                                <Col xs={4}>
                                    <Button variant="secondary" onClick={changeCenter}>Add Center Point</Button>
                                </Col>
                            </Row>
                            {useCenter ? 
                                <div><br />
                                    <Row>
                                        <Col xs={4}>
                                            <Form.Control
                                                type="text"
                                                placeholder="Latitude"
                                                name="LatCo"
                                                required={false}
                                                value={LatCo}
                                                onChange={handleChange}/>
                                        </Col>
                                        <Col xs={4}>
                                            <Form.Control
                                                type="text"
                                                placeholder="Longitude"
                                                name="LngCo"
                                                required={false}
                                                value={LngCo}
                                                onChange={handleChange}/>
                                        </Col>
                                        <Col xs={4}>
                                            <Form.Control
                                                    type="number"
                                                    placeholder="Radius"
                                                    name="Radius"
                                                    required={false}
                                                    value={Radius}
                                                    onChange={handleChange}/>
                                        </Col>
                                    </Row><br />
                                    <Row>
                                        <Col xs={4}>
                                            <Form.Control
                                                type="text"
                                                placeholder="Search for Location"
                                                name="LocSearch"
                                                required={false}
                                                onChange={handleChange}/>
                                        </Col>
                                        <Col xs={4}>
                                            <Button variant="secondary" onClick={Search}>Search Location</Button>
                                        </Col>
                                    </Row>
                                    {Searched ? 
                                        <Row>
                                            <Col xs={4}>
                                                <br/>
                                                <Card>
                                                    <Card.Header>{Location.AddName}</Card.Header>
                                                    <Card.Body>
                                                        <Card.Img variant="top" src={Location.ImgSrc}/><br/><br/>
                                                        <Button variant="secondary" onClick={AddLocationAsCenter}>Add As Center Point</Button>
                                                    </Card.Body> 
                                                </Card>
                                            </Col>
                                        </Row>
                                        : 
                                        null}
                                </div>
                                : 
                                null
                            }
                            <br />
                            <Row>
                                <Col xs={4}>
                                    <Button variant="primary" type="submit">Create Driver</Button>
                                </Col>
                            </Row>
                        </Form.Group>
                    </Form>
                </Container>
                {requestSent ? <Alert variant="primary">Account Made</Alert> : null}
                {validEmail ? null:<Alert variant="warning">The Email Entered is not Valid</Alert>}
                {ServerError ? <Alert variant="warning">There is an error with the Server, Please try again later</Alert>:null}
                {InvalidEmail ? <Alert variant="danger">Email already in use</Alert>:null}
                {CenterPointError ? <Alert variant="danger">Center Point expected, but None was entered</Alert>:null}
                {CenterError ? <Alert variant="danger">An Error occured while assigning the Center Point. The Driver has however been made.<br />Please add a center point using the Manage Settings tab</Alert>:null}
            </Card.Body>
        </Card>
    );
}

export default CreateDriver;