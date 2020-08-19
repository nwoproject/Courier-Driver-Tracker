import React from 'react';
import {render, screen} from '@testing-library/react';

import AlwaysOnTracking from './AlwaysOnTracking';
import Login from './Login';
import Routes from './Routes';
import ManagerDrivers from './ManageDrivers';
import Report from './Report';

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
    });
});

describe("ManageDrivers",()=>{
    test("Render Manage Drivers",()=>{
        render(<ManagerDrivers />);
        expect(screen.getByText(/Driver ID/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Enter Driver ID/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Driver Name/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Driver Surname/)).toBeInTheDocument();
    });
});

describe("Report",()=>{
    test("Render Report",()=>{
        render(<Report />);
        expect(screen.getByText(/Reporting/)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Enter Driver ID/)).toBeInTheDocument();
    });
});