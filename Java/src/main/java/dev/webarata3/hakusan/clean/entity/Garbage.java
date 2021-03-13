package dev.webarata3.hakusan.clean.entity;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;

import dev.webarata3.hakusan.clean.GarbageParseException;

public class Garbage {
    private List<String> garbageTitles;
    private List<String> garbageDates;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    public Garbage(int year, Element elm) {
        garbageTitles = new ArrayList<>();
        garbageDates = new ArrayList<>();
        parseGarbageTitle(elm);
        parseGarbageDate(year, elm);
    }

    public void merge(Garbage otherGarbage) {
        if (garbageTitles.isEmpty()) {
            garbageTitles.addAll(otherGarbage.garbageTitles);
        }
        garbageDates.addAll(otherGarbage.garbageDates);
    }

    private void parseGarbageTitle(Element elm) {
        var headings = elm.select(".panel-heading");
        if (headings.size() != 1) throw new GarbageParseException(".panel-headingがない");

        var titles = headings.first().html().split("<br( /)?>");
        var titleList = Arrays.stream(titles).map(v -> v.trim()).collect(Collectors.toList());
        garbageTitles.addAll(titleList);
    }

    private void parseGarbageDate(int year, Element elm) {
        var bodies = elm.select(".panel-body");
        if (bodies.size() != 1) throw new GarbageParseException(".panel-bodyがない");

        var splitBodies = bodies.first().html().split("<br( /)?>");

        garbageTitles.add(splitBodies[0].trim());
        if (splitBodies.length == 1) {
            setBurnDate(year, splitBodies[0].trim());
        } else {
            var doc = Jsoup.parse(splitBodies[1]);

            var spans = doc.select("span");
            Pattern pattern = Pattern.compile("・(\\d+)月(\\d+)日.*");
            for (Element span : spans) {
                garbageDates.add(FORMATTER.format(parseDate(span.text().trim(), year, pattern)));
            }
        }
    }

    private LocalDate parseDate(String dateString, int year, Pattern pattern) {
        Matcher m = pattern.matcher(dateString);
        if (!m.find()) throw new GarbageParseException("日付の形式がおかしい " + dateString);
        int month = Integer.parseInt(m.group(1));
        int day = Integer.parseInt(m.group(2));
        if (month <= 3) {
            year = year + 1;
        }
        return LocalDate.of(year, month, day);
    }

    private static final Map<String, DayOfWeek> DAY_OF_WEEK_STRING_MAP;
    static {
        DAY_OF_WEEK_STRING_MAP = Collections.unmodifiableMap(new HashMap<String, DayOfWeek>() {
            private static final long serialVersionUID = 1L;
            {
                put("日", DayOfWeek.SUNDAY);
                put("月", DayOfWeek.MONDAY);
                put("火", DayOfWeek.TUESDAY);
                put("水", DayOfWeek.WEDNESDAY);
                put("木", DayOfWeek.THURSDAY);
                put("金", DayOfWeek.FRIDAY);
                put("土", DayOfWeek.SATURDAY);
            }
        });
    }

    private void setBurnDate(int year, String youbi) {
        Pattern p = Pattern.compile("【毎週(.)曜日・(.)曜日】");
        Matcher m = p.matcher(youbi);
        if (!m.find()) throw new GarbageParseException("曜日情報がない（" + youbi + "）");

        setOneYearDays(year, DAY_OF_WEEK_STRING_MAP.get(m.group(1)));
        setOneYearDays(year, DAY_OF_WEEK_STRING_MAP.get(m.group(2)));
        Collections.sort(garbageDates);
    }

    private void setOneYearDays(int year, DayOfWeek dayOfWeek) {
        LocalDate startDate = LocalDate.of(year, 4, 1);
        LocalDate lastDate = LocalDate.of(year + 1, 3, 31);

        LocalDate currentDate = startDate.with(TemporalAdjusters.dayOfWeekInMonth(1, dayOfWeek));
        while (true) {
            garbageDates.add(FORMATTER.format(currentDate));
            currentDate = currentDate.plusDays(7);
            if (currentDate.isAfter(lastDate)) break;
        }
    }

    public List<String> getGarbageTitles() {
        return garbageTitles;
    }

    public List<String> getGarbageDates() {
        return garbageDates;
    }
}
