import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alert from 'react-bootstrap/Alert';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import Tooltip from 'react-bootstrap/Tooltip';

import './style/style.css';

function CenterPoint(props){

    const [HasCenterPoint, setHCP] = useState(true);
    const [ChangeCenter, setCC] = useState(false);
    const [AssignCenter, setAC] = useState(false);
    const [EditCenter, setEC] = useState(false);
    const [SearchQuery, setSQ] = useState(false);
    const [Searched, setSearched] = useState(false);
    const [Location, setLocation] = useState({Geo:"", AddName:"",ImgSrc:""});
    const [MissingInfo, setMI] = useState(false);
    const [CenterSetDone, setCSD] = useState(false);
    const [ServerError, setSE] = useState(false);
    const [NoLocation, setNL] = useState(false);
    const [LatCord, setLatC] = useState("");
    const [LngCord, setLngC] = useState("");
    const [Radius, setR] = useState("");

    const renderTooltip = (props) =>(
        <Tooltip id="button-tooltip" {...props}>
            Enter Radius
        </Tooltip>
    );

    useEffect(()=>{
        let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
        fetch(process.env.REACT_APP_API_SERVER+"/api/drivers/centerpoint/"+props.DriverID,{
            method : "POST",
            headers:{
                'authorization': Token,
                'Content-Type' : 'application/json',  
            },
            body: JSON.stringify({
                "id" : localStorage.getItem("ID"),
                "token" : localStorage.getItem("Token")
            })
        })
        .then(result=>{
            if(result.status===404){
                setHCP(false);
            }
            else if(result.status===200){
                result.json()
                .then(response=>{
                    setLatC(response.centerpoint.latitude);
                    setLngC(response.centerpoint.longitude);
                    setR(response.centerpoint.radius.substring(0, response.centerpoint.radius.length-2));
                });
            }
        });
            
    },[]);

    function handleChange(event){
        setMI(false);
        setNL(false);
        if(event.target.name==="ChangeCP"){
            setCC(!ChangeCenter);
            setEC(!EditCenter);
        }  
        else if(event.target.name==="AssignCP"){
            setAC(!AssignCenter);
            setEC(!EditCenter);
        }
        else if(event.target.name==="LocSearch"){
            setSearched(false);
            setSQ(event.target.value);
        }
        else{
            if(event.target.name==="LatCo"){
                setLatC(event.target.value); 
            }
            else if(event.target.name==="LonCo"){
                setLngC(event.target.value);
            }
            else if(event.target.name==="Radius"){
                setR(event.target.value);
            }
        }
        
        
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
            .then(response=>{
                if(response.status===404){
                    setNL(true);
                }
                else{
                    response.json()
                    .then(result=>{
                        let TempLoc = {Geo:"", AddName:"",ImgSrc:""};
                        TempLoc.AddName = result.candidates[0].name;
                        TempLoc.Geo = result.candidates[0].geometry.location;
                        TempLoc.ImgSrc = result.candidates[0].photo;
                        setLocation(TempLoc);
                        setSearched(true); 
                    })
                }
            })
        }
    }

    function AddLocationAsCenter(){
        setLngC(Location.Geo.lng);
        setLatC(Location.Geo.lat);
    }

    function SubmitCenter(){
        if(LatCord!==""&&LngCord!==""&&Radius!==""){
            let URL = "";
            if(HasCenterPoint===true){
                URL = process.env.REACT_APP_API_SERVER+"/api/drivers/centerpoint/coords";
            }
            else{
                URL = process.env.REACT_APP_API_SERVER+"/api/drivers/centerpoint";
            }
            fetch(URL,{
                method : HasCenterPoint ? "PUT":"POST",
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json'    
                },
                body: JSON.stringify({
                    "id" : localStorage.getItem("ID"),
                    "driver_id" : props.DriverID,
                    "token" : localStorage.getItem("Token"),
                    "latitude" : LatCord,
                    "longitude" : LngCord,
                    "radius": Radius
                })
            })
            .then(result=>{
                console.log(result);
                if(result.status===204||result.status===201){
                    if(HasCenterPoint===true){
                        fetch(process.env.REACT_APP_API_SERVER+"/api/drivers/centerpoint/radius",{
                            method : "PUT",
                            headers:{
                                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                                'Content-Type' : 'application/json'    
                            },
                            body: JSON.stringify({
                                "id" : localStorage.getItem("ID"),
                                "driver_id" : props.DriverID,
                                "token" : localStorage.getItem("Token"),
                                "radius": Radius
                            })
                        })
                        .then(result=>{
                            console.log(result);
                            if(result.status===204){
                                setCSD(true);
                            }
                            else if(result.status===500){
                                setSE(true);
                            }
                        })       
                    }
                    else{
                        setCSD(true);
                    }
                }
                else if(result.status===500){
                    setSE(true);
                }
            })    
        }
        else{
            setMI(true);
        }
    }

    return(
        <div>
            <Card>
            <Card.Body>
                    <div>
                        <Card>
                            <Card.Body>
                                <Row>
                                    <Col xs={4}>
                                        <Form.Control
                                            type="text"
                                            placeholder="Latitude"
                                            name="LatCo"
                                            value={LatCord}
                                            required={false}
                                            onChange={handleChange}/>
                                    </Col>
                                    <Col xs={4}>
                                        <Form.Control
                                            type="text"
                                            placeholder="Longitude"
                                            value={LngCord}
                                            name="LonCo"
                                            required={false}
                                            onChange={handleChange}/>
                                    </Col>
                                    <Col xs={4}>
                                        <OverlayTrigger
                                            placement="right"
                                            delay={{show: 250, hide: 400}}
                                            overlay={renderTooltip}>
                                            <Form.Control
                                                type="number"
                                                placeholder="Radius"
                                                value={Radius}
                                                name="Radius"
                                                required={true}
                                                onChange={handleChange}
                                            />
                                        </OverlayTrigger>
                                    </Col>
                                </Row>
                                <br />
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
                                    <Col>
                                        <Button onClick={SubmitCenter}>Submit Center</Button>
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
                                {MissingInfo ? <div><br /><Alert variant="warning">All The Needed Info has not been added</Alert></div>:null}
                                {CenterSetDone ? <div><br /><Alert variant="success">The Center point has been changed</Alert></div>:null}
                                {ServerError ? <div><br /><Alert variant="danger">An Error on the Server has occurred, please try again later</Alert></div>:null}
                                {NoLocation ? <div><br /><Alert variant="danger">No Location has been found</Alert></div>:null}
                            </Card.Body>
                        </Card>
                    </div>
                </Card.Body>
            </Card>
        </div>
    );
}

export default CenterPoint;