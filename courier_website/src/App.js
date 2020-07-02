import React from 'react';
import './App.css';
import Main from "./Main";
import Header from "./components/Header";
import Footer from "./components/Footer"

function App() {
  return (
    <div className="MainBack">
      <Header />
      <Main />
      <Footer />
    </div>
  );
}

export default App;
