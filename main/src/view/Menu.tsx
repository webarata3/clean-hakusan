import React from 'react';
import Xmark from '../image/xmark.svg';
import { useLocation, useNavigate, Location, Link, NavigateFunction } from 'react-router-dom';
import Privacy from './Privacy';
import Disclaimer from './Disclaimer';
import Credit from './Credit';

const Menu = (): JSX.Element => {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <>
      <div className={`menu__background ${isOpen(location) ? 'menu__open' : 'menu__close'}${isSubMenuOpen(location) ? ' submenu__open' : ''}`}
        onClick={() => onClickBackground(location, navigate)}></div>
      <menu className={`${isOpen(location) ? 'menu__open' : 'menu__close'}`}>
        <div className="submenu__header">
          <Link to="/">
            <svg className="submenu__close-button">
              <use xlinkHref={`${Xmark}#xmark`}></use>
            </svg>
          </Link>
        </div>
        <ul>
          <li>
            <a href="how-to-use/" target="_blank" className="submenu__link-title">
              <span>使い方</span>
              <img src="image/external-link-alt-solid.svg" className="submenu__external-link-image" alt="" />
            </a>
          </li>
          <li>
            <Link to="/privacy" className="submenu__link-title">プライバシーポリシー</Link>
          </li>
          <li>
            <Link to="/disclaimer" className="submenu__link-title">免責事項</Link>
          </li>
          <li>
            <Link to="/credit" className="submenu__link-title">クレジット</Link>
          </li>
        </ul>
      </menu>
      <Privacy />
      <Disclaimer />
      <Credit />
    </>
  );
};

const isOpen = (location: Location): boolean => {
  return location.pathname === '/menu'
    || location.pathname === '/privacy'
    || location.pathname === '/disclaimer'
    || location.pathname === '/credit';
};

const isSubMenuOpen = (location: Location): boolean => {
  return location.pathname === '/privacy'
    || location.pathname === '/disclaimer'
    || location.pathname === '/credit';
};

const onClickBackground = (location: Location, navigate: NavigateFunction) => {
  if (isSubMenuOpen(location)) {
    navigate('/menu');
  } else {
    navigate('/');
  }
};

export default Menu;
