import React from "react";
import Card from "react-bootstrap/Card";
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import "./style/style.css";

function ManagerAcc(){

    function Logout(event){
        localStorage.setItem("Login", "false");
        localStorage.removeItem("ID");
        localStorage.removeItem("Token");
        localStorage.removeItem("Locations");
    }

    return(
        <Card className="LoginCard">
            <Card.Header>You are a Manager. Nice</Card.Header> <br />
            <Form onSubmit={Logout}>
                <Button variant="primary" type="submit">
                    Logout
                </Button>
            </Form>
        </Card>
    )
}  

export default ManagerAcc;