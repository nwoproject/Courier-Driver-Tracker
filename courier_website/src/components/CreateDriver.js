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
    
    function handleChange(event){
        setRequest(false);
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
        else{
            if(event.target.name==="LatCo"){
                setCenter(this.Lat = event.target.value);
            }
            else{
                setCenter(this.Lng = event.target.value);
            }
        }
    }

    function changeCenter(){
        if(useCenter){
            toggleCenter(false);
        }
        else{
            toggleCenter(true);
        }
    }

    function Search(){
        setSearched(false);
        if(SearchQuery===""){
            window.alert("No Search Query Entered");
        }
        else{
            var URL = "https://drivertracker-api.herokuapp.com/api/google-maps/web?searchQeury="+SearchQuery;
            fetch(encodeURI(URL),{
                method: 'GET',
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json'    
                }
            })
            .then(response=>response.json())
            .then(result=>{
                console.log(result);
                let TempLoc = {Geo:"", AddName:"",ImgSrc:""};
                TempLoc.AddName = result.candidates[0].name;
                TempLoc.Geo = result.candidates[0].geometry.location;
                TempLoc.ImgSrc = result.candidates[0].photos[0].photo_reference;
                setLocation(TempLoc);
                setSearched(true); 
                console.log(TempLoc);
                console.log(Location);
            });
        }
    }

    function AddLocationAsCenter(){
        let tempGeo = {Lat:"", Lng:""};
        tempGeo.Lat = Location.Geo.lat;
        tempGeo.Lng = Location.Geo.lng;
        setCenter(tempGeo);
        document.getElementsByName("LatCo").value = tempGeo.Lat;
        document.getElementsByName("LonCo").value = tempGeo.Lng;
        console.log(CenterPoint);
    }

    function handleSubmit(event){
        event.preventDefault();
        var EmailRegex = /\S+@\S+\.\S+/;
        if(EmailRegex.test(email)){
            fetch("https://drivertracker-api.herokuapp.com/api/drivers",{
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
                    setRequest(true);
                }
                else if(response.status===500){
                    setServerErr(true);
                }
                else{
                    setInEmail(true);
                }
                
            })
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
                                        <Col xs={2}>
                                            <Form.Control
                                                type="text"
                                                placeholder="Latitude"
                                                name="LatCo"
                                                required={false}
                                                value={CenterPoint.Lat}
                                                onChange={handleChange}/>
                                        </Col>
                                        <Col xs={2}>
                                            <Form.Control
                                                type="text"
                                                placeholder="Longitude"
                                                name="LonCo"
                                                required={false}
                                                value={CenterPoint.Lng}
                                                onChange={handleChange}/>
                                        </Col>
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
                                                        <Card.Img variant="top" src={Location.ImgSrc}/><br/>
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
            </Card.Body>
        </Card>
    );
}

export default CreateDriver;