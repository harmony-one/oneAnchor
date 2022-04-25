import React, { useState } from "react";
import { Routes, Route } from "react-router-dom";
import { ToastContainer, toast } from "react-toastify";
import { useSelector } from 'react-redux';
import { RootState } from 'redux/root-reducer';

import Header from './components/header/header.component';
import EarnPage from './pages/earn/earn.component';
import DashboardPage from './pages/dashboard/dashboard.component';
import Footer from './components/footer/footer.component';
import "react-toastify/dist/ReactToastify.css";
import './App.scss';
import { useEffect } from 'react';

function App() {
  const toastMessage = useSelector((state: RootState) => state.toast.toast); 
  const [isActive, setActive] = useState<boolean>(false);

  const updateState = (state: boolean): void => {
    setActive(state);   
  };

  useEffect(()=>{
    if (toastMessage) {
      if (toastMessage.type === 0) {
        toast.error(toastMessage.message);
      }
    }
  },[toastMessage]);

  return (
    <div id="app" className={!isActive ? "light" : "dark"}>
      <Header state={isActive} updateState={updateState} />
      <div className="container">
        <Routes>
          <Route path="/" element={<EarnPage />} />
          <Route path="/dashboard" element={<DashboardPage />} />
        </Routes>
        <ToastContainer autoClose={2000} />
      </div>
      <Footer />
    </div>
  );
}

export default App;
