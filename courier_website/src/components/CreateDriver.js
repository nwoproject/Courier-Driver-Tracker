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
    
    function handleChange(event){
        setRequest(false);
        setValid(true);
        if(event.target.name==="email"){
            setMail(event.target.value);
        }
        else if(event.target.name==="name"){
            setName(event.target.value);
        }
        else{
            setSurname(event.target.value);
        }
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
                console.log(response);
                setRequest(true);
            })
        }
        else{
            setValid(false);
        }
        
    }

    return(
        <Card>
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
                                    <Button variant="primary" type="submit">Create Driver</Button>
                                </Col>
                            </Row>
                        </Form.Group>
                    </Form>
                </Container>
                {requestSent ? <Alert variant="primary">Account Made</Alert> : null}
                {validEmail ? null:<Alert variant="warning">The Email Entered is not Valid</Alert>}
            </Card.Body>
        </Card>
    );
}

export default CreateDriver;