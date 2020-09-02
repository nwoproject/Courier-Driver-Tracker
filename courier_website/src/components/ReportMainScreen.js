import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Dropdown from 'react-bootstrap/Dropdown';
import DropdownButton from 'react-bootstrap/DropdownButton';

import ReportSelection from './ReportSelection';
import SendReport from './SendReport';

import './style/style.css';

function ReportMainScreen(){
    
    const [DriverID, setDID] = useState("");
    const [MakeRequest, setMR] = useState(false);
    const [SendReportB, setSR] = useState(false);
    const [Time, setT] = useState("week");

    function handleChange(event){
        setMR(false);
        if(event.target.name==="DriverID"){
            setDID(event.target.value);
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
                    <Row>
                        <Col xs={5}>
                            <Form.Control 
                            name="DriverID"
                            placeholder="Enter Driver ID"
                            onChange={handleChange}   
                            />
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
                </Form><br />
                {MakeRequest ? <ReportSelection DriverID={DriverID} />:null}
                {SendReportB ? <SendReport Time={Time}/> :null}
            </Card.Body>
        </Card>
    )
}

export default ReportMainScreen;