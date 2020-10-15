import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alert from 'react-bootstrap/Alert';

import './style/style.css';

function Pattern(props){
    const [PatternList, setPL] = useState();
    const [Loading, setL] = useState(true);
    const [DriverList, setDL] = useState();
    const [Pattern404, setP404] = useState(false);

    useEffect(()=>{
        fetch(process.env.REACT_APP_API_SERVER+"/api/patterns/report/"+props.time,{
            method : "GET",
            headers :{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'
            }    
        })
        .then(response=>{
            if(response.status===204){
                setP404(true);
                setL(false);
            }
            else{
                response.json()
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
            }
        });
    },[]);

    function getDriver(id){
        for(let i=0;i<DriverList.length;i++){
            if(id==DriverList[i].id){
                return(DriverList[i].name+" "+DriverList[i].surname)
            }
        }
    }

    function AbnormalityName(code){
        if(code==100){
            return(<div>Standing Still for too long<b /></div>);
        }
        else if(code==101){
            return(<div>Driver came to a Sudden Stop<b /></div>);
        }
        else if(code==102){
            return(<div>Driver exceeded the speed limit<b /></div>);
        }
        else if(code==103){
            return(<div>Driver took a diffrent route than what prescribed<b /></div>);
        }
        else if(code==104){
            return(<div>Driver was driving with the company car when no deliveries were scheduled<b /></div>);
        }
        else if(code==105){
            return(<div>Driver never embarked on the route that was assigned to him<b /></div>);
        }
        else if(code==106){
            return(<div>Driver skipped a delivery on his route<b /></div>);
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
                    <Card.Body className="ReportCard">
                        {Pattern404 ? <Alert variant="info">There are no detected patterns</Alert> :
                            <div>
                                {PatternList.map((item, index)=>
                                    <Row>
                                        <Col xs={3}>
                                            {item.pattern_detected}
                                        </Col>
                                        <Col xs={3}>
                                            Abnormality List : {item.abnormality.map((item, index)=><div>{AbnormalityName(item)}</div>)}
                                        </Col>
                                        <Col xs={2}>
                                            Occured on : {item.date.substring(0,10)}
                                        </Col>
                                        <Col xs={4}>
                                            By : {getDriver(item.driver_id)}
                                        </Col>
                                        <Col xs={12}>
                                            <hr className="BorderLine"/>
                                        </Col>
                                    </Row>
                                )}
                            </div>
                        }
                    </Card.Body>
                </Card>    
        }
        </div>
    )
}

export default Pattern;