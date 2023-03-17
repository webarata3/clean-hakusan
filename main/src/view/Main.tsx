import React, { useState, useEffect } from 'react';
import MainHeader from './MainHeader';
import { Region, Area } from '../util/Types';
import CardList from './CardList';

const Main = (): JSX.Element => {
  const [localVersionNo, setLocalVersionNo] = useState(localStorage.getItem('versionNo'));
  const [versionNo, setVersionNo] = useState<string | null>(null);
  const [regions, setRegions] = useState<Region[]>([]);
  const [areas, setAreas] = useState<Area[]>([]);
  const [selectedAreaNo, setSelectedAreaNo] = useState(localStorage.getItem('areaNo') ?? '01');
  const [selectedArea, setSelectedArea] = useState<Area | null>(null);
  const [calendarUrl, setCalendarUrl] = useState<string | undefined>(undefined);
  const [today, setToday] = useState<Date | null>(null);

  // 30秒ごとに日付確認
  const getToday = () => {
    const now = new Date();
    setTimeout(getToday, 30000);

    // 日付だけ比較
    if (now.getDate() === today?.getDate()) return;
    setToday(new Date(now.getFullYear(), now.getMonth(), now.getDate()));
  };

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    setArea(e.target.value);
  };

  const setArea = (areaNo: string) => {
    setSelectedAreaNo(areaNo);
    localStorage.setItem('areaNo', areaNo);
  };

  const fetchData = () => {
    readRegions(setRegions);
    readAreas(setAreas);
  };

  useEffect(() => {
    if (versionNo === null) return;
    if (localVersionNo === versionNo) {
      if (regions.length === 0 || areas.length === 0) {
        const areaNo = localStorage.getItem('areaNo') ?? '01';
        setSelectedAreaNo(areaNo);
        const regionsString = localStorage.getItem('regions');
        const areasString = localStorage.getItem('areas');
        // もしデータがなければ再度読み込む
        if (regionsString === null || areasString === null) {
          fetchData();
          return;
        }
        setRegions(JSON.parse(regionsString));
        setAreas(JSON.parse(areasString));
      }
      return;
    }
    // バージョンが変更されたとき
    localStorage.setItem('versinNo', versionNo);
    setLocalVersionNo(versionNo);
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [versionNo]);

  useEffect(() => {
    if (regions.length === 0 || areas.length === 0) return;
    localStorage.setItem('regions', JSON.stringify(regions));
    localStorage.setItem('areas', JSON.stringify(areas));
  }, [regions, areas]);

  getToday();

  useEffect(() => {
    const foundAreas = areas.filter(v => v.areaNo === selectedAreaNo);
    if (foundAreas.length === 0) return;
    setSelectedArea(foundAreas[0]);
    setCalendarUrl(foundAreas[0].calendarUrl);
  }, [areas, selectedAreaNo]);

  readVersion(setVersionNo);

  return (
    <>
      <MainHeader regions={regions} selectedAreaNo={selectedAreaNo} handleOnChange={handleChange}
        calendarUrl={calendarUrl} />
      {today === null || selectedArea === null ? <div></div>
        : <CardList today={today} area={selectedArea} />
      }
    </>
  );
};

const asyncFetchGet = <T,>(url: string,
  successCallback: (json: T) => void,
  failureCallback: (error: Error) => void) => {
  fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    }
  }).then(response => response.json())
    .then(data => successCallback(data))
    .catch(error => failureCallback(error));
};

const readVersion = (setVersionNo: React.Dispatch<React.SetStateAction<string | null>>) => {
  asyncFetchGet<{ apiVersion: string }>('/api/version.json', json => {
    setVersionNo(json.apiVersion);
  }, e => {
    console.log(e);
  });
};

const readRegions = (setRegions: React.Dispatch<React.SetStateAction<Region[]>>) => {
  asyncFetchGet<Array<Region>>('/api/regions.json', json => {
    setRegions(json);
  }, e => {
    console.log(e);
  });
};

const readAreas = (setAreas: React.Dispatch<React.SetStateAction<Area[]>>) => {
  asyncFetchGet<Array<Area>>('/api/areas.json', json => {
    setAreas(json);
  }, e => {
    console.log(e);
  });
};

export default Main;
