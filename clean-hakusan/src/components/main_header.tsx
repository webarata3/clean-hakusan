import React from 'react';
import ExternalLink from './external_link';
import SelectArea from './select_area';
import { Region } from './types';

type Props = {
  regions: Region[];
  selectedAreaNo: string;
  handleOnChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  calendarUrl: string | undefined;
};

const MainHeader = ({
  regions,
  selectedAreaNo,
  handleOnChange,
  calendarUrl,
}: Props): JSX.Element => {
  return (
    <section>
      <div className="mt-2.5 mb-0 mx-1 text-sm text-red-600 before:content-['※'] before:pr-0.5">
        白山市公式のアプリではありません。
      </div>
      <SelectArea
        regions={regions}
        selectedAreaNo={selectedAreaNo}
        handleOnChange={handleOnChange}
      />
      <ExternalLink calendarUrl={calendarUrl} />
    </section>
  );
};

export default MainHeader;
