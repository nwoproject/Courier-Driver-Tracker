import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Alert from 'react-bootstrap/Alert';

import './style/style.css';

function EditManager(){
    const [CurrentPass, setCurrentPass] = useState("");
    const [NewPass, setNewPass] = useState("");
    const [NewPass2, setNewPass2] = useState("");
    const [Auth, setAuth] = useState(false);
    const [IncorrectPass, setIncoPass] = useState(false);
    const [PassNoMatch, setPassMatch] = useState(false);
    const [ValidPass, setValid] = useState(false);
    const [PassChanged, setPassChange] = useState(false);
    const [PassChangedF, setPassChangeF] = useState(false);

    function handleChange(event){
        setIncoPass(false);
        setPassMatch(false);
        setValid(false);
        if(event.target.name==="CurPass"){
            setCurrentPass(event.target.value);
        }
        else if(event.target.name==="NewPass"){
            setNewPass(event.target.value);
        }
        else if(event.target.name==="NewPass2"){
            setNewPass2(event.target.value);
        }
    }

    function AuthenticateManager(event){
        event.preventDefault();
        fetch("https://drivertracker-api.herokuapp.com/api/managers/authenticate",{
            method : "POST",
            headers:{
                'authorization' : 'Bearer '+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type'  : 'application/json'
            },
            body : JSON.stringify({
                email: localStorage.Email,
                password : CurrentPass
            })
        })
        .then(response=>{
            console.log(response);
            if(response.status===200){
                setAuth(true);
            }
            else{
                setIncoPass(true);
            }
        })
    }

    function changePass(event){
        event.preventDefault();
        var ValidPassRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$/;
        if(NewPass===NewPass2){
            if(ValidPassRegex.test(NewPass)){
                fetch("https://drivertracker-api.herokuapp.com/api/managers/"+localStorage.getItem("ID")+"/password",{
                    method : 'PUT',
                    headers:{
                        'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                        'Content-Type' : 'application/json'    
                    },
                    body : JSON.stringify({
                        "password" : NewPass,
                        "token" : localStorage.getItem("Token")
                    })
                })
                .then(response=>{
                    if(response.status===204){
                        setPassChange(true);
                    }
                    else{
                        setPassChangeF(true);
                    }
                });
            }
            else{
                setValid(true);
            
            }
        }
        else{
            setPassMatch(true);
            
        }
    }

    return(
        <Card className="InnerCard">
            <Card.Header>Edit Manager</Card.Header>
            <Card.Body>
                <Form onSubmit={AuthenticateManager}>
                    <Form.Group>
                        <Row>
                            <Col xs={8}>
                                <Form.Control
                                    type="password"
                                    placeholder="Enter Current Password"
                                    name="CurPass"
                                    required={true}
                                    onChange={handleChange}/>
                            </Col>
                            <Col xs={4}>
                                <Button type="submit">
                                    Authenticate Manager
                                </Button>
                            </Col>
                        </Row>
                    </Form.Group>
                </Form>
                {IncorrectPass ? <Alert variant="danger" name="DangerAlert">Password Incorrect</Alert>:null}
                {Auth ? 
                    <Form onSubmit={changePass}>
                        <Form.Group>
                            <Row>
                                <Col xs={6}>
                                    <Form.Control 
                                        type="password"
                                        placeholder="Enter New Password"
                                        name="NewPass"
                                        required={true}
                                        onChange={handleChange}/>
                                </Col>
                                <Col xs={6}>
                                    <Form.Control 
                                        type="password"
                                        placeholder="Re-enter New Password"
                                        name="NewPass2"
                                        required={true}
                                        onChange={handleChange}/>
                                </Col>
                            </Row> <br />
                            <Row>
                                <Col>
                                    <Button type="submit">
                                        Change Password
                                    </Button>
                                </Col>
                            </Row>
                        </Form.Group>
                        {PassNoMatch ? <Alert variant="warning">Passwords do not match</Alert> : null}
                        {ValidPass ? <Alert variant="warning">Passwords is not Valid</Alert> : null}
                        {PassChangedF ? <Alert variant="danger">Could not change Password</Alert> : null}
                        {PassChanged ? <Alert variant="success">Passwords has been changed</Alert> : null}
                    </Form> 
                    : null}
            </Card.Body>
        </Card>
        
        );
}

export default EditManager;