import Card from './Card';
import { Area } from '../util/Types';

type Props = {
  today: Date,
  area: Area
};

const CardList = ({ today, area }: Props): JSX.Element => {
  return (
    <div className="garbage">
      {area.garbages.map((v, index) =>
        <Card today={today} garbage={v} key={index} />)}
    </div>
  );
};

export default CardList;
