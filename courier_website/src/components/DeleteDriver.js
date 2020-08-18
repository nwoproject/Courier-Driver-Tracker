import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';

import ScreenOverlay from './ScreenOverlay';

import './style/style.css';

function DeleteDriver(props){
    
    const [Password, setP] = useState("");
    const [PasswordProblem, setPP] = useState(false);
    const [FailedDelete, setFD] = useState(false);
    const [DeleteSuc, setDS] = useState(false);

    function handleChange(event){
        setPP(false);
        if(event.target.name==="password"){
            setP(event.target.value);
        }
    }

    function DeleteDriver(event){
        event.preventDefault();
        if(Password===""){
            setPP(true);
        }
        else{
            fetch("https://drivertracker-api.herokuapp.com/api/managers/authenticate",{
                method : "POST",
                headers:{
                    'authorization' : 'Bearer '+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type'  : 'application/json'
                },
                body : JSON.stringify({
                    email: localStorage.Email,
                    password : Password
                })
            })
            .then(response=>{
                if(response.status===200){
                    fetch("https://drivertracker-api.herokuapp.com/api/drivers/"+props.DriverID,{
                        method : "DELETE",
                        headers:{
                            'authorization' : 'Bearer '+process.env.REACT_APP_BEARER_TOKEN,
                            'Content-Type'  : 'application/json'    
                        },
                        body : JSON.stringify({
                            "id" : localStorage.getItem("ID"),
                            "token" : localStorage.getItem("Token"),
                            "manager" : true
                        })
                    })
                    .then(result=>{
                        if(result.status===200){
                            setDS(true);
                        }
                        else{
                            setFD(true);
                        }
                    })    
                }
                else{
                    setPP(true);
                }
            })
        }

    }

    return(
        <Card>
            <Card.Body>
                <Alert variant="warning">This will remove the Driver in his entirety and cannot be undone.<br />Please enter your password to Confirm this decision</Alert>
                <Form onSubmit={DeleteDriver}>
                    <Row>
                        <Col xs={6}>
                            <Form.Control
                                name="password"
                                type="password"
                                required={true}
                                placeholder="Please Enter your Password"
                                onChange={handleChange}
                            />
                        </Col>
                        <Col xs={4}>
                            <Button type="submit">Delete Driver</Button>
                        </Col>
                    </Row>
                </Form>
                    {PasswordProblem ? <div><br/><Alert variant="danger">Incorrect or no Password</Alert></div>:null}
                    {DeleteSuc ? <ScreenOverlay title="Driver Delete" message="The Driver has been Deleted"/>:null}
                    {FailedDelete ? <div><br/><Alert variant="danger">The driver could not be deleted</Alert></div>:null}
            </Card.Body>
        </Card>
    );
}

export default DeleteDriver;