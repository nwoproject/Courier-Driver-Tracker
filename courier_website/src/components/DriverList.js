import React, {useState} from 'react';
import ListGroup from 'react-bootstrap/ListGroup';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Alert from 'react-bootstrap/Alert';
import Spinner from 'react-bootstrap/Spinner';

import DriverProfile from "./DriverProfile";

//import Drivers from '../MockData/Drivers.json';

import './style/style.css'
import Button from 'react-bootstrap/Button';

function DriverList(){

    const [DriverSelected, ToggleSelected] = useState(false);
    const [DriverID, setID] = useState("");
    const [DriverName, setDN] = useState("");
    const [DriverSName, setDSN] = useState("");
    const [NoNamem, setNN] = useState(false);
    const [NotFound, setNF] = useState(false);
    const [ServerError, setSE] = useState(false);
    const [FoundHim, setFH] = useState(false);
    const [DriverList, setDL] = useState([]);
    const [Loading, setL] = useState(false);

    function handleChange(event){
        ToggleSelected(false);
        setNN(false);
        setNF(false);
        setFH(false);
        if(event.target.name==="DriverID"){
            setID(event.target.value);
        }
        else if(event.target.name==="DriverName"){
            setDN(event.target.value);
        }
        else if(event.target.name==="DriverSName"){
            setDSN(event.target.value);
        }
    }

    function SubmitID(event){
        event.preventDefault();
        if(DriverID!==""){
            ToggleSelected(true);
        }
    }

    function SubmitIDSearch(event){
        event.preventDefault();
        setL(true);
        if(DriverName===""||DriverSName===""){
            setNN(true);
        }
        else{
            let URL = process.env.REACT_APP_API_SERVER+"/api/location/driver?name="+DriverName+"&surname="+DriverSName;
            fetch(encodeURI(URL),{
                method : "GET",
                headers:{
                    'authorization': "Bearer "+ process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json',
                }
            })
            .then(result=>{
                if(result.status===404){
                    setNF(true);
                }
                else if(result.status===500){
                    setSE(true);
                }
                else if(result.status===200){
                    result.json()
                    .then(response=>{
                        let NewArr = [];
                        response.drivers.map((item, index)=>{
                            NewArr[index] = item;
                        });
                        setDL(NewArr);
                        setFH(true);
                        setL(false);
                    });
                }   
                else{
                    window.alert("I have no idea how you got here...")
                }
            })
        }
    }
    return(
        <Card className="OuterCard">
            <Card.Header>Manage Drivers</Card.Header>
            <Card.Body>
                <Row>
                    <Col xs={4}>
                        <Row>
                            <Card>
                                <Card.Body>
                                    <Form onSubmit={SubmitID}>
                                        <Form.Label>Driver ID</Form.Label>
                                        <Form.Control
                                            name="DriverID"
                                            placeholder="Enter Driver ID"
                                            onChange={handleChange}
                                        />
                                        <br />
                                        <Button type="submit">Submit</Button>
                                    </Form> 
                                </Card.Body>
                            </Card>
                        </Row>< br/>
                        <Row>
                            <Card>
                                <Card.Body>
                                    <Form onSubmit={SubmitIDSearch}>
                                        <Form.Control
                                            name="DriverName"
                                            placeholder="Driver Name"
                                            onChange={handleChange}
                                        /><br />
                                        <Form.Control
                                            name="DriverSName"
                                            placeholder="Driver Surname"
                                            onChange={handleChange}
                                        /><br />
                                        <Button type="submit">Search For ID</Button>
                                    </Form><br />
                                    {Loading ? 
                                        <Spinner animation="border" role="status">
                                            <span className="sr-only">Loading...</span>
                                        </Spinner>
                                    :null}
                                    {FoundHim ? 
                                        <Row>
                                            {DriverList.map((item, index)=>
                                                <Alert key={index} variant="info">{item.name+" "+item.surname+ " ID: "+item.id}</Alert>
                                            )}
                                        </Row>
                                    :
                                        null
                                    }
                                    {NoNamem ? <Alert variant="danger">Either name or Surname has not been entered</Alert>:null}
                                    {ServerError ? <Alert variant="danger">An Error occurred on the Server. PLease try again later</Alert>:null}
                                    {NotFound ? <Alert variant="danger">A Driver with those details could not be found</Alert>:null}
                                </Card.Body>    
                            </Card>   
                        </Row>
                    </Col>
                    <Col xs={8}>
                        {DriverSelected ? <DriverProfile DriverID={DriverID}/>: null}
                    </Col>
                </Row>
            </Card.Body>
        </Card>
    );
}
export default DriverList;