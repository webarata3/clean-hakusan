import { render, screen } from '@testing-library/react';
import ExternalLink from '../../view/ExternalLink';

describe('snapshot-test tutorial', () => {
  test('リンクの確認', () => {
    render(<ExternalLink calendarUrl='test' />);

    const garbage = screen.getByText('ゴミの出し方');

    expect(garbage).toHaveAttribute('href', 'test');
  });
});
