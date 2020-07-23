import React, {useState, useEffect} from 'react';

import LoginForm from '../components/LoginForm';
import ManagerAcc from '../components/ManagerAcc';

function Login(){

    const [LoginState, ChangeLogState] = useState(false);

    useEffect(()=>{
        if(localStorage.getItem("Login")==="true"){
            ChangeLogState(true);
        }
        else{
            ChangeLogState(false);
        }
    },[]);

    return(
        <div>
            {LoginState ? <ManagerAcc /> : <LoginForm />}
        </div>
    );
}

export default Login;