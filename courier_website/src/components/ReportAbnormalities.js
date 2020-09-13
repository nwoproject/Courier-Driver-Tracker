import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import Alert from 'react-bootstrap/Alert';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Chart from 'react-google-charts';

import Abnormality from './Abnormality';

import "./style/style.css";

function ReportAbnormalities(props){

    const [AbnormalityArr, setAA] = useState([]);
    const [Loading, setL] = useState(true);
    const [ServerError, setSE] = useState(false);
    const [NumberAbbnormalities, setNA] = useState(0);
    const [Graph, setG] = useState(false);
    const [GraphData, setGD] = useState();

    function handleClick(event){
        if(event.target.name==="GraphSwitch"){
            setG(!Graph);
            console.log(AbnormalityArr);
        }
    }

    useEffect(()=>{
        let Token = "Bearer "+ process.env.REACT_APP_BEARER_TOKEN;
        fetch(process.env.REACT_APP_API_SERVER+"/api/abnormalities/"+props.DriverID,{
            method : "GET",
            headers:{
                'authorization': Token,
                'Content-Type' : 'application/json',     
            }
        })
        .then(respone=>{
            if(respone.status===200){
                setL(false);
                respone.json()
                .then(result=>{
                    let GData = [];
                    let GCount = 1;
                    let AbArr = {};
                    let length = 0;
                    let Counter = 0;
                    let AbObj = {};
                    GData.push(["Description","Count"]);
                    if(result.abnormalities.code_100.driver_abnormalities.length!==0){
                        GData.push(['Still for too long',0]);
                        length = length + result.abnormalities.code_100.driver_abnormalities.length;
                        result.abnormalities.code_100.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Standing still for too long.'}
                            Counter++;
                            AbObj = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Standing still for too long.'}; 
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_101.driver_abnormalities.length!==0){
                        GData.push(['Sudden Stop',0]);
                        length = length + result.abnormalities.code_101.driver_abnormalities.length;
                        result.abnormalities.code_101.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver came to a sudden stop.'}
                            AbObj = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver came to a sudden stop.'};
                            Counter++;
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_102.driver_abnormalities.length!==0){
                        GData.push(['Exceeded Speed Limit',0]);
                        length = length + result.abnormalities.code_102.driver_abnormalities.length;
                        result.abnormalities.code_102.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver exceeded the speed limit.'}
                            AbObj = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver exceeded the speed limit.'};
                            Counter++;
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_103.driver_abnormalities.length!==0){
                        GData.push(['Off Route',0]);
                        length = length + result.abnormalities.code_103.driver_abnormalities.length;
                        result.abnormalities.code_103.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver took a diffrent route than what prescribed.'}
                            Counter++;
                            AbObj = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver took a diffrent route than what prescribed.'};
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_104.driver_abnormalities.length!==0){
                        GData.push(['Driving with no Deliveries',0]);
                        length = length + result.abnormalities.code_104.driver_abnormalities.length;
                        result.abnormalities.code_104.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver was driving with the company car when no deliveries were scheduled.'}
                            AbObj = AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver was driving with the company car when no deliveries were scheduled.'};
                            Counter++;
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_105.driver_abnormalities.length!==0){
                        GData.push(['Never Started Route',0]);
                        length = length + result.abnormalities.code_105.driver_abnormalities.length;
                        result.abnormalities.code_105.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver never embarked on the route that was assigned to him.'}
                            AbObj = AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver never embarked on the route that was assigned to him.'};
                            Counter++;
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                        GCount++;
                    }
                    if(result.abnormalities.code_106.driver_abnormalities.length!==0){
                        GData.push(['Skipped Delivery on Route',0]);
                        length = length + result.abnormalities.code_106.driver_abnormalities.length;
                        result.abnormalities.code_106.driver_abnormalities.map((CurrEle, index)=>{
                            AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver skipped a delivery on his route.'}
                            AbObj = AbArr[Counter] = {'Reason' : CurrEle.driver_description, 'timestamp':CurrEle.timestamp, 'ID':Counter, 'Desc':'Driver skipped a delivery on his route.'};
                            Counter++;
                            setAA(prevState=>{return([...prevState, AbObj])});
                            GData[GCount][1] = GData[GCount][1]+1;
                        });
                    }
                    setNA(length);
                    setGD(GData);
                });
            }
            else if(respone.status===500){
                setL(false);
                setSE(true);
            }
            else{
                setL(false);
            }
        })
    },[]);

    return (
        <div>
            {Loading ? 
                <Spinner animation="border" role="status">
                    <span className="sr-only">Loading...</span>
                </Spinner>
            :
                <Card>
                    <Card.Header>Abnormality Report</Card.Header>
                    <Card.Body>
                        {ServerError ? <Alert variant="warning">An Error occured on the Server.</Alert>:null}
                        <p>The Driver has {NumberAbbnormalities} abnormalities so far.</p>
                            <Row>
                                <Col xs={4}>
                                    <Button name="GraphSwitch" onClick={handleClick}>{Graph ? "Switch to Detail View":"Switch to Graph View"}</Button>
                                </Col>
                            </Row><br />
                                {Graph ?
                                <div>
                                    <Chart
                                        width={400}
                                        height={400}
                                        chartType="PieChart"
                                        loader={<div>Loading Chart</div>}
                                        data={GraphData} 
                                    />
                                </div>
                                :
                                <Row>
                                    {AbnormalityArr.map((item, index)=>
                                        <Col xs={4} key={IDBIndex}>
                                            <Abnormality
                                                ID={index+1}
                                                key={index}
                                                Desc={item.Desc}
                                                Reason={item.Reason}
                                                Date={item.timestamp}
                                            />
                                        </Col>
                                    )}   
                                </Row>
                                }
                    </Card.Body>
                </Card>
            }
        </div>
    );
}

export default ReportAbnormalities;