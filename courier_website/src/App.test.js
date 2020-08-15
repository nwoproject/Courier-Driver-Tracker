import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react';

import App from './App';

describe("App", () =>{
    test("Render Header Component", ()=>{
        render(<App />);
        expect(screen.getByText("Home")).toBeInTheDocument();
        expect(screen.getByText("Account")).toBeInTheDocument();
        expect(screen.getByText("Routes")).toBeInTheDocument();
        expect(screen.getByText("Always On Tracking")).toBeInTheDocument();
    });
    test("Render Footer Component", ()=>{
        render(<App />);
        expect(screen.getByText(/COS 301 in 2020/)).toBeInTheDocument();
        expect(screen.getByText(/Created for Epi-Use in collaboration with the University of Pretoria/)).toBeInTheDocument();
        expect(screen.getByText(/All rights reserved/)).toBeInTheDocument();
    });
    test("Navbar not Functional when not logged in",()=>{
        render(<App />);
        expect(screen.getByText(/Login/i)).toBeInTheDocument();
        fireEvent.click(screen.getByText(/Routes/i));
        expect(screen.queryByText(/Search For Location/i)).toBeNull();
        expect(screen.getByText(/Login/i)).toBeInTheDocument();
    })
});