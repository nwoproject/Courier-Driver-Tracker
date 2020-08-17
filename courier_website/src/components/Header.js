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
                    <Nav.Link href="#Home" className="BrandHome" as={Link} to={Logged ? "/pages/Home":"/pages/Login"}>
                        Home
                    </Nav.Link>
                    <Nav.Link href="#Login" as={Link} to="/pages/Login">
                        Account
                    </Nav.Link>
                    <Nav.Link href="#routes" as={Link} to={Logged ? "/pages/Routes" : "/pages/Login"}>
                        Routes
                    </Nav.Link>
                    <Nav.Link href="#Tracking" as={Link} to={Logged ? "/pages/AlwaysOnTracking" : "/pages/Login"}>
                        Always On Tracking
                    </Nav.Link>
                    <Nav.Link href="#ManageDrivers" as={Link} to={Logged ? "/pages/ManageDrivers" : "/pages/Login"}>
                        Manage Drivers
                    </Nav.Link>
                    <Nav.Link href="#Report" as={Link} to={Logged ? "/pages/Report" : "/pages/Login"}>
                        Report
                    </Nav.Link>
                </Nav>
        </Navbar>
    );
}

export default Header;