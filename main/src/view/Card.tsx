import React, { useState, useEffect } from 'react';
import { formatDateJa, formatDateYyyymmdd, parseDateYyyymmdd, diffDate } from '../util/DateUtil';
import { Garbage } from '../util/Types';

type Props = {
  today: Date,
  garbage: Garbage
};

const Card = ({ today, garbage }: Props): JSX.Element => {
  const [garbageDate, setGarbageDate] = useState<string | null>(null);
  const [howManyDates, setHowManyDates] = useState(0);

  useEffect(() => {
    const todayString = formatDateYyyymmdd(today);
    const dates = garbage.garbageDates.filter(v => v >= todayString);
    if (dates.length === 0) return;
    setGarbageDate(dates[0]);
  }, [today, garbage]);

  useEffect(() => {
    if (garbageDate === null) return;
    const date = parseDateYyyymmdd(garbageDate);
    setHowManyDates(diffDate(date, today));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [garbageDate]);

  const renderGarbageTitles = () =>
    <React.Fragment>
      {garbage.garbageTitles.map((title, index) =>
        <div key={index}>{title}</div>)}
    </React.Fragment>

  return (
    <div className="garbage__item">
      <div className="garbage__title">
        {renderGarbageTitles()}
      </div>
      <div className={getDateClassName(howManyDates)}>
        <div className="garbage__how-many-days">{getDateLabel(howManyDates)}</div>
        <div className="garbage__next-date">{formatDateJa(garbageDate)}</div>
      </div>
    </div>
  );
};

const getDateClassName = (howManyDays: number): string => {
  if (howManyDays === 0) return 'garbage__schedule garbage__today';
  if (howManyDays === 1) return 'garbage__schedule garbage__tomorrow';
  if (howManyDays === 2) return 'garbage__schedule garbage__day-after-tomorrow';
  return 'garbage__schedule';

};

const getDateLabel = (howManyDays: number): string => {
  if (howManyDays === 0) return '今日';
  if (howManyDays === 1) return '明日';
  if (howManyDays === 2) return '明後日';
  return `${howManyDays}日後`;
};

export default Card;
