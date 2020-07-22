import React from 'react';
import {BrowserRouter } from "react-router-dom";
import './App.css';
import Main from "./Main";
import Header from "./components/Header";
import Footer from "./components/Footer"

function App() {
  return (
    <div className="MainBack">
      <BrowserRouter>
        <Header />
        <Main />
        <Footer />
      </BrowserRouter>
    </div>
  );
}

export default App;
