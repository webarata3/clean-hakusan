import Xmark from '../image/xmark.svg';
import { useLocation, Location, Link } from 'react-router-dom';

const Privacy = (): JSX.Element => {
  const location = useLocation();

  return (
    <div className={`submenu ${isOpen(location) ? 'submenu__open' : 'submenu__close'}`}>
      <div className="submenu__window">
        <div className="submenu__window-header">
          <h2 className="submenu__window-title">プライバシーポリシー</h2>
          <Link to="/menu" className="submenu__window-close">
            <svg className="submenu__close-button">
              <use xlinkHref={`${Xmark}#xmark`}></use>
            </svg>
          </Link>
        </div>
        <div className="text">
          <p>当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を使用しています。このGoogleアナリティクスはデータの収集のためにCookieを使用しています。このデータは匿名で収集されており、個人を特定するものではありません。</p>
          <p><span>この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。この規約に関しての詳細は</span><a href="https://marketingplatform.google.com/about/analytics/terms/jp/"
            target="_blank" rel="noreferrer" className="submenu__link"
          >Googleアナリティクスサービス利用規約のページ</a><span>や</span><a
            href="https://policies.google.com/technologies/ads?hl=ja"
            target="_blank" rel="noreferrer" className="submenu__link"
          >Googleポリシーと規約ページ</a><span>をご覧ください。</span></p>
        </div>
      </div>
    </div>
  );
};

const isOpen = (location: Location): boolean => {
  return location.pathname === '/privacy';
};

export default Privacy;
