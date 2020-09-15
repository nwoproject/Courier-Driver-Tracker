import React, {useState, useEffect} from 'react';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import { Link} from 'react-router-dom';

import './style/style.css';

function Header() {
    const [Logged, changeLog] = useState("");

    useEffect(()=>{     
        if(localStorage.getItem("Login")==="true"){
            changeLog(true);
        }
        else{
            changeLog(false);
        }
    },[Logged]);

    return(
        <Navbar bg="dark" variant="dark" sticky="top">
            <Navbar.Brand>
                <img
                    alt="?"
                    src={require('../images/logo512.png')}
                    className="d-inline-block align-top BrandLogo"
                />{' '}
            </Navbar.Brand>
                <Nav className="mr-auto">
                    <Nav.Link href="#Login" as={Link} to="/pages/Login">
                        Account
                    </Nav.Link>
                    {Logged ? 
                        <Nav.Link href="#routes" as={Link} to="/pages/Routes">
                            Routes
                        </Nav.Link>
                    :null}
                    {Logged ? 
                        <Nav.Link href="#Tracking" as={Link} to="/pages/AlwaysOnTracking">
                            Always On Tracking
                        </Nav.Link>
                    :null}
                    {Logged ? 
                        <Nav.Link href="#ManageDrivers" as={Link} to="/pages/ManageDrivers">
                            Manage Drivers
                        </Nav.Link>
                    :null}
                    {Logged ? 
                        <Nav.Link href="#Report" as={Link} to="/pages/Report">
                            Report
                        </Nav.Link>
                    :null}
                </Nav>
        </Navbar>
    );
}

export default Header;