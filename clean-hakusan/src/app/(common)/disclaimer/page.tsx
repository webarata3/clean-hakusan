import SubMenu from '@/components/sub_menu';

const Page = (): React.ReactElement => {
  return (
    <SubMenu
      title="免責事項"
      contents={
        <div className="text-sm">
          <p>
            当サイトの情報は、慎重に管理・作成しますが、すべての情報が正確・完全であることは保証しません。そのことをご承知の上、利用者の責任において情報を利用してください。当サイトを利用したことによるいかなる損失について、一切保証しません。
          </p>
          <p>
            また、当サイトは白山市役所が作成したものではありません。
            <span className="warning">問い合わせ等を白山市にしないようにお願いします。</span>
          </p>
          <p>
            問い合わせはTwitter（@webarata3）もしくは、webmaster at hakusan.appまでお願いします。
          </p>
        </div>
      }
    />
  );
};

export default Page;
