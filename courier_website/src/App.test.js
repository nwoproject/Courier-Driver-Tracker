import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react';

import App from './App';

describe("App", () =>{
    test("Render Header Component", ()=>{
        render(<App />);
        expect(screen.getByText("Account")).toBeInTheDocument();
    });
    test("Render Footer Component", ()=>{
        render(<App />);
        expect(screen.getByText(/COS 301 in 2020/)).toBeInTheDocument();
        expect(screen.getByText(/Created for Epi-Use in collaboration with the University of Pretoria/)).toBeInTheDocument();
        expect(screen.getByText(/All rights reserved/)).toBeInTheDocument();
    });

});