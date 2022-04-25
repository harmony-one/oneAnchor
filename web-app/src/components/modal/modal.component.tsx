import React from "react";
import { resultType } from "components/deposit/deposit.component";
import "./modal.styles.scss";


type modalProps = {
  title: string;
  content: any;
  actions: any;
  setIsOpen: any;
  isProcessing : boolean
  result: resultType;
};

const LoadingIcon = () => {
  return (
    <svg
      className="progress-bar"
      viewBox="0 0 96 96"
      xmlns="<http://www.w3.org/2000/svg>"
      preserveAspectRatio="xMidYMin"
    >
      <circle
        cx="12"
        cy="12"
        r="8"
        strokeWidth="2"
        stroke="#1F5AE2"
        fill="none"
      />
    </svg>
  );
};

const Modal: React.FC<modalProps> = (props: modalProps) => {
  const { title, setIsOpen, result, isProcessing } = props;
  console.log("MODAL",result);
  return (
    <>
      <div className="darkBG" onClick={() => setIsOpen(false)} />

      <div className="centered">
        <div className="modal">
          <div className="modalHeader">
            <h5 className="heading">{title}</h5>
          </div>
          { isProcessing ? (<div className="progress-bar-container">
            <LoadingIcon />
          </div>) : (<div className="modalContent">
            { result.errorMessage ? (result.errorMessage) : (`Transaction completed <br> ${result.transactionHash}`)}
          </div>)}

          <div className="modalActions">
            <div className="actionsContainer">
              <button className="cancelBtn" onClick={() => setIsOpen(false)}>
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Modal;
