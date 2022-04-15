import "./balance.scss";

const Balance = (props) => {
  return (
    <div className="balance">
      <div className="balance__row">
        <div className="balance__title">ONE Available</div>
        <div className="balance__total">{props.onetotal.toFixed(2)}</div>
        <div className="balance__converted">= ${props.onetotal.toFixed(2)}</div>
      </div>
      <div className="balance__row">
        <div className="balance__title">ubONE Balance</div>
        <div className="balance__total">{props.ubtotal.toFixed(2)}</div>
      </div>
    </div>
  );
};

export default Balance;
