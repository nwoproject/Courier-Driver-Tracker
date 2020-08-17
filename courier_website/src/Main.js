import React from "react";
import {Switch, Route} from 'react-router-dom';

import Login from "./pages/Login";
import Home from "./pages/Home";
import Routes from "./pages/Routes";
import AlwaysOnTracking from "./pages/AlwaysOnTracking";
import ManageDrivers from "./pages/ManageDrivers";
import Report from './pages/Report';

const Main = () =>{
    return(
            <Switch>
                <Route exact path="/pages/Login" component={Login}></Route>
                <Route exact path="/pages/Home" component={Home}></Route>
                <Route exact path="/pages/Routes" component={Routes}></Route>
                <Route exact path="/pages/AlwaysOnTracking" component={AlwaysOnTracking}></Route>
                <Route exact path="/pages/ManageDrivers" component={ManageDrivers}></Route>
                <Route exact path="/pages/Report" component={Report}></Route>
                <Route path="/" component={Login}></Route>
            </Switch>
    );
}

export default Main;