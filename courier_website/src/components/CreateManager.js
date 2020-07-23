import React, {useState} from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Alert from 'react-bootstrap/Alert';

function CreateManager(){
    const [email, setMail] = useState("");
    const [name, setName] = useState("");
    const [surname, setSurname] = useState("");
    const [password1, setPass1] = useState("");
    const [password2, setPass2] = useState("");
    const [requestSent, setRequest] = useState(false);
    const [PassSame, testPass] = useState(true);
    
    function handleChange(event){
        if(event.target.name==="email"){
            setMail(event.target.value);
        }
        else if(event.target.name==="name"){
            setName(event.target.value);
        }
        else if(event.target.name==="surname"){
            setSurname(event.target.value);
        }
        else if(event.target.name==="pass1"){
            setPass1(event.target.value);
        }
        else{
            setPass2(event.target.value);
        }   
    }

    function handleSubmit(event){
        event.preventDefault();
        if(password1===password2){
            testPass(true);
            fetch("https://drivertracker-api.herokuapp.com/api/managers",{
                method : "POST",
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json' 
                },
                body : JSON.stringify({
                    email : email,
                    password: password1,
                    name : name,
                    surname: surname
                })
            })
            .then(response=>{
                console.log(response);
                setRequest(true);
            })
        }
        else{
            testPass(false);
        }
        
    }

    return(
        <Card>
            <Card.Header>Create New Manager</Card.Header>
            <Card.Body>
                <Container>
                    <Form onSubmit={handleSubmit}>
                        <Form.Group>
                            <Row>
                                <Col xs={12}>
                                    <Form.Control
                                        type="email"
                                        placeholder="Enter New Manager Email"
                                        name="email"
                                        required={true}
                                        onChange={handleChange} />
                                </Col>
                            </Row> <br />
                            <Row>
                                <Col xs={6}>
                                    <Form.Control 
                                    type="password"
                                    placeholder="Password"
                                    name="pass1"
                                    required={true}
                                    onChange={handleChange}/>
                                </Col>
                                <Col xs={6}>
                                    <Form.Control 
                                    type="password"
                                    placeholder="Confirm Password"
                                    name="pass2"
                                    required={true}
                                    onChange={handleChange}/>
                                </Col>
                            </Row><br />
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
                                    <Button variant="primary" type="submit">Create Manager</Button>
                                </Col>
                            </Row>
                        </Form.Group>
                    </Form>
                </Container>
                {PassSame ? "" : <Alert variant="warning">Passwords do not match!</Alert>}
                {requestSent ? <Alert variant="primary">Account Made</Alert> : ""}
            </Card.Body>
        </Card>
    );
}

export default CreateManager;