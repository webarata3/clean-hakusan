import Link from 'next/link';

type Props = {
  title: string;
  contents: React.ReactElement;
};

const SubMenu = ({ title, contents }: Props): React.ReactElement => {
  return (
    <div className="border border-slate-400 p-2">
      <div>
        <h2 className="border-b border-slate-900 text-center mb-2">{title}</h2>
        <Link href="/" className="absolute top-1 right-1">
          <svg className="w-6 h-6 text-black hover:text-sky-800">
            <use xlinkHref="/image/xmark.svg#xmark"></use>
          </svg>
        </Link>
      </div>
      <div className="pr-4 h-[70vh] overflow-scroll">{contents}</div>
    </div>
  );
};

export default SubMenu;
