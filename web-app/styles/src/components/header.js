import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import Navigation from "./navigation";
import "./header.scss";

const Header = () => {
  return (
    <header className="header">
      <div className="container">
        <div className="header__logo">
          <div className="header__logo-emblem"></div>
          <div className="header__logo-type"></div>
        </div>
        <Navigation />
        <div className="header__actions">
          <button className="header__actions--theme button">
            <FontAwesomeIcon
              className="icon header__icon"
              icon={["fas", "moon"]}
              size="xs"
            />
          </button>
          <button className="header__actions--wallet button">Connect Wallet</button>
        </div>
      </div>
    </header>
  );
};

export default Header;
