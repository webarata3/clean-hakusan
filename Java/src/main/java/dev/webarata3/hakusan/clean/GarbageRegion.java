package dev.webarata3.hakusan.clean;

import java.util.List;

public class GarbageRegion {
    private String regionName;
    private List<GarbageArea> areas;

    public String getRegionName() {
        return regionName;
    }

    public void setRegionName(String regionName) {
        this.regionName = regionName;
    }

    public List<GarbageArea> getAreas() {
        return areas;
    }

    public void setAreas(List<GarbageArea> areas) {
        this.areas = areas;
    }
}
