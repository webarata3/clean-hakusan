package dev.webarata3.hakusan.clean;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.ObjectMapper;

public class GarbageSetting {
    private List<Integer> years;
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
