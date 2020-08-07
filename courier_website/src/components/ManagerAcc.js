import React from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';

import CreateDriver from './CreateDriver';
import CreateManager from './CreateManager';

import './style/style.css';

function ManagerAcc(){

    function Logout(event){
        localStorage.setItem("Login", "false");
        localStorage.removeItem("ID");
        localStorage.removeItem("Token");
        localStorage.removeItem("Locations");
    }

    return(
        <Card className="LoginCard">
            <Card.Header>You are logged in, Welcome</Card.Header> 
            <Card.Body>
                <CreateDriver /> <br />
                <CreateManager /> <br />
                <Form onSubmit={Logout}>
                <Button variant="primary" type="submit">
                    Logout
                </Button>
            </Form>
            </Card.Body>
        </Card>
    )
}  

export default ManagerAcc;