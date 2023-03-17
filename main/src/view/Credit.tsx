import Xmark from '../image/xmark.svg';
import { useLocation, Location, Link } from 'react-router-dom';
import CreditCard from './CreditCard';

const LICENSES = [
  {
    title: 'React',
    url: 'https://reactjs.org/',
    contents: [
      'MIT License',
      '',
      'Copyright (c) Meta Platforms, Inc. and affiliates.',
      '',
      'Permission is hereby granted, free of charge, to any person obtaining a copy',
      'of this software and associated documentation files (the "Software"), to deal',
      'in the Software without restriction, including without limitation the rights',
      'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell',
      'copies of the Software, and to permit persons to whom the Software is',
      'furnished to do so, subject to the following conditions:',
      '',
      'The above copyright notice and this permission notice shall be included in all',
      'copies or substantial portions of the Software.',
      '',
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
      'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
      'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE',
      'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER',
      'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,',
      'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE',
      'SOFTWARE.'
    ]
  },
  {
    title: 'Font Awesome Free',
    url: 'https://fontawesome.com/license/free',
    contents: ['Icons - CC BY 4.0 License']
  }
];

const Credit = (): JSX.Element => {
  const location = useLocation();

  return (
    <div className={`submenu ${isOpen(location) ? 'submenu__open' : 'submenu__close'}`}>
      <div className="submenu__window">
        <div className="submenu__window-header">
          <h2 className="submenu__window-title">クレジット</h2>
          <Link to="/menu" className="submenu__window-close">
            <svg className="submenu__close-button">
              <use xlinkHref={`${Xmark}#xmark`}></use>
            </svg>
          </Link>
        </div>
        <div className="window__content">
          {LICENSES.map((v, index) =>
            <CreditCard title={v.title} url={v.url} contents={v.contents} key={index} />)}
        </div>
      </div>
    </div>
  );
};

const isOpen = (location: Location): boolean => {
  return location.pathname === '/credit';
};

export default Credit;
