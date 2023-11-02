import { Region } from './types';

type Props = {
  regions: Region[];
  selectedAreaNo: string;
  handleOnChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
};

const SelectArea = ({ regions, selectedAreaNo, handleOnChange }: Props): React.ReactElement => {
  const renderSelect = (): React.ReactElement => {
    return (
      <select
        className="appearance-none border border-slate-400 flex-1 w-full p-2.5 bg-select bg-no-repeat bg-[99%_50%] bg-[length:18px_18px] bg-gray-100"
        id="area"
        onChange={handleOnChange}
        value={selectedAreaNo}
      >
        {regions.map((region, index) => renderRegions(region, index))}
      </select>
    );
  };

  const renderRegions = (region: Region, index: number): React.ReactElement => (
    <optgroup label={region.regionName} key={index}>
      {region.areas.map((area) => (
        <option value={area.areaNo} key={area.areaNo}>
          {area.areaName}
        </option>
      ))}
    </optgroup>
  );

  return (
    <div className="items-center flex-1 flex-column text-sm py-2.5 px-5">
      <div className="flex flex-row items-center w-full">{renderSelect()}</div>
    </div>
  );
};

export default SelectArea;
