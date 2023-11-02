import Card from './card_item';
import { Area } from './types';

type Props = {
  today: string;
  area: Area;
};

const CardList = ({ today, area }: Props): React.ReactElement => {
  return (
    <div className="grow grid grid-rows-4 auto-rows-fr">
      {area.garbages.map((v, index) => (
        <Card today={today} garbage={v} key={index} />
      ))}
    </div>
  );
};

export default CardList;
