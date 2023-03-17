import React from 'react';
import { Link } from 'react-router-dom';
import BarsSvg from '../image/bars.svg';
import RotateRightSvg from '../image/rotate-right.svg';
import Twitter from '../image/twitter.svg';

const Footer = (): JSX.Element => {
  return (
    <footer className="footer">
      <small>©2023 webarata3（ARATA Shinichi）</small>
      <a href="https://twitter.com/webarata3" target="_blank"
        className="footer__link"><img src={Twitter} /></a>
    </footer>
  );
};

export default Footer;
