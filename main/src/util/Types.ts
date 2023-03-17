type AreaNo = {
  areaNo: string,
  areaName: string
};

type Region = {
  regionName: string,
  areas: Array<Area>
};

type Area = {
  areaNo: string,
  areaName: string,
  calendarUrl: string,
  garbages: Array<Garbage>
};

type Garbage = {
  garbageTitles: Array<string>,
  garbageDates: Array<string>
};

export type { AreaNo, Region, Area, Garbage };
