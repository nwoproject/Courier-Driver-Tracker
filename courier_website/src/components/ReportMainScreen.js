import React, {useState, useEffect} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Dropdown from 'react-bootstrap/Dropdown';
import DropdownButton from 'react-bootstrap/DropdownButton';
import Spinner from 'react-bootstrap/Spinner';

import ReportSelection from './ReportSelection';
import SendReport from './SendReport';

import './style/style.css';

function ReportMainScreen(){
    
    const [DriverID, setDID] = useState("");
    const [MakeRequest, setMR] = useState(false);
    const [SendReportB, setSR] = useState(false);
    const [Time, setT] = useState("week");
    const [DriverList, setDL] = useState();
    const [LoadingList, setLL] = useState(false);
    const [DriverName, setDN] = useState("None");

    useEffect(()=>{
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
            setLL(true);
        });
    },[])

    function handleChange(event){
        setMR(false);
        if(event.target.name==="DriverID"){
            let Index = event.target.id;
            setDID(DriverList[Index].id);
            setDN(DriverList[Index].name + " " + DriverList[Index].surname);
        }
        else if(event.target.name==="SendReport"){
            setSR(!SendReportB);
            setMR(false);
        }
    }

    function SubmitID(event){
        event.preventDefault();
        setMR(true);
        setSR(false);
    }

    function handleDropDown(event){
        setSR(false);
        if(event.target.name==="week"){
            setT("week");
        }
        else if(event.target.name==="month"){
            setT("month");
        }
        else{
            window.alert("How did you get here?");
        }
    }

    return(
        <Card className="OuterCard">
            <Card.Header>Reporting</Card.Header>
            <Card.Body>
                <Form onSubmit={SubmitID}>
                    {LoadingList?
                    <Row>
                            <Col xs={2}>
                                <DropdownButton
                                    key="right"
                                    drop="right"
                                    title="Select Driver">
                                    {DriverList.map((item, index)=>
                                        <Dropdown.Item name="DriverID" id={index} onClick={handleChange} key={index}>{item.name + " " + item.surname}</Dropdown.Item>)}        
                                </DropdownButton>
                            </Col>
                            <Col xd={4}>
                                    <p>Curerently Selected Driver: {DriverName}</p>
                            </Col>
                            <Col xs={2}>
                                <Button type="submit">Search</Button>
                            </Col>
                        <Col xs={2}>
                            <DropdownButton
                                key="down"
                                drop="down"
                                title="Report Period"
                            >
                                <Dropdown.Item name="week" onClick={handleDropDown}>Week</Dropdown.Item>
                                <Dropdown.Item name="month" onClick={handleDropDown}>Month</Dropdown.Item>
                            </DropdownButton>
                        </Col>
                        <Col xs={2}>
                            <Button name="SendReport" onClick={handleChange}>Full Report</Button>
                        </Col>
                    </Row>
                    :
                    <Spinner animation="border" role="status">
                        <span className="sr-only">Loading...</span>
                    </Spinner>
                    }
                </Form><br />
                {MakeRequest ? <ReportSelection DriverID={DriverID} />:null}
                {SendReportB ? <SendReport Time={Time}/> :null}
            </Card.Body>
        </Card>
    )
}

export default ReportMainScreen;