import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Spinner from 'react-bootstrap/Spinner';
import Chart from 'react-google-charts';

import MockDrivers from "../mock_data/allDrivers.json";
import MockAbnormalities from "../mock_data/abnormality.json";
import MockDeliveries from "../mock_data/deliveries.json";
import Pattern from './Pattern';

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
    const [DScore, setDS] = useState(false);
    const [MostMade, setMM] = useState([]);
    const [MostAbnot, setMA] = useState([]);
    const [MostMissed, setMMiss] = useState([]);
    const [LeastAbb, setLA] = useState([]);
    const [DriverScore, setDriverScore] = useState([]);
    const [Time, setT] = useState(true);
    const [Loading, setLoad] = useState(true);
    const [AbnorPie, setAP] = useState(false);
    const [PieData, setPD] = useState([]);
    const [SeeDC, setSDC] = useState(false);

    useEffect(()=>{
        let tempNum = 0;
        let DriverItem = MockDrivers.drivers;
        let Deliveries = MockDeliveries.deliveries;
        let AbnormalityArr = MockAbnormalities.abnormalities;
        if(props.Time!=="week"){
            setT(false);
        }
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
            let TimeVar = props.Time;
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
                        let aDriver = '';
                        let searching = true;
                        let index = 0;
                        while(searching){
                            if(DriverItem[index].id == item.driver_id){
                                aDriver = index;
                                searching = false;
                            }
                            else{
                                index++;
                            }
                        }
                        item.routes.map(item=>{
                            DeliveryCount += item.locations.length;
                            item.locations.map(item=>{
                                if(item.time_completed!==null){
                                    DeliveryComplete = DeliveryComplete + 1;
                                    DriverItem[aDriver].DeliveryMade = DriverItem[aDriver].DeliveryMade + 1;
                                    if(item.time_completed>item.time_expected){
                                        LateDeliveries++;
                                        DriverItem[aDriver].DeliveryLate = DriverItem[aDriver].DeliveryLate + 1;    
                                    }
                                }
                                else{
                                    DeliveryMissed = DeliveryMissed + 1;
                                    DriverItem[aDriver].DeliverMissed = DriverItem[aDriver].DeliverMissed + 1;
                                }
                            })
                        });
                    });
                    Deliveries.Count = DeliveryCount;
                    Deliveries.Made = DeliveryComplete;
                    Deliveries.Missed = DeliveryMissed;
                    Deliveries.Late = LateDeliveries;
                    setANP(tempNum);
                    let GData = [];
                    GData.push(["Description","Count"]);
                    AbnormalityFrequency.map((item,index)=>{
                        if(item.count!==0){
                            GData.push([item.Desc,item.Count]);
                        }
                    });
                    setPD(GData);
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
                        while(tempArr.DeliveryMade===DriverItem[index+1].DeliveryMade){
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
                    setLoad(false);
                    //======================================================================================================================
                });
            });
        });
    },[]);

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

    function SortDriverByScore(){
        let Drivers = DriverArray;
        fetch(process.env.REACT_APP_API_SERVER+"/api/driver-score/all",{
            method: 'POST',
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json'    
            },
            body: JSON.stringify({
                id:localStorage.ID,
                token:localStorage.Token
            }) 
        })
        .then(response=>response.json())
        .then(result=>{
            Drivers.map((item, index)=>{
                let Position = result.findIndex(element=>element.id === item.id);
                Drivers[index].Score = result[Position].score
            });
            Drivers.sort((a,b)=>{
                return b.Score - a.Score;
            });
            setDA(Drivers);
            setDS(false);
            setDS(true);
        });
    } 

    function HandleSort(event){
        if(event.target.name==="Abnor"){
            sortDriversByAb();
            setST("Abnormality Count: ");
            setAS(true);
            setMade(false);
            setMissed(false);
            setLate(false);
            setDS(false);    
        }
        else if(event.target.name==="Made"){
            SortDriverByMade();
            setST("Deliveries Made Count: ");
            setAS(false);
            setMade(true);
            setMissed(false);
            setLate(false);
            setDS(false);
        }
        else if(event.target.name==="Missed"){
            SortDriversByMissed();
            setST("Deliveries Missed Count: ");
            setAS(false);
            setMade(false);
            setMissed(true);
            setLate(false);
            setDS(false);
        }
        else if(event.target.name==="Late"){
            SortDriverByLate();
            setST("Deliveries Late Count: ");
            setAS(false);
            setMade(false);
            setMissed(false);
            setLate(true);
            setDS(false);
        }
        else if(event.target.name==="Score"){
            SortDriverByScore();
            setST("Driver Score :");
            setAS(false);
            setMade(false);
            setMissed(false);
            setLate(false);
            setDS(true);
        }
    }

    function handleClick(event){
        if(event.target.name==="AbnorPieView"){
            setAP(!AbnorPie);
        }
        else if(event.target.name==="SetDeliveryView"){
            setSDC(!SeeDC);
        }
    }

    return(
        <Card>
            <Card.Header>Full Reports: {Time ? "Weekly":"Monthly"}</Card.Header>
            {Loading ? 
                <Card.Body>
                    <Spinner animation="border" role="status">
                        <span className="sr-only">Loading...</span>
                    </Spinner>
                </Card.Body>
            :
            <div>
                <Card.Body>
                    <Row>
                        <Card className="ReportCard">
                            <Card.Header>Abnormalities</Card.Header>
                            <Card.Body>
                                <p><b>Number of Abnormalities: </b>{AbnormalityNumberPresent}</p>
                                <Button onClick={handleClick} name="AbnorPieView">Switch View</Button>
                                <hr className="BorderLine"/>
                                {AbnorPie ?
                                <div>
                                    <Chart
                                        width={600}
                                        height={600}
                                        chartType="PieChart"
                                        loader={<div>Loading Chart</div>}
                                        data={PieData}    
                                    />    
                                </div>:
                                <div>
                                    <p><b>Abnormality Counter</b></p>
                                    {AbnormalityArrayCount.map((item, index)=>
                                        <Row key={index}>
                                            <Col xs={10}><b>Description: </b>{item.Desc}</Col>
                                            <Col xs={2}><b>Count: </b>{item.Count}</Col>
                                            <hr className="SmallerLine"/>
                                        </Row>    
                                    )}
                                </div>
                                }
                            </Card.Body>
                        </Card>
                    </Row> <br />
                    <Row>
                        <Card className="ReportCard">
                            <Card.Header>Deliveries</Card.Header>
                            <Card.Body>
                                <Button onClick={handleClick} name="SetDeliveryView">Switch View</Button>
                                {SeeDC ? <div>
                                    <h5>Deliveries Scheduled : {DeliveryArray.Count}</h5>
                                    <Chart
                                        width={600}
                                        height={600}
                                        chartType="PieChart"
                                        loader={<div>Loading Chart</div>}
                                        data={[["Abnormality Type","Number"],["Deliveries Made",DeliveryArray.Made],["Deliveries Missed",DeliveryArray.Missed],["Deliveries Late",DeliveryArray.Late]]}    
                                    />   
                                </div>:
                                <div>
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
                                </div>
                                }
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
                                    <Col xs={2}>
                                        <Button name="Abnor" onClick={HandleSort}>Abnormality Count</Button>
                                    </Col>
                                    <Col xs={2}>
                                        <Button name="Made" onClick={HandleSort}>Deliveries Made</Button>
                                    </Col>
                                    <Col xs={2}>
                                        <Button name="Missed" onClick={HandleSort}>Deliveries Missed</Button>
                                    </Col>
                                    <Col xs={2}>
                                        <Button name="Late" onClick={HandleSort}>Deliveries Late</Button>
                                    </Col>
                                    <Col xs={2}>
                                        <Button name="Score" onClick={HandleSort}>Driver Score</Button>
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
                                            {DScore ? item.Score:null}
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
                    </Row><br />
                    <Row>
                        <Col xs={11}>
                            <Pattern time={props.Time}/>
                        </Col>
                        
                    </Row>
                </Card.Body>
            </div>
        }
        </Card>
    )
}
export default SendReport;