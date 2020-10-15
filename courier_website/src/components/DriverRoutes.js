import React, {useState, useEffect} from 'react';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Alert from 'react-bootstrap/Alert';
import Spinner from 'react-bootstrap/Spinner';
import Col from 'react-bootstrap/Col';
import Row from 'react-bootstrap/Row';

import ScreenOverlay from './ScreenOverlay';

function DriverRoutes(props){

    const [RouteList, setRL] = useState([]);
    const [Loading, setL] = useState(true);
    const [NoRoutes, setNR] = useState(false);
    const [FailedDelete, setFD] = useState(false);
    const [Overlay, setO] = useState(false);

    useEffect(()=>{
        fetch(process.env.REACT_APP_API_SERVER+"/api/routes/"+props.DriverID,{
            method : "GET",
            headers:{
                'authorization' : "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'
            } 
        })
        .then(result=>{
            if(result.status===404){
                setNR(true);
                setL(false);
            }
            else{
                result.json()
                .then(response=>{
                    setRL(response.active_routes);
                    setL(false);
                });
            }
        });    
    },[])

    function DeleteRoute(event){
        fetch(process.env.REACT_APP_API_SERVER+"/api/routes/"+event.target.name,{
            method : "DELETE",
            headers:{
                'authorization' : "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'   
            },
            body: JSON.stringify({
                'id': localStorage.ID,
                'token' : localStorage.Token
            })
        })
        .then(result=>{
            console.log(result);
            if(result.status===204||result.status===200){
                setO(true);
            }
            else{
                setFD(true);
            }
        })    
    }

    return(
        <div>
            {Overlay ? <ScreenOverlay title="Route Deleted" message="The Route has been deleted"/>:null}
            {Loading ? 
            <div>
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>    
            </div>
            :
            <div>
                {FailedDelete ? <Alert variant="danger">Failed to Delete the Route. Please Try Again Later</Alert>: null}
                {NoRoutes ? <Card>
                                <Card.Body>
                                    <Alert variant="info">This Driver has no Active Routes</Alert>
                                </Card.Body>
                            </Card>
                :
                <Card>
                    <Card.Header>Routes</Card.Header>
                    <Card.Body>
                        {RouteList.map((item, index)=>
                            <Card>
                                <Card.Header>Route ID :{item.route_id}</Card.Header>
                                <Card.Body>
                                <Row>
                                    {item.locations.map((item,index)=><Col xs={4}>
                                        <Card>
                                            <Card.Header>Location ID :{item.location_id}</Card.Header>
                                            <Card.Body>
                                                <p><b>Name :</b>{item.name}</p>
                                                <p><b>Address :</b>{item.address}</p>
                                            </Card.Body>
                                        </Card>
                                    </Col>)}
                                </Row><br />
                                <Button name={item.route_id} onClick={DeleteRoute}>Delete Route</Button>
                                </Card.Body>
                            </Card>
                        )}
                    </Card.Body>
                </Card>
                }
            </div>}
        </div>
    )
}
export default DriverRoutes;