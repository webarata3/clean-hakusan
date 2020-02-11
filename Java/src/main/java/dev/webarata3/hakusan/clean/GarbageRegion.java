package dev.webarata3.hakusan.clean;

import java.util.List;

public class GarbageRegion {
    private String regionName;
    private List<Area> areas;

    public String getRegionName() {
        return regionName;
    }

    public void setRegionName(String regionName) {
        this.regionName = regionName;
    }

    public List<Area> getAreas() {
        return areas;
    }

    public void setAreas(List<Area> areas) {
        this.areas = areas;
    }
}
