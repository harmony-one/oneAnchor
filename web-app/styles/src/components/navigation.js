import { NavLink } from "react-router-dom";
import "./navigation.scss";

const Navigation = () => {
  return (
    <nav className="navigation">
      <ul className="navigation__list">
        <li>
          <NavLink className="navigation__item" activeclassname="active" to="/">
            Earn
          </NavLink>
        </li>
        <li>
          <NavLink
            className="navigation__item"
            activeclassname="active"
            to="/dashboard"
          >
            Dashboard
          </NavLink>
        </li>
      </ul>
    </nav>
  );
};

export default Navigation;
