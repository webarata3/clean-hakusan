package dev.webarata3.hakusan.clean;

public class Area {
    private int areaNo;
    private int webAreaNo;
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

    public int getWebAreaNo() {
        return webAreaNo;
    }

    public void setWebAreaNo(int webAreaNo) {
        this.webAreaNo = webAreaNo;
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
