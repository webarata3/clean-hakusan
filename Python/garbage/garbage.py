from __future__ import annotations
import json
import logging
import logging.config
import bs4
import re
import calendar
import datetime
from typing import Iterable
import urllib.request
import sys


class Config():
    __logger: logging.Logger
    html_dir: str
    json_dir: str
    number_of_file: int
    year: int
    areaCalendars: list()

    def __init__(self, settings_text: str):
        self.__logger = logging.getLogger('garbage')
        settings = json.loads(settings_text)
        self.__load_settings(settings)
        self.__output_log()

    def __load_settings(self, settings: dict) -> None:
        self.html_dir = settings['html_dir']
        self.json_dir = settings['json_dir']
        self.number_of_file = settings['number_of_file']
        self.year = settings['year']
        self.areaCalendars = settings['areaCalendars']

    def __output_log(self) -> None:
        self.__output_all_log(['html_dir', 'json_dir', 'number_of_file'])

    def __output_all_log(self, keys: list[str]) -> None:
        for key in keys:
            self.__output_one_log(key)

    def __output_one_log(self, key: str) -> None:
        self.__logger.info('[settings] {}={}'.format(key, self.__dict__[key]))

    @classmethod
    def get_instance(cls, file_name: str) -> Config:
        __logger = logging.getLogger('garbage')
        __logger.info('[Config] open settings.json')
        with open(file_name) as fp:
            settings_text = fp.read()
            return Config(settings_text)
        raise RuntimeError('何かがおかしいよ')


class Scraping():
    SCRAPING: str = 'SCRAPING'
    __logger: logger.Logger
    config: Config

    def __init__(self, config: Config):
        self.__logger = logging.getLogger('garbage')
        self.config = config

    def conversion_all(self) -> None:
        for i in range(1, self.config.number_of_file + 1):
            self.__conversion(i)

    def __conversion(self, area_number: int) -> None:
        file_name = self.__get_file_name(area_number)
        self.__logger.info('[{}] - read {}'.format(self.SCRAPING, file_name))
        html = self.__read_file(file_name)
        html_to_json = HtmlToJson(config, area_number, html)
        json_str = html_to_json.conversion()

        self.__save_json(area_number, json_str)

    def __get_file_name(self, area_number: int) -> str:
        return self.config.html_dir + '/' + '{:02}'.format(
            area_number) + '.html'

    def __read_file(self, file_name: str) -> str:
        with open(file_name, 'rt') as fp:
            return fp.read()
        raise RuntimeError('何かがおかしいよ')

    def __save_json(self, file_number: int, json_str: str) -> None:
        file_name = '{}/{:02}.json'.format(self.config.json_dir, file_number)
        with open(file_name, 'wt') as fp:
            fp.write(json_str)


class HtmlToJson():
    HTML_TO_JSON: str = 'HTML_TO_JSON'
    __logger: logger.Logger
    __config: Config
    __soup: bs4.BeautifulSoup
    __result_dict: dict
    __area_no: int
    __DAY_OF_WEEK_DICT: dict = {
        '日': calendar.SUNDAY,
        '月': calendar.MONDAY,
        '火': calendar.TUESDAY,
        '水': calendar.WEDNESDAY,
        '木': calendar.THURSDAY,
        '金': calendar.FRIDAY,
        '土': calendar.SATURDAY
    }

    def __init__(self, config: Config, area_no: int, html: str):
        self.__logger = logging.getLogger('garbage')
        self.__config = config
        self.__soup = bs4.BeautifulSoup(html, 'html.parser')
        self.__area_no = area_no
        self.__result_dict = {
            'areaNo': '{:02}'.format(area_no),
            'garbages': []
        }

    def conversion(self) -> str:
        self.__set_areaCalendars()
        self.__set_areaName()
        self.__get_bargages()

        return json.dumps(self.__result_dict, ensure_ascii=False, indent=2)

    def __set_areaCalendars(self) -> None:
        check_area_no = '{:02}'.format(self.__area_no)
        for i in range(0, 23):
            areaCalendar = self.__config.areaCalendars[i]
            if areaCalendar['areaNo'] == check_area_no:
                self.__result_dict['calendarUrl'] = areaCalendar['calendarUrl']
                return

    def __set_areaName(self) -> None:
        areaName_str = self.__get_text_one('.container h4')
        m = re.search('【(.*)】', areaName_str)
        if not m:
            raise RuntimeError('areaNameが見つからない')
        areaName = m.group(1)
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON, 'areaName',
                                               areaName))
        self.__result_dict['areaName'] = areaName

    def __get_bargages(self):
        headings = self.__get_texts('.container .panel-heading')
        bodies = self.__get_texts('.container .panel-body')
        if len(headings) != len(bodies):
            raise RuntimeError('__get_burn: .panel-headingと.panel-bodyの数が違う')
        if len(headings) == 0:
            raise RuntimeError('__get_burn: .panel-headingは最低1つ必要')
        self.__set_burn(headings[0], bodies[0])
        for i in range(1, len(headings)):
            self.__set_other_garbage(headings[i], bodies[i])

    def __set_burn(self, heading: str, body: str) -> None:
        m = re.search('【毎週(.)曜日・(.)曜日】', body)
        if m.lastindex != 2:
            raise RuntimeError('__set_burn: 曜日が2つない')
        day_of_weeks = [m.group(1), m.group(2)]
        garbage_titles = [
            heading, '毎週 {}{}'.format(day_of_weeks[0], day_of_weeks[1])
        ]
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON,
                                               'garbage_titles',
                                               garbage_titles))
        garbage_dates = [date for date in self.__get_burn_dates(day_of_weeks)]
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON,
                                               'garbage_dates', garbage_dates))
        self.__result_dict['garbages'].append({
            'garbageTitles': garbage_titles,
            'garbageDates': garbage_dates
        })

    def __get_burn_dates(self, day_of_weeks: list(str)) -> list(str):
        first_day1 = self.__get_first_day_of_week(day_of_weeks[0])
        first_day2 = self.__get_first_day_of_week(day_of_weeks[1])
        if first_day1 > first_day2:
            (first_day1, first_day2) = (first_day2, first_day1)
        return [date for date in self.__get_all_dates(first_day1, first_day2)]

    def __get_all_dates(self, first_day1: int,
                        first_day2: int) -> Iterable(str):
        gen1 = self.__get_next_week_date(first_day1)
        gen2 = self.__get_next_week_date(first_day2)
        while True:
            try:
                yield next(gen1)
                yield next(gen2)
            except StopIteration:
                break

    def __get_next_week_date(self, first_day: int) -> str:
        first_date = '{}-{:02}-{:02}'.format(self.__config.year, 4, first_day)
        current_date = datetime.datetime.strptime(first_date, '%Y-%m-%d')

        last_date = datetime.datetime(self.__config.year + 1, 3, 31)

        while True:
            yield current_date.strftime('%Y%m%d')
            current_date = current_date + datetime.timedelta(days=7)
            if current_date > last_date:
                break

    def __get_first_day_of_week(self, day_of_week: str) -> int:
        days = [
            x[self.__DAY_OF_WEEK_DICT[day_of_week]]
            for x in calendar.monthcalendar(self.__config.year, 4)
        ]
        return days[0]

    def __set_other_garbage(self, heading: str, body: str) -> None:
        garbage_titles = heading.split('\n')
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON,
                                               'garbage_titles',
                                               garbage_titles))
        garbage_dates = self.__get_garbage_dates(body)
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON,
                                               'garbage_dates', garbage_dates))
        self.__result_dict['garbages'].append({
            'garbageTitles': garbage_titles,
            'garbageDates': garbage_dates
        })

    def __get_garbage_dates(self, body: str) -> list(str):
        dates = re.findall(r'(・\d+月\d+日)', body)
        result_dates = []
        for date in dates:
            m = re.search(r'(\d+)月(\d+)日', date)
            month = int(m.group(1))
            day = int(m.group(2))
            year = self.__config.year if month > 3 else self.__config.year + 1
            result_dates.append('{}{:02}{:02}'.format(year, month, day))
        return result_dates

    def __get_text_one(self, selector: str) -> str:
        text = self.__soup.select(selector)
        if len(text) != 1:
            raise RuntimeError('{}は最低1件でないといけません'.format(selector))
        result_text = text[0].get_text().strip()
        self.__logger.info('[{}] {}={}'.format(self.HTML_TO_JSON, selector,
                                               result_text))
        return result_text

    def __get_texts(self, selector: str) -> list(str):
        texts = self.__soup.select(selector)
        if len(texts) == 0:
            raise RuntimeError('{}は最低1件ないといけません'.format(selector))
        result_texts = []
        for text in texts:
            result_texts.append(text.get_text().strip())
        return result_texts


def download_html():
    logger = logging.getLogger('garbage')

    base_url = 'https://gb.hn-kouiki.jp/towns/pud/0/{}/2019'
    for i in range(1, 24):
        url = base_url.format(i)
        file_name = './html/{:02}.html'.format(i)
        logger.info('[download] {} -> {}'.format(url, file_name))
        urllib.request.urlretrieve(url, file_name)


if __name__ == '__main__':
    logging.config.fileConfig('logging.conf')
    logger = logging.getLogger('garbage')

    if len(sys.argv) != 2:
        print('usage: pipenv run python garbage.py [mode]')
        print('       mode: download or convert')
        sys.exit()

    if sys.argv[1] == 'download':
        download_html()
    else:
        config = Config.get_instance('settings.json')
        scraping = Scraping(config)
        scraping.conversion_all()
