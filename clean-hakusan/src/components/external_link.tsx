type Props = {
  calendarUrl?: string;
};

const ExternalLink = ({ calendarUrl }: Props): JSX.Element => {
  return (
    <div className="text-right w-full">
      <a
        href="https://www.city.hakusan.lg.jp/seikatsu/kankyo/1001731/1005551/1007377.html"
        target="_blank"
        rel="noreferrer"
        className="text-xs text-sky-600 mr-2"
      >
        地域が不明な方
      </a>
      <a
        href="https://gb.hn-kouiki.jp/hakusan"
        target="_blank"
        rel="noreferrer"
        className="text-xs text-sky-600 mr-2"
      >
        ゴミ分別検索
      </a>
      <a href={calendarUrl} target="_blank" rel="noreferrer" className="text-xs text-sky-600">
        ゴミの出し方
      </a>
    </div>
  );
};

export default ExternalLink;
