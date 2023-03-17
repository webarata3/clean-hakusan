import React from 'react';

type Props = {
  title: string,
  url: string,
  contents: string[]
};

const CreditCard = ({ title, url, contents }: Props): JSX.Element => {

  return (
    <div className="credit__license">
      <h3 className="credit__license-title"><a href={url}>{title}</a></h3>
      <div className="credit__contents">
        {contents.map((v, index) => <span key={index}>{`${v}\n`}</span>)}
      </div>
    </div>
  );
};

export default CreditCard;
