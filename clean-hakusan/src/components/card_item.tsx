import React, { useEffect, useState } from 'react';
import { diffDate, formatDateJa, parseDateYyyymmdd } from './date_util';
import { Garbage } from './types';

type Props = {
  today: string;
  garbage: Garbage;
};

const Card = ({ today, garbage }: Props): JSX.Element => {
  const [garbageDate, setGarbageDate] = useState<string | null>(null);
  const [howManyDates, setHowManyDates] = useState(0);

  useEffect(() => {
    const dates = garbage.garbageDates.filter((v) => v >= today);
    if (dates.length === 0) return;
    setGarbageDate(dates[0]);
  }, [today, garbage]);

  useEffect(() => {
    if (garbageDate === null) return;
    const todayDate = parseDateYyyymmdd(today);
    const date = parseDateYyyymmdd(garbageDate);
    setHowManyDates(diffDate(date, todayDate));
  }, [garbageDate]);

  const renderGarbageTitles = () => (
    <React.Fragment>
      {garbage.garbageTitles.map((title, index) => (
        <div key={index}>{title}</div>
      ))}
    </React.Fragment>
  );

  return (
    <div className="flex flex-1 flex-row border border-gray-700 m-1 shadow-[5px_5px_5px_rgba(0,0,0,0.4)]">
      <div className="text-white bg-sky-500 flex-1 text-sm p-1 relative before:content-[''] before:absolute before:inset-y-1/2 before:right-[-25px] before:mt-[-13px] before:border-[13px] before:border-transparent before:border-l-sky-500 z-10">
        {renderGarbageTitles()}
      </div>
      <div className={getDateClassName(howManyDates)}>
        <div className="flex flex-column flex-1 text-4xl text-center items-center justify-center">
          {getDateLabel(howManyDates)}
        </div>
        <div className="bottom-1 right-1 text-right absolute text-xs text-gray-600">
          {formatDateJa(garbageDate)}
        </div>
      </div>
    </div>
  );
};

const getDateClassName = (howManyDays: number): string => {
  const scheduleClass = 'flex flex-column p-1 relative flex-1';
  if (howManyDays === 0) return scheduleClass + ' bg-amber-100 text-red-600';
  if (howManyDays === 1) return scheduleClass + ' text-red-600';
  if (howManyDays === 2) return scheduleClass + ' text-blue-600';
  return scheduleClass;
};

const getDateLabel = (howManyDays: number): string => {
  if (howManyDays === 0) return '今日';
  if (howManyDays === 1) return '明日';
  if (howManyDays === 2) return '明後日';
  return `${howManyDays}日後`;
};

export default Card;
