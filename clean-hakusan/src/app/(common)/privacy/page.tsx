import SubMenu from '@/components/sub_menu';

const Page = (): React.ReactElement => {
  return (
    <SubMenu
      title="プライバシーポリシー"
      contents={
        <div className="text-sm">
          <p>
            当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を使用しています。このGoogleアナリティクスはデータの収集のためにCookieを使用しています。このデータは匿名で収集されており、個人を特定するものではありません。
          </p>
          <p>
            <span>
              この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。この規約に関しての詳細は
            </span>
            <a
              href="https://marketingplatform.google.com/about/analytics/terms/jp/"
              target="_blank"
              rel="noreferrer"
              className="submenu__link"
            >
              Googleアナリティクスサービス利用規約のページ
            </a>
            <span>や</span>
            <a
              href="https://policies.google.com/technologies/ads?hl=ja"
              target="_blank"
              rel="noreferrer"
              className="submenu__link"
            >
              Googleポリシーと規約ページ
            </a>
            <span>をご覧ください。</span>
          </p>
        </div>
      }
    />
  );
};

export default Page;
