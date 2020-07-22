import React from 'react';
import {render, screen} from '@testing-library/react';

import AlwaysOnTracking from './AlwaysOnTracking';
import Login from './Login';
import Routes from './Routes';
import Home from './Home';

describe("Home", ()=>{
    test("Render MainHome text in Home", ()=>{
        render(<Home />);
        expect(screen.getByText(/Welcome to the Courier Driver Tracker Website/)).toBeInTheDocument();
    })
});

describe("Login", ()=>{
    test("Render Login Form", ()=>{
        render(<Login />);
        expect(screen.getByText(/Login/)).toBeInTheDocument();
        expect(screen.getByText(/Email address/)).toBeInTheDocument();
        expect(screen.getByText(/Password/)).toBeInTheDocument();
        expect(screen.getByRole("button")).toBeInTheDocument();
    });
});

describe("Routes", ()=>{
    test("Render Add Routes Component",()=>{
        render(<Routes />);
        expect(screen.getByText(/Search For Location/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Search/)).toBeInTheDocument();
        expect(screen.getByRole("button")).toBeInTheDocument();
    });
});

describe("AlwaysOnTracking",()=>{
    test("Render TrackingCard",()=>{
        render(<AlwaysOnTracking />);
        expect(screen.getByText(/Always On Tracking/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Enter Driver ID to track/)).toBeInTheDocument();
        expect(screen.getByRole("button")).toBeInTheDocument();
    })
})