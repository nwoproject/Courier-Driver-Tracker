import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';

import CreateDriver from './CreateDriver';
import CreateManager from './CreateManager';
import EditManager from './EditManager';

import './style/style.css';

function ManagerAcc(){

    const [createDriverB, setDriver] = useState(false);
    const [createManagerB, setManager] = useState(false);
    const [editManager, toggleEdit] = useState(false);

    function Logout(event){
        localStorage.setItem("Login", "false");
        localStorage.removeItem("ID");
        localStorage.removeItem("Token");
        localStorage.removeItem("Locations");
    }

    function ToggleForm(event){
        if(event.target.name === "Driver"){
            setDriver(!createDriverB);
        }
        else if(event.target.name === "Manager"){
            setManager(!createManagerB);
        }
        else{
            toggleEdit(!editManager);
        }
    }

    return(
        <Card className="OuterCard">
            <Card.Header>You are logged in, Welcome</Card.Header> 
            <Card.Body>
                <Button onClick={ToggleForm} name="Driver">
                    Toggle Create Driver    
                </Button> 
                {createDriverB ? <div><br /></div>: null}
                {createDriverB ? <CreateDriver /> : null}
                {createDriverB ? <br /> : null}
                <hr className="BorderLine"/>
                <Button onClick={ToggleForm} name="Manager">
                    Toggle Create Manager    
                </Button>
                {createManagerB ? <div><br /></div> : null}
                {createManagerB ? <CreateManager /> : null }
                {createManagerB ? <br /> : null }
                <hr className="BorderLine"/>
                <Button onClick={ToggleForm} name="EditManager">
                    Toggle Edit Manager    
                </Button>
                {editManager ? <div><br /></div> : null}
                {editManager ? <EditManager /> : null }
                {editManager ? <br /> : null }
                <hr className="BorderLine"/>
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