package dev.webarata3.hakusan.clean;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.ObjectMapper;

public class GarbageSetting {
    private List<Integer> years;
    private String calendarPdfBaseUrl;
    private List<GarbageRegion> regions;

    public static GarbageSetting readSetting() {
        try (var is = GarbageFileDownload.class.getClassLoader().getResourceAsStream("setting.json")) {
            var mapper = new ObjectMapper();
            return mapper.readValue(is, GarbageSetting.class);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public String getAreaName(int areaNo) {
        List<String> areaNames = regions
                .stream()
                .flatMap(v -> v.getAreas().stream())
                .filter(v -> v.getAreaNo() == areaNo)
                .map(v -> v.getAreaName())
                .collect(Collectors.toList());
        return areaNames.get(0);
    }

    public String getPdfName(int areaNo) {
        List<String> pdfNames = regions
                .stream()
                .flatMap(v -> v.getAreas().stream())
                .filter(v -> v.getAreaNo() == areaNo)
                .map(v -> v.getPdfName())
                .collect(Collectors.toList());
        return String.format("%s/%s", calendarPdfBaseUrl, pdfNames.get(0));
    }

    public List<Integer> getAreaNos() {
        return regions
                .stream()
                .flatMap(v -> v.getAreas().stream())
                .map(v -> v.getAreaNo())
                .collect(Collectors.toList());
    }

    public List<Integer> getYears() {
        return years;
    }

    public String getCalendarPdfBaseUrl() {
        return calendarPdfBaseUrl;
    }

    public void setYears(List<Integer> years) {
        this.years = years;
    }

    public List<GarbageRegion> getRegions() {
        return regions;
    }

    public void setRegions(List<GarbageRegion> regions) {
        this.regions = regions;
    }
}
