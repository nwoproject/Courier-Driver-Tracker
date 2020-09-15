import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

function Pattern(props){
    const [PatternList, setPL] = useState();
    const [Loading, setL] = useState(true);
    const [DriverList, setDL] = useState();

    useEffect(()=>{
        fetch(process.env.REACT_APP_API_SERVER+"/api/patterns/report/"+props.time,{
            method : "GET",
            headers :{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'
            }    
        })
        .then(response=>response.json())
        .then(result=>{
            setPL(result);
        })
        .then(()=>{
            fetch(process.env.REACT_APP_API_SERVER+"/api/reports/drivers",{
                method: 'GET',
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json'    
                }
            })
            .then(response=>response.json())
            .then(result=>{
                setDL(result.drivers);
                setL(false);
            });
        });
    },[]);

    function getDriver(id){
        for(let i=0;i<DriverList.length;i++){
            if(id==DriverList[i].id){
                return(DriverList[i].name+" "+DriverList[i].surname)
            }
        }
    }

    return(
        <div>
            {Loading ? 
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>
                    :
                <Card>
                    <Card.Header>Patterns</Card.Header>
                    <Card.Body>
                    {PatternList.map((item, index)=>
                        <Row>
                            <Col xs={3}>
                                {item.pattern_detected}
                            </Col>
                            <Col xs={3}>
                                Abnormality List : {item.abnormality.map((item, index)=><div>{item}</div>)}
                            </Col>
                            <Col xs={2}>
                                Occured on : {item.date.substring(0,10)}
                            </Col>
                            <Col xs={4}>
                                By : {getDriver(item.driver_id)}
                            </Col>
                        </Row>
                    )}
                    </Card.Body>
                </Card>    
        }
        </div>
    )
}

export default Pattern;