type Props = {
  handleMenu: () => void;
};

const Header = ({ handleMenu }: Props) => {
  return (
    <header className="flex flex-row flex-nowrap justify-start text-white bg-blue-500 text-2xl p-4">
      <button type="button" className="w-6 h-6 text-white" onClick={handleMenu}>
        <svg className="w-6 h-6 text-white hover:text-sky-800">
          <use xlinkHref="image/bars.svg#bars"></use>
        </svg>
      </button>
      <h1 className="text-xl flex-auto text-center">白山市ゴミ収集日程</h1>
      <a href="/" className="w-6 h-6 text-white">
        <svg className="w-6 h-6 text-white hover:text-sky-800">
          <use xlinkHref="image/rotate-right.svg#rotate-right"></use>
        </svg>
      </a>
    </header>
  );
};

export default Header;
