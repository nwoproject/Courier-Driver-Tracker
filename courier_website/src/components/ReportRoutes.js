import React, {useState, useEffect} from 'react';
import Spinner from 'react-bootstrap/Spinner';
import Alert from 'react-bootstrap/Alert';

import ReportRouteCard from './ReportRouteCard';

function ReportRoutes(props){

    const [Loading, setL] = useState(true);
    const [LocationArray, setLA] = useState([]);
    const [NotFound, setNF] = useState(false);
    const [ServerError, setSE] = useState(false);
    const [WeWon, setWW] = useState(false);

    useEffect(()=>{
        fetch("https://drivertracker-api.herokuapp.com/api/routes/"+props.DriverID,{
            method : "GET",
            headers:{
                'authorization': "Bearer "+ process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'
            }
        })
        .then(result=>{
            if(result.status===404){
                setNF(true);
                setL(false);
            }
            else if(result.status===500){
                setSE(true);
                setL(false);
            }
            else if(result.status===200){
                result.json()
                .then(response=>{
                    setLA(response.active_routes);
                    setWW(true);
                    setL(false);
                });
            }
            else{
                window.alert("I Have no idea how we got here...");
            }
        });
    },[]);

    return(
        <div>
            {Loading ? 
            <div>
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>
            </div>
            :
            <div>
                {NotFound ? <div><br/><Alert variant="info">The Driver has no active routes</Alert></div>: null}
                {ServerError ? <div><br/><Alert variant="danger">An Error has occured on the Server, please try again later</Alert></div>: null}
                {WeWon ? 
                    <div><br />
                        {LocationArray.map((item, index)=>
                            <ReportRouteCard Location={item} key={index}/>
                        )}      
                    </div>
                :null}
            </div>
            }
        </div>
    )
}

export default ReportRoutes;