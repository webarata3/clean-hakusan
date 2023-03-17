import Xmark from '../image/xmark.svg';
import { useLocation, Location, Link } from 'react-router-dom';

const Disclaimer = (): JSX.Element => {
  const location = useLocation();

  return (
    <div className={`submenu ${isOpen(location) ? 'submenu__open' : 'submenu__close'}`}>
      <div className="submenu__window">
        <div className="submenu__window-header">
          <h2 className="submenu__window-title">免責事項</h2>
          <Link to="/menu" className="submenu__window-close">
            <svg className="submenu__close-button">
              <use xlinkHref={`${Xmark}#xmark`}></use>
            </svg>
          </Link>
        </div>
        <div className="text"><p>当サイトの情報は、慎重に管理・作成しますが、すべての情報が正確・完全であることは保証しません。そのことをご承知の上、利用者の責任において情報を利用してください。当サイトを利用したことによるいかなる損失について、一切保証しません。</p><p>また、当サイトは白山市役所が作成したものではありません。<span className="warning">問い合わせ等を白山市にしないようにお願いします。</span></p><p>問い合わせはTwitter（@webarata3）もしくは、webmaster at hakusan.appまでお願いします。</p></div>
      </div>
    </div>
  );
};

const isOpen = (location: Location): boolean => {
  return location.pathname === '/disclaimer';
};

export default Disclaimer;
