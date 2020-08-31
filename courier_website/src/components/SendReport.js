import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Alert from 'react-bootstrap/Alert';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';

import MockDrivers from "../mock_data/allDrivers.json";
import MockAbnormalities from "../mock_data/abnormality.json";
import MockDeliveries from "../mock_data/deliveries.json";

import './style/style.css';

function SendReport(props){

    const [AbnormalityNumberPresent, setANP] = useState(0);
    const [AbnormalityArrayCount, setAAC] = useState([]);
    const [DriverArray, setDA] = useState([]);
    const [DeliveryArray, setDlA] = useState({});
    const [SortType, setST] = useState("Abnormality Count :");
    const [AbnnorS, setAS] = useState(true);
    const [DMade, setMade] = useState(false);
    const [DMissed, setMissed] = useState(false);
    const [DLate, setLate] = useState(false);
    const [MostMade, setMM] = useState([]);
    const [MostAbnot, setMA] = useState([]);
    const [MostMissed, setMMiss] = useState([]);
    const [LeastAbb, setLA] = useState([]);
    const [Time, setT] = useState(true);

    useEffect(()=>{
        let tempNum = 0;
        let DriverItem = MockDrivers.drivers;
        let Deliveries = MockDeliveries.deliveries;
        let AbnormalityArr = MockAbnormalities.abnormalities;
        fetch(process.env.REACT_APP_API_SERVER+"/api/reports/drivers",{
            method: 'GET',
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'    
            }
        })
        .then(response=>response.json())
        .then(result=>{
            DriverItem = result.drivers;
            console.log(DriverItem);
            let TimeVar = "week";
            if(Time===false){
                TimeVar="month";
            }
            let URL = process.env.REACT_APP_API_SERVER+"/api/reports/locations/"+TimeVar;
            fetch(URL,{
                method: 'GET',
                headers:{
                    'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                    'Content-Type' : 'application/json'    
                }    
            })
            .then(response=>response.json())
            .then(result=>{
                Deliveries = result.deliveries;
                URL = process.env.REACT_APP_API_SERVER+"/api/reports/abnormality/"+TimeVar;
                fetch(URL,{
                    method: 'GET',
                    headers:{
                        'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                        'Content-Type' : 'application/json'    
                    }    
                })
                .then(response=>response.json())
                .then(result=>{
                    AbnormalityArr = result.abnormalities;
                    //======================================================================================================================
                    let AbnormalityFrequency = [];
                    let DeliveryCount = 0;
                    let DeliveryComplete = 0;
                    let DeliveryMissed = 0;
                    let LateDeliveries = 0;
                    DriverItem.map(item=>{
                        item.AbnormalityCount = 0;
                        item.DeliveryMade = 0;
                        item.DeliverMissed = 0;
                        item.DeliveryLate = 0;
                    });
                    AbnormalityArr.types.map((item, index)=>{
                        let Abnormal = {};
                        Abnormal.Desc = item.description;
                        Abnormal.Count = item.Cases.length;
                        AbnormalityFrequency[index] = Abnormal;
                        tempNum += item.Cases.length;
                        item.Cases.map(item=>{
                            let aDriver = DriverItem.findIndex(element=>element.id===item.driver_id);
                            DriverItem[aDriver].AbnormalityCount = DriverItem[aDriver].AbnormalityCount + 1;
                        });
                    });
                    Deliveries.map(item=>{
                        let RouteDriver = DriverItem.findIndex(element=>element.id===item.driver_id);
                        item.routes.map(item=>{
                            DeliveryCount += item.location.length;
                            item.location.map(item=>{
                                if(item.time_completed!==null){
                                    DeliveryComplete = DeliveryComplete + 1;
                                    DriverItem[RouteDriver].DeliveryMade = DriverItem[RouteDriver].DeliveryMade + 1;
                                    if(item.time_completed>item.time_expected){
                                        LateDeliveries++;
                                        DriverItem[RouteDriver].DeliveryLate = DriverItem[RouteDriver].DeliveryLate + 1;    
                                    }
                                }
                                else{
                                    DeliveryMissed = DeliveryMissed + 1;
                                    DriverItem[RouteDriver].DeliverMissed = DriverItem[RouteDriver].DeliverMissed + 1;
                                }
                            })
                        });
                    });
                    Deliveries.Count = DeliveryCount;
                    Deliveries.Made = DeliveryComplete;
                    Deliveries.Missed = DeliveryMissed;
                    Deliveries.Late = LateDeliveries;
                    setANP(tempNum);
                    setAAC(AbnormalityFrequency);
                    setDA(DriverItem);
                    //====================================================================================================================
                        DriverItem.sort((a,b)=>{
                            return b.AbnormalityCount - a.AbnormalityCount;
                        });
                        let tempArr = [];;
                        let index = 0;
                        tempArr[index] = DriverItem[0];
                        while(tempArr[index].AbnormalityCount===DriverItem[index+1].AbnormalityCount){
                            tempArr[index+1]=DriverItem[index+1];
                            index++;
                        }
                        setMA(tempArr);
                        tempArr=[];
                        index=DriverItem.length-1;
                        let rIndex = 0;
                        tempArr[rIndex] = DriverItem[index];
                        while(tempArr[rIndex].AbnormalityCount===DriverItem[index-1].AbnormalityCount){
                            tempArr[rIndex+1] = DriverItem[index-1];
                            rIndex++;
                            index--;
                        }
                        setLA(tempArr);
                        tempArr = [];
                        index=0;
                        DriverItem.sort((a,b)=>{
                            return b.DeliveryMade - a.DeliveryMade;
                        });
                        tempArr[index] = DriverItem[index];
                        while(tempArr[index].DeliveryMade===DriverItem[index+1].DeliveryMade){
                            tempArr[index+1]=DriverItem[index+1];
                            index++;
                        }
                        setMM(tempArr);
                        tempArr=[];
                        index=0;
                        DriverItem.sort((a,b)=>{
                            return b.DeliverMissed - a.DeliverMissed;
                        });
                        tempArr[index] = DriverItem[index];
                        while(tempArr[index].DeliverMissed===DriverItem[index+1].DeliverMissed){
                            tempArr[index+1]=DriverItem[index+1];
                            index++;
                        }
                        setMMiss(tempArr);
                    //====================================================================================================================
                    DriverItem.sort((a,b)=>{
                        return b.AbnormalityCount - a.AbnormalityCount;
                    });
                    setDlA(Deliveries);
                    //======================================================================================================================
                });
            });
        });
        /*let AbnormalityFrequency = [];
        let DeliveryCount = 0;
        let DeliveryComplete = 0;
        let DeliveryMissed = 0;
        let LateDeliveries = 0;
        DriverItem.map(item=>{
            item.AbnormalityCount = 0;
            item.DeliveryMade = 0;
            item.DeliverMissed = 0;
            item.DeliveryLate = 0;
        });
        AbnormalityArr.types.map((item, index)=>{
            let Abnormal = {};
            Abnormal.Desc = item.description;
            Abnormal.Count = item.Cases.length;
            AbnormalityFrequency[index] = Abnormal;
            tempNum += item.Cases.length;
            item.Cases.map(item=>{
                let aDriver = DriverItem.findIndex(element=>element.id===item.driver_id);
                DriverItem[aDriver].AbnormalityCount = DriverItem[aDriver].AbnormalityCount + 1;
            });
        });
        Deliveries.map(item=>{
            let RouteDriver = DriverItem.findIndex(element=>element.id===item.driver_id);
            item.routes.map(item=>{
                DeliveryCount += item.location.length;
                item.location.map(item=>{
                    if(item.time_completed!==null){
                        DeliveryComplete = DeliveryComplete + 1;
                        DriverItem[RouteDriver].DeliveryMade = DriverItem[RouteDriver].DeliveryMade + 1;
                        if(item.time_completed>item.time_expected){
                            LateDeliveries++;
                            DriverItem[RouteDriver].DeliveryLate = DriverItem[RouteDriver].DeliveryLate + 1;    
                        }
                    }
                    else{
                        DeliveryMissed = DeliveryMissed + 1;
                        DriverItem[RouteDriver].DeliverMissed = DriverItem[RouteDriver].DeliverMissed + 1;
                    }
                })
            });
        });
        Deliveries.Count = DeliveryCount;
        Deliveries.Made = DeliveryComplete;
        Deliveries.Missed = DeliveryMissed;
        Deliveries.Late = LateDeliveries;
        setANP(tempNum);
        setAAC(AbnormalityFrequency);
        setDA(DriverItem);
        //====================================================================================================================
            DriverItem.sort((a,b)=>{
                return b.AbnormalityCount - a.AbnormalityCount;
            });
            let tempArr = [];;
            let index = 0;
            tempArr[index] = DriverItem[0];
            while(tempArr[index].AbnormalityCount===DriverItem[index+1].AbnormalityCount){
                tempArr[index+1]=DriverItem[index+1];
                index++;
            }
            setMA(tempArr);
            tempArr=[];
            index=DriverItem.length-1;
            let rIndex = 0;
            tempArr[rIndex] = DriverItem[index];
            while(tempArr[rIndex].AbnormalityCount===DriverItem[index-1].AbnormalityCount){
                tempArr[rIndex+1] = DriverItem[index-1];
                rIndex++;
                index--;
            }
            setLA(tempArr);
            tempArr = [];
            index=0;
            DriverItem.sort((a,b)=>{
                return b.DeliveryMade - a.DeliveryMade;
            });
            tempArr[index] = DriverItem[index];
            while(tempArr[index].DeliveryMade===DriverItem[index+1].DeliveryMade){
                tempArr[index+1]=DriverItem[index+1];
                index++;
            }
            setMM(tempArr);
            tempArr=[];
            index=0;
            DriverItem.sort((a,b)=>{
                return b.DeliverMissed - a.DeliverMissed;
            });
            tempArr[index] = DriverItem[index];
            while(tempArr[index].DeliverMissed===DriverItem[index+1].DeliverMissed){
                tempArr[index+1]=DriverItem[index+1];
                index++;
            }
            setMMiss(tempArr);
        //====================================================================================================================
        DriverItem.sort((a,b)=>{
            return b.AbnormalityCount - a.AbnormalityCount;
        });
        setDlA(Deliveries);*/
    },[])

    function sortDriversByAb(){
        let Drivers = DriverArray;
        Drivers.sort((a,b)=>{
            return b.AbnormalityCount - a.AbnormalityCount;
        });
        setDA(Drivers);
    }

    function SortDriverByMade(){
        let Drivers = DriverArray;
        Drivers.sort((a,b)=>{
            return b.DeliveryMade - a.DeliveryMade;
        });
        setDA(Drivers);
    }

    function SortDriversByMissed(){
        let Drivers = DriverArray;
        Drivers.sort((a,b)=>{
            return b.DeliverMissed - a.DeliverMissed;
        });
        setDA(Drivers);    
    }

    function SortDriverByLate(){
        let Drivers = DriverArray;
        Drivers.sort((a,b)=>{
            return b.DeliveryLate - a.DeliveryLate;
        });
        setDA(Drivers);     
    }

    function HandleSort(event){
        if(event.target.name==="Abnor"){
            sortDriversByAb();
            setST("Abnormality Count: ");
            setAS(true);
            setMade(false);
            setMissed(false);
            setLate(false);    
        }
        else if(event.target.name==="Made"){
            SortDriverByMade();
            setST("Deliveries Made Count: ");
            setAS(false);
            setMade(true);
            setMissed(false);
            setLate(false);
        }
        else if(event.target.name==="Missed"){
            SortDriversByMissed();
            setST("Deliveries Missed Count: ");
            setAS(false);
            setMade(false);
            setMissed(true);
            setLate(false);
        }
        else if(event.target.name==="Late"){
            SortDriverByLate();
            setST("Deliveries Late Count: ");
            setAS(false);
            setMade(false);
            setMissed(false);
            setLate(true);
        }
    }

    function hanleChange(event){
        if(event.target.name==="TimeButton"){
            setT(!Time);
        }
    }

    return(
        <Card>
            <Card.Header>Full Reports</Card.Header>
            <Card.Body>
                <Button name="TimeButton" onClick={hanleChange}>{Time ? "Swap to Montly View":"Swap to Weekly View"}</Button><br /><br />
                <Row>
                    <Card className="ReportCard">
                        <Card.Header>Abnormalities</Card.Header>
                        <Card.Body>
                            <p><b>Number of Abnormalities: </b>{AbnormalityNumberPresent}</p>
                            <hr className="BorderLine"/>
                            <p><b>Abnormality Counter</b></p>
                            {AbnormalityArrayCount.map((item, index)=>
                                <Row key={index}>
                                    <Col xs={10}><b>Description: </b>{item.Desc}</Col>
                                    <Col xs={2}><b>Count: </b>{item.Count}</Col>
                                    <hr className="SmallerLine"/>
                                </Row>    
                            )}
                        </Card.Body>
                    </Card>
                </Row> <br />
                <Row>
                    <Card className="ReportCard">
                        <Card.Header>Deliveries</Card.Header>
                        <Card.Body>
                            <Row>
                                <Col xs={6}>
                                    Total Deliveries Scheduled: 
                                </Col>
                                <Col xs={3}>
                                    {DeliveryArray.Count}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={6}>
                                    Total Deliveries Made: 
                                </Col>
                                <Col xs={3}>
                                    {DeliveryArray.Made}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={6}>
                                    Total Deliveries Missed: 
                                </Col>
                                <Col xs={3}>
                                    {DeliveryArray.Missed}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={6}>
                                    Total Deliveries Late: 
                                </Col>
                                <Col xs={3}>
                                    {DeliveryArray.Late}
                                </Col>
                            </Row>
                            <hr className="BorderLine"/>
                        </Card.Body>
                    </Card>
                </Row> <br />
                <Row>
                    <Card className="ReportCard">
                        <Card.Header>Driver List</Card.Header>
                        <Card.Body>
                            <hr className="BorderLine"/>
                            <Row>
                                <Col xs={3}>
                                    <Button name="Abnor" onClick={HandleSort}>Sort by Abnormality Count</Button>
                                </Col>
                                <Col xs={3}>
                                    <Button name="Made" onClick={HandleSort}>Sort by Deliveries Made</Button>
                                </Col>
                                <Col xs={3}>
                                    <Button name="Missed" onClick={HandleSort}>Sort by Deliveries Missed</Button>
                                </Col>
                                <Col xs={3}>
                                    <Button name="Late" onClick={HandleSort}>Sort by Deliveries Late</Button>
                                </Col>
                            </Row>
                            <hr className="BorderLine"/>
                            {DriverArray.map((item, index)=>
                                <Row key={index}>
                                    <Col xs={5}>
                                        Driver Name: {item.name + " " +item.surname}
                                    </Col>
                                    <Col xs={4}>
                                        {SortType}
                                    </Col>
                                    <Col xs={2}>
                                        {AbnnorS ? item.AbnormalityCount:null}
                                        {DMade ? item.DeliveryMade:null}
                                        {DMissed ? item.DeliverMissed:null}
                                        {DLate ? item.DeliveryLate:null}
                                    </Col>
                                </Row>
                            )}
                        </Card.Body>
                    </Card>
                </Row><br />
                <Row>
                    <Card className="ReportCard">
                        <Card.Header>Notable Drivers</Card.Header>
                        <Card.Body>
                            <Row>
                                <Col xs={5}>
                                    Most Deliveries Made
                                </Col>
                                <Col xs={7}>
                                    {MostMade.map((item, index)=><Row key={index}>
                                        {item.name + " " + item.surname}
                                    </Row>)}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={5}>
                                    Most Abnormalities Made
                                </Col>
                                <Col xs={7}>
                                    {MostAbnot.map((item, index)=><Row key={index}>
                                        {item.name + " " + item.surname}
                                    </Row>)}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={5}>
                                    Most Deliveries Missed
                                </Col>
                                <Col xs={7}>
                                    {MostMissed.map((item, index)=><Row key={index}>
                                        {item.name + " " + item.surname}
                                    </Row>)}
                                </Col>
                            </Row>
                            <Row>
                                <Col xs={5}>
                                    Least Abnormalities Made
                                </Col>
                                <Col xs={7}>
                                    {LeastAbb.map((item, index)=><Row key={index}>
                                        {item.name + " " + item.surname}
                                    </Row>)}
                                </Col>
                            </Row>
                        </Card.Body>
                    </Card>
                </Row>
            </Card.Body>
        </Card>
    )
}
export default SendReport;