import React from 'react';
import { Link } from 'react-router-dom';
import BarsSvg from '../image/bars.svg';
import RotateRightSvg from '../image/rotate-right.svg';

const Header = (): JSX.Element => {
  return (
    <header className="header">
      <Link to="/menu" className="header__button">
        <svg className="header__button-image">
          <use xlinkHref={`${BarsSvg}#bars`}></use>
        </svg>
      </Link>
      <h1 className="header__title">白山市ゴミ収集日程</h1>
      <a href="/" className="heaer__button">
        <svg className="header__button-image">
          <use xlinkHref={`${RotateRightSvg}#rotate-right`}></use>
        </svg>
      </a>
    </header>
  );
};

export default Header;
