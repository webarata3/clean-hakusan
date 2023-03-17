import { Region } from '../util/Types';

type Props = {
  regions: Region[],
  selectedAreaNo: string,
  handleOnChange: (e: React.ChangeEvent<HTMLSelectElement>) => void
};

const SelectArea = ({ regions, selectedAreaNo, handleOnChange }: Props): JSX.Element => {
  const renderSelect = (): JSX.Element => {
    return <select className="main__select" id="area" onChange={handleOnChange} value={selectedAreaNo}>
      {regions.map((region, index) => renderRegions(region, index))}
    </select>;
  }

  const renderRegions = (region: Region, index: number): JSX.Element =>
    <optgroup label={region.regionName} key={index}>
      {region.areas.map(area =>
        <option value={area.areaNo} key={area.areaNo}>{area.areaName}</option>)}
    </optgroup>;

  return (
    <div className="area">
      <div className="area__select">
        {renderSelect()}
      </div>
    </div>
  );
};

export default SelectArea;
