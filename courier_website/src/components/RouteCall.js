import React, {useState, useEffect} from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Alert from 'react-bootstrap/Alert';
import Spinner from 'react-bootstrap/Spinner';

import LocationCard from './LocationCard';

function RouteCall(props){

    const [AllLocs, setLocs] = useState([]);
    const [BoolDone, setBool] = useState(false);
    const [LocsFound, setLF] = useState(false);
    useEffect(()=>{
        var URLtoSend = "https://drivertracker-api.herokuapp.com/api/google-maps/web?searchQeury="+props.Query
        try{
            fetch(encodeURI(URLtoSend),{
            method: 'GET',
            headers:{
                'authorization': "Bearer "+process.env.REACT_APP_BEARER_TOKEN,
                'Content-Type' : 'application/json' 
            }
            })
            .then(response=>{
                if(response.status!==200){
                    setLF(true);
                    setBool(true);
                }
                else{
                    response.json()
                    .then(result=>{
                        result.candidates.map(CurrentElement=>{
                            let Location = {};
                            let ImgSrc = "";                  
                            try{
                                ImgSrc = CurrentElement.photo;
                            }
                            catch(err){
                                ImgSrc = "../images/404.png";
                            }
                                setBool(false);
                                Location.Name = CurrentElement.name;
                                Location.ForAdd = CurrentElement.formatted_address;
                                Location.IMG = ImgSrc;
                                Location.geo = CurrentElement.geometry.location;
                                setLocs(prevState=>{return ([...prevState, Location])});
                                setBool(true);
                        }); 
                    })
                }
            })
        }
        catch(err){
            window.alert("lolz whoops");
        }
    },[]);

    return(
        <div>
            {BoolDone ? <div>
            {LocsFound ? <div><br /><Alert variant="danger">No Location Found</Alert></div>:
                <Container>
                    <Row>
                        {AllLocs.map((item, index)=> 
                            <LocationCard 
                                key={index}
                                IMGSrc={item.IMG}
                                LocName={item.Name}
                                FormatAdd={item.ForAdd}  
                                Geometry={item.geo}  
                            />
                        )}
                    </Row>
                </Container>}
                </div>
                :
                <div>
                    <br/>
                    <Spinner animation="border" role="status">
                        <span className="sr-only">Loading...</span>
                    </Spinner>
                </div>
                }
        </div>
    )
}

export default RouteCall;