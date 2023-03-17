import { render, screen } from '@testing-library/react';
import SelectArea from '../../view/SelectArea';


describe('<SelectArea />', () => {
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
});
