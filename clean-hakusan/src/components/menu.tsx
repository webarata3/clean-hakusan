import Link from 'next/link';

type Props = {
  openMenu: boolean;
  handleClose: () => void;
};

const Menu = ({ openMenu, handleClose }: Props): React.ReactElement => {
  return (
    <>
      <div
        className={`fixed top-0 left-0 w-full h-full z-10 bg-black/[0.6] -translate-x-full ${
          openMenu ? 'translate-x-0' : '-translate-x-full'
        }`}
        onClick={handleClose}
      ></div>
      <menu
        className={`fixed top-0 left-0 w-48 h-screen z-30 bg-white -translate-x-full transition-all ${
          openMenu ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex justify-center relative p-4 bg-slate-300">
          <button type="button" onClick={handleClose}>
            <svg className="w-6 h-6 text-black hover:text-sky-800">
              <use xlinkHref="image/xmark.svg#xmark"></use>
            </svg>
          </button>
        </div>
        <ul className="flex flex-col p-1 whitespace-nowrap">
          <li>
            <a
              href="how-to-use/"
              target="_blank"
              className="flex flex-row items-center gap-1 block text-black no-underline p-1
              hover:bg-sky-100"
            >
              <span>使い方</span>
              <svg className="w-4 h-4 text-black">
                <use xlinkHref="/image/open-right-square.svg#open-right-square"></use>
              </svg>
            </a>
          </li>
          <li className="border-t border-solid border-slate-300">
            <Link href="/privacy/" className="block text-black no-underline p-1 hover:bg-sky-100">
              プライバシーポリシー
            </Link>
          </li>
          <li className="border-t border-solid border-slate-300">
            <Link
              href="/disclaimer/"
              className="block text-black no-underline p-1 hover:bg-sky-100"
            >
              免責事項
            </Link>
          </li>
          <li className="border-t border-solid border-slate-300">
            <Link href="/credit/" className="block text-black no-underline p-1 hover:bg-sky-100">
              クレジット
            </Link>
          </li>
        </ul>
      </menu>
    </>
  );
};

export default Menu;
