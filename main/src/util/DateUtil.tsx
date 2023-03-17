const padStart0 = (value: number, length: number): string =>
  String(value).padStart(length, '0')

const formatDateYyyymmdd = (date: Date): string =>
  `${date.getFullYear()}${padStart0(date.getMonth() + 1, 2)}${padStart0(date.getDate(), 2)}`;

const formatDateJa = (dateString: string | null): string => {
  if (dateString === null) return '';
  const date = parseDateYyyymmdd(dateString);
  return `${date.getMonth() + 1}月${date.getDate()}日(${toDayName(date.getDay())})`;
};

const toDayName = (value: number): string =>
  ['日', '月', '火', '水', '木', '金', '土'][value];

const parseDateYyyymmdd = (dateString: string): Date => {
  const year = parseInt(dateString.substring(0, 4));
  const month = parseInt(dateString.substring(4, 6));
  const date = parseInt(dateString.substring(6, 8));

  return new Date(`${year}-${padStart0(month, 2)}-${padStart0(date, 2)}T00:00:00`);
};

const diffDate = (date1: Date, date2: Date): number =>
  (date1.getTime() - date2.getTime()) / 1000 / 60 / 60 / 24;

export { formatDateJa, formatDateYyyymmdd, parseDateYyyymmdd, diffDate };
