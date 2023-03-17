import { formatDateJa, formatDateYyyymmdd, parseDateYyyymmdd, diffDate } from '../../util/DateUtil';

describe('DateUtil', () => {
  test('parseDateYyyymmdd', () => {
    const date = parseDateYyyymmdd('20221231');

    expect(date.getFullYear()).toBe(2022);
    expect(date.getMonth()).toBe(11);
    expect(date.getDate()).toBe(31);
  });

  test('formatDateYyyymmdd', () => {
    const date = new Date('2022-12-31T13:14:15');
    const dateString = formatDateYyyymmdd(date);

    expect(dateString).toBe('20221231');
  });

  test('formatDateJa 日曜日', () => {
    const dateString = formatDateJa('20230101');

    expect(dateString).toBe('1月1日(日)');
  });

  test('formatDateJa 月曜日', () => {
    const dateString = formatDateJa('20230102');

    expect(dateString).toBe('1月2日(月)');
  });

  test('formatDateJa 火曜日', () => {
    const dateString = formatDateJa('20230103');

    expect(dateString).toBe('1月3日(火)');
  });

  test('formatDateJa 水曜日', () => {
    const dateString = formatDateJa('20230104');

    expect(dateString).toBe('1月4日(水)');
  });

  test('formatDateJa 木曜日', () => {
    const dateString = formatDateJa('20221229');

    expect(dateString).toBe('12月29日(木)');
  });

  test('formatDateJa 金曜日', () => {
    const dateString = formatDateJa('20221230');

    expect(dateString).toBe('12月30日(金)');
  });

  test('formatDateJa 土曜日', () => {
    const dateString = formatDateJa('20221231');

    expect(dateString).toBe('12月31日(土)');
  });

  test('diffDate 0日', () => {
    const date1 = new Date('2022-12-31T00:00:00');
    const date2 = new Date('2022-12-31T00:00:00');

    const diff = diffDate(date1, date2);
    expect(diff).toBe(0);
  });

  test('diffDate 1日', () => {
    const date1 = new Date('2023-01-01T00:00:00');
    const date2 = new Date('2022-12-31T00:00:00');

    const diff = diffDate(date1, date2);
    expect(diff).toBe(1);
  });

  test('diffDate 2日', () => {
    const date1 = new Date('2023-01-02T00:00:00');
    const date2 = new Date('2022-12-31T00:00:00');

    const diff = diffDate(date1, date2);
    expect(diff).toBe(2);
  });
});
