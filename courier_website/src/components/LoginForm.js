import React, {useState} from 'react';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';

import './style/style.css';

function LoginForm(){
    const [emaill, updateEmail] = useState("");
    const [pass, updatePass] = useState("");

    function RealSubmit(event){
        event.preventDefault();
        let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
        fetch("https://drivertracker-api.herokuapp.com/api/managers/authenticate",{
            method : 'POST',
            headers:{
                'authorization': Token,
                'Content-Type' : 'application/json', 
            },
            body: JSON.stringify({email: emaill, password: pass})
        })
        .then(response => response.json())
        .then(result=>
            {
            localStorage.setItem("Login", "true");
            localStorage.setItem("ID", result.id);
            localStorage.setItem("Token", result.token);
            window.location.reload(false);
        })
        .catch(error=>{
            console.log(error);
        });
        
    }

    function handleChange(event){
        if(event.target.name==="updateEmail"){
            updateEmail(event.target.value);
        }
        else{
            updatePass(event.target.value);
        } 
    }


    return(
        <Card className="LoginCard">
            <Card.Header className="Title">Login</Card.Header>
            <Card.Body>
                <Form className="ActualForm" onSubmit={RealSubmit}> 
                    <Form.Group controlId="formBasicEmail">
                        <Form.Label className="FormLabel">Email address</Form.Label>
                        <Form.Control type="email" placeholder="Enter email" name="updateEmail" onChange={handleChange}/>
                        <Form.Text className="text-muted">
                        </Form.Text>
                    </Form.Group>

                    <Form.Group controlId="formBasicPassword">
                        <Form.Label>Password</Form.Label>
                        <Form.Control type="password" placeholder="Password" name="updatePass" onChange={handleChange}/>
                    </Form.Group>
                    <Button variant="primary" type="submit">
                        Submit
                    </Button>
                </Form>
            </Card.Body>
        </Card> 
    );
}

export default LoginForm;