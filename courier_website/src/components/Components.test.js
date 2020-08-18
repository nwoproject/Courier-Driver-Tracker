import React from 'react';
import {render, screen} from '@testing-library/react';

import ManagerAcc from './ManagerAcc';
import CreateManager from './CreateManager';
import CreateDriver from './CreateDriver';
import AddRoutes from './AddRoutes';

describe("ManagerAcc", ()=>{
    test("Render Manager Account",()=>{
        render(<ManagerAcc />);
        expect(screen.getByText(/You Are logged in, Welcome/i)).toBeInTheDocument();
        expect(screen.getByText(/Logout/i)).toBeInTheDocument();
    });
});

describe("CreateManager", ()=>{
    test("Render Create Manager",()=>{
        render(<CreateManager />);
        expect(screen.getByPlaceholderText(/Enter New Manager Email/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText("Password")).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Confirm Password/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/First Name/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Last Name/i)).toBeInTheDocument();
    });
});

describe("CreateDriver", ()=>{
    test("Render Create Driver", ()=>{
        render(<CreateDriver />);
        expect(screen.getByPlaceholderText(/Enter New Driver Email/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/First Name/i)).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/Last Name/i)).toBeInTheDocument();
    })
});
