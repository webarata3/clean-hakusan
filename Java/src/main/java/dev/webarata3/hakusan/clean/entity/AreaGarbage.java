package dev.webarata3.hakusan.clean.entity;

import java.util.List;

public class AreaGarbage {
    private String areaNo;
    private String areaName;
    private String calendarUrl;
    private List<Garbage> garbages;

    public AreaGarbage(int intAreaNo, String areaName, String calendarUrl, List<Garbage> garbages) {
        this.areaNo = String.format("%02d", intAreaNo);
        this.areaName = areaName;
        this.calendarUrl = calendarUrl;
        this.garbages = garbages;
    }

    public String getAreaNo() {
        return areaNo;
    }

    public void setAreaNo(String areaNo) {
        this.areaNo = areaNo;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getCalendarUrl() {
        return calendarUrl;
    }

    public void setCalendarUrl(String calendarUrl) {
        this.calendarUrl = calendarUrl;
    }

    public List<Garbage> getGarbages() {
        return garbages;
    }

    public void setGarbages(List<Garbage> garbages) {
        this.garbages = garbages;
    }

}
