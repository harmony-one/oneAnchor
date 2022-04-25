import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter } from "react-router-dom";
import { UseWalletProvider } from 'use-wallet';
import { Provider } from 'react-redux';
import store from './redux/store';

import App from './App';
import reportWebVitals from './reportWebVitals';
import './index.scss';

const chainID = process.env.REACT_APP_CHAIN_ID?.split(',').map(el => {
  let n = Number(el);
  return isNaN(n) ? el : n;
});

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <UseWalletProvider autoConnect connectors={{
        injected: {
          chainId: chainID
        }
      }}>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </UseWalletProvider>
    </Provider>
  </React.StrictMode>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
