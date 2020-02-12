package dev.webarata3.hakusan.clean;

public class Area {
    private int areaNo;
    private String areaName;
    private String pdfName;

    public String getAreaName() {
        return areaName;
    }

    public int getAreaNo() {
        return areaNo;
    }

    public void setAreaNo(int areaNo) {
        this.areaNo = areaNo;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getPdfName() {
        return pdfName;
    }

    public void setPdfName(String pdfName) {
        this.pdfName = pdfName;
    }
}
