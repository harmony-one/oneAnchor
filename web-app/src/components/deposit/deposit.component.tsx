import React, { useState } from "react";
import { useWallet } from "use-wallet";
import { incomeDeposit } from "web3/web3.utils";
import Modal from "components/modal/modal.component";
import "./deposit.styles.scss";

export type resultType = {
  status?: boolean;
  transactionHash?: string,
  blockHash?: string,
  errorMessage: string
}

const Deposit: React.FC= () => {
  const [amount, setAmount] = useState('');
  const [validationError, setValidationError] = useState('');
  const [buttonDisable, setButtonDisable] = useState(false);
  const [openModal, setOpenModal] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [result, setResult] = useState<resultType>({
    status: true,
    transactionHash: "",
    blockHash: "",
    errorMessage : ""
  });
  const wallet = useWallet();

  const handleDeposit = async () => {
    setValidationError('');
    setResult({
      status: true,
      transactionHash: "",
      blockHash: "",
      errorMessage: ""
    });
    try {
      if (wallet.isConnected()) {
        if (amount) {
          setIsProcessing(true);
          setButtonDisable(true);
          setOpenModal(true);          
          setResult(await incomeDeposit(wallet,amount,setValidationError));
          setButtonDisable(false);  
          setIsProcessing(false);
        } else {
          setValidationError('Please enter the Amount');
        }
      }
    } catch(e:any) {
      console.log(e);
      setIsProcessing(false);
      setButtonDisable(false);
      setResult({
        status: false,
        errorMessage: "Unable to complete transaction"
      }); 
      setValidationError('');
      setAmount('');
    }
  }
  
  const handleWithdraw = async () => {
    setValidationError('');
    try {
      if (wallet.isConnected()) {
        if (amount) {
          setButtonDisable(true)
          await incomeDeposit(wallet,amount,setValidationError);
          setButtonDisable(false);  
        } else {
          setValidationError('Please enter the Amount');
        }
      }
    } catch(e) {
      setButtonDisable(false);  
      console.log("catched",e);
      setValidationError('');
      setAmount('');
    }
  }

  return (
    <div className="deposit">
      <div className="deposit__title">Enter Amount</div>
      <p></p>
      <input
        className="deposit__input"
        type="number"
        step="1"
        placeholder="0"
        value={amount}
        onChange={e => setAmount(e.target.value)}    
      ></input>
      <span className="deposit__total--warning">{validationError}</span>
      { openModal ? (<Modal title="Processing Transaction" content={null} actions={null} 
        result={result} isProcessing={isProcessing}
        setIsOpen={setOpenModal}  />) :
      (<div className="deposit__cta">
        <button className="deposit__button button" onClick={handleDeposit} disabled={buttonDisable}>Deposit</button>
        <button className="deposit__button button" onClick={handleWithdraw} disabled={buttonDisable}>Withdraw</button>
      </div>)}
    </div>
  );
};

export default Deposit;