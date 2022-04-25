import React from "react";
import { NavLink } from "react-router-dom";
import "./navigation.styles.scss";

const Navigation: React.FC = () => {
  return (
    <nav className="navigation">
      <ul className="navigation__list">
        <li>
          <NavLink className="navigation__item" to="/">
            Earn
          </NavLink>
        </li>
        {/* <li>
          <NavLink
            className="navigation__item"
            to="/dashboard"
          >
            Dashboard
          </NavLink>
        </li> */}
      </ul>
    </nav>
  );
};

export default Navigation;
