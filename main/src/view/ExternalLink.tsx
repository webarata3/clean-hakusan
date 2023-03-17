type Props = {
  calendarUrl?: string
};

const ExternalLink = ({ calendarUrl }: Props): JSX.Element => {
  return (
    <div className="main__external-link">
      <a href="https://www.city.hakusan.lg.jp/seikatsu/kankyo/1001731/1005551/1007377.html" target="_blank" rel="noreferrer">地域が不明な方</a>
      <a href="https://gb.hn-kouiki.jp/hakusan" target="_blank" rel="noreferrer">ゴミ分別検索</a>
      <a href={calendarUrl} target="_blank" rel="noreferrer">ゴミの出し方</a>
    </div>)
}

export default ExternalLink;
