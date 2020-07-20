import React from "react";
import Navbar from "react-bootstrap/Navbar";
import "./style/style.css"

function Footer(){
    
    return(
        <Navbar bg="dark" variant="dark" fixed="bottom" className="TheFoot">
            <Navbar.Text className="BottomText">
                Create by Ctrl+Alt+Elite for COS 301 in 2020<br/>
                Created for Epi-Use in collaboration with the University of Pretoria<br/>
                All rights reserved <br/>
            </Navbar.Text>
        </Navbar>
    );
}

export default Footer;