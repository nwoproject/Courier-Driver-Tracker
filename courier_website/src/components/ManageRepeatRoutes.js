import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Spinner from 'react-bootstrap/Spinner';
import Alert from 'react-bootstrap/Alert';

import ScreenOverlay from './ScreenOverlay';

function ManageRepeatRoutes(){

    const [RouteList, setRL] = useState([]);
    const [Failed, setF] = useState(false);
    const [Loading, setL] = useState(true);
    const [FailedDelete, setFD] = useState(false);
    const [Overlay, setO] = useState(false);

    useEffect(()=>{
        fetch(process.env.REACT_APP_API_SERVER+'/api/routes/repeating/all',{
            method : "POST",
            headers: {
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json' 
            },
            body: JSON.stringify({
                'id': localStorage.ID,
                'token' : localStorage.Token
            })
        })
        .then(result=>{
            if(result.status===200||result.status===204){
                result.json()
                .then(response=>{
                    setRL(response);
                    setL(false);
                });
            }
            else{
                setF(true);
            }
        });
    },[]);

    function DeleteMe(event){
        fetch(process.env.REACT_APP_API_SERVER+"/api/routes/repeating/"+event.target.name,{
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
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner> :
            <div>
                {Failed ? <Alert variant="info">There are no repeating Routes</Alert>:
                <Card>
                    <Card.Header>Repeating Routes</Card.Header>
                    <Card.Body>
                    {FailedDelete ? <Alert variant="danger">Failed to Delete the Route. Please Try Again Later</Alert>: null}
                    {RouteList.map((item, index)=>
                        <Card>
                            <Card.Header>Route ID: {item[0].route_id}</Card.Header>
                            <Card.Body>
                                <Row>
                                {item[0].locations.map((item, index)=>
                                <Col xs={4}>
                                    <Card>
                                        <Card.Header>Location ID: {item.location_id}</Card.Header>
                                        <Card.Body>
                                            <p><b>Name : </b>{item.name}</p>
                                            <p><b>Address : </b>{item.address}</p>
                                        </Card.Body>
                                    </Card>
                                </Col>)}
                                </Row><br />
                                <Button name={item[0].route_id} onClick={DeleteMe}>Delete Route?</Button>
                            </Card.Body>
                        </Card>
                    )}
                    </Card.Body>
                </Card>
                }
            </div>
            }          
        </div>
    )
}

export default ManageRepeatRoutes;