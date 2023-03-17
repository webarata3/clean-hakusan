import React from 'react';
import SelectArea from './SelectArea';
import ExternalLink from './ExternalLink';
import { Region } from '../util/Types';
type Props = {
  regions: Region[],
  selectedAreaNo: string,
  handleOnChange: (e: React.ChangeEvent<HTMLSelectElement>) => void,
  calendarUrl: string | undefined
};


const MainHeader = ({ regions, selectedAreaNo, handleOnChange, calendarUrl }: Props): JSX.Element => {
  return (
    <section className="main__header">
      <div className="main__alert">白山市公式のアプリではありません。</div>
      <SelectArea regions={regions} selectedAreaNo={selectedAreaNo} handleOnChange={handleOnChange} />
      <ExternalLink calendarUrl={calendarUrl} />
    </section>
  );
};

export default MainHeader;
