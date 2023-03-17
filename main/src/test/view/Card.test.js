import { render, screen } from '@testing-library/react';
import Card from '../../view/Card';

const TITLE_ELMS = '.garbage__title > div';
const HOW_MANY_DAYS_ELM = '.garbage__how-many-days';

const get20221231Date = () => new Date('2022-12-31T00:00:00');

describe('<Card />', () => {
  test('タイトルの確認 1行', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221231', '20230101']
      }} />);

    const elms = container.querySelectorAll(TITLE_ELMS)
    expect(elms.length).toBe(1);
    expect(elms.item(0).textContent).toBe('1行目');
  });

  test('タイトルの確認 2行', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目', '2行目'],
        garbageDates: ['20221231', '20230101']
      }} />);

    const elms = container.querySelectorAll(TITLE_ELMS)
    expect(elms.length).toBe(2);
    expect(elms.item(0).textContent).toBe('1行目');
    expect(elms.item(1).textContent).toBe('2行目');
  });

  test('タイトルの確認 3行', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目', '2行目', '3行目'],
        garbageDates: ['20221231', '20230101']
      }} />);

    const elms = container.querySelectorAll(TITLE_ELMS)
    expect(elms.length).toBe(3);
    expect(elms.item(0).textContent).toBe('1行目');
    expect(elms.item(1).textContent).toBe('2行目');
    expect(elms.item(2).textContent).toBe('3行目');
  });

  test('あと何日の確認 今日 先頭データ', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221231', '20230101']
      }} />);

    const elm = container.querySelector(HOW_MANY_DAYS_ELM)
    expect(elm).not.toBeNull();
    expect(elm.textContent).toBe('今日');

    expect(elm.parentElement).toHaveClass('garbage__today');

    expect(elm.nextSibling.textContent).toBe('12月31日(土)');
  });

  test('あと何日の確認 今日 2番目のデータ', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221230', '20221231', '20230101']
      }} />);

    const elm = container.querySelector(HOW_MANY_DAYS_ELM)
    expect(elm).not.toBeNull();
    expect(elm.textContent).toBe('今日');

    expect(elm.parentElement).toHaveClass('garbage__today');

    expect(elm.nextSibling.textContent).toBe('12月31日(土)');
  });

  test('あと何日の確認 明日 2番目のデータ', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221230', '20230101']
      }} />);

    const elm = container.querySelector(HOW_MANY_DAYS_ELM)
    expect(elm).not.toBeNull();
    expect(elm.textContent).toBe('明日');

    expect(elm.parentElement).toHaveClass('garbage__tomorrow');

    expect(elm.nextSibling.textContent).toBe('1月1日(日)');
  });

  test('あと何日の確認 明後日 2番目のデータ', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221230', '20230102']
      }} />);

    const elm = container.querySelector(HOW_MANY_DAYS_ELM)
    expect(elm).not.toBeNull();
    expect(elm.textContent).toBe('明後日');

    expect(elm.parentElement).toHaveClass('garbage__day-after-tomorrow');

    expect(elm.nextSibling.textContent).toBe('1月2日(月)');
  });

  test('あと何日の確認 3日後 2番目のデータ', () => {
    const today = get20221231Date();

    const { container } = render(<Card today={today}
      garbage={{
        garbageTitles: ['1行目'],
        garbageDates: ['20221230', '20230103']
      }} />);

    const elm = container.querySelector(HOW_MANY_DAYS_ELM)
    expect(elm).not.toBeNull();
    expect(elm.textContent).toBe('3日後');

    expect(elm.nextSibling.textContent).toBe('1月3日(火)');
  });
});
