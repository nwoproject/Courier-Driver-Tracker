import React, {useState} from 'react';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';

function ScreenOverlay(props){

    function Refresh(){
        window.location.reload(false);
    }

    return(
        <Modal show={true}>
            <Modal.Header>
                <Modal.Title>{props.title}</Modal.Title>
            </Modal.Header>
            <Modal.Body>{props.message}</Modal.Body>
            <Modal.Footer>
                <Button onClick={Refresh}>Confirm</Button>
            </Modal.Footer>
        </Modal>
    );
}

export default ScreenOverlay;