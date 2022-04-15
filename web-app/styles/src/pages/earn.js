import Interest from "../components/interest";
import Deposit from "../components/deposit";
import Balance from "../components/balance";
import "./earn.scss";

const Earn = () => {
  return (
    <div className="main">
      <Interest title="Interest APY" ratio={19.57} date="April 7 2022" />
      <Deposit title="Your Total Deposit" ratioSmall={0.0} ratioMedium={0.0} />
      <Balance onetotal={0.0} ubtotal={0.0} />
    </div>
  );
};

export default Earn;
