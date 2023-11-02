import { Inconsolata } from 'next/font/google';

const inconsolata = Inconsolata({
  weight: ['400'],
  subsets: ['latin'],
});

type Props = {
  title: string;
  url: string;
  contents: string[];
};

const CreditCard = ({ title, url, contents }: Props): React.ReactElement => {
  return (
    <div className="credit__license">
      <h3 className="mb-3 text-center text-xl text-sky-600">
        <a href={url}>{title}</a>
      </h3>
      <div className={`${inconsolata.className} whitespace-pre-wrap`}>
        {contents.map((v, index) => (
          <span key={index}>{`${v}\n`}</span>
        ))}
      </div>
    </div>
  );
};

export default CreditCard;
