import React from "react";
import {Switch, Route} from 'react-router-dom';

import Login from "./pages/Login";
import Home from "./pages/Home";
import Routes from "./pages/Routes";
import AlwaysOnTracking from "./pages/AlwaysOnTracking";

const Main = () =>{
    return(
        <Switch>
            <Route exact path="/pages/Login" component={Login}></Route>
            <Route exact path="/pages/Home" component={Home}></Route>
            <Route exact path="/pages/Routes" component={Routes}></Route>
            <Route exact path="/pages/AlwaysOnTracking" component={AlwaysOnTracking}></Route>
            <Route path="/" component={Login}></Route>
        </Switch>
    );
}

export default Main;