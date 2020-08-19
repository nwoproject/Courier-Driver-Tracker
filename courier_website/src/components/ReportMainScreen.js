import React, {useState} from 'react';
import Card from 'react-bootstrap/Card';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';

import ReportSelection from './ReportSelection';
import SendReport from './SendReport';

import './style/style.css';

function ReportMainScreen(){
    
    const [DriverID, setDID] = useState("");
    const [MakeRequest, setMR] = useState(false);
    const [SendReportB, setSR] = useState(false);

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
                        <Col xs={4}>
                            <Button type="submit">Search</Button>
                        </Col>
                        <Col xs={3}>
                            <Button name="SendReport" onClick={handleChange}>See Full Report</Button>
                        </Col>
                    </Row>
                </Form><br />
                {MakeRequest ? <ReportSelection DriverID={DriverID} />:null}
                {SendReportB ? <SendReport DriverID={DriverID} />:null}
            </Card.Body>
        </Card>
    )
}

export default ReportMainScreen;