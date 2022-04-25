import React, { useState, useEffect } from "react";
import { useWallet } from "use-wallet";
import { getTokenBalance, AUST_CONTRACT } from "web3/web3.utils";
import "./balance.styles.scss";

const Balance: React.FC = () => {
  const [austBalance, setAustBalance] = useState("0.00");
  const wallet = useWallet();
  let isSubscribed = React.useRef(true);

  useEffect(()=>{
    
    if (wallet.status === 'connected' && isSubscribed) {
      getTokenBalance(wallet.account,AUST_CONTRACT,setAustBalance);
      isSubscribed.current = false;      
    }

    if (wallet.status !== 'connected') {
      setAustBalance("0.00");
    }

  },[wallet.status, wallet.account, wallet.balance]);

  return (
    <div className="balance">
      <div className="balance__row">
        <div className="balance__title">Total Deposits</div>
        <div className="balance__total">{austBalance} aUST</div>
      </div>
    </div>
  );
};

export default Balance;
