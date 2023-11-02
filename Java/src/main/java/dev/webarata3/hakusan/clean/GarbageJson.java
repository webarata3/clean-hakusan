package dev.webarata3.hakusan.clean;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;

import org.jsoup.Jsoup;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import dev.webarata3.hakusan.clean.entity.AreaGarbage;
import dev.webarata3.hakusan.clean.entity.Garbage;

public class GarbageJson {
    public static void main(String[] args) {
        var setting = GarbageSetting.readSetting();

        var inputBasePath = Paths.get("input", "source");
        var outputBasePath = Paths.get("output");

        var areas = new ArrayList<AreaGarbage>();
        for (int areaNo : setting.getAreaNos()) {
            areas.add(makeArea(inputBasePath, outputBasePath, areaNo, setting));
        }

        try {
            var mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
            var json = mapper.writeValueAsString(areas);
            System.out.println(json);
            var outputPath = Paths.get("output", "areas.json");
            Files.writeString(outputPath, json, StandardCharsets.UTF_8, StandardOpenOption.CREATE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static AreaGarbage makeArea(Path inputBasePath, Path outputBasePath, int areaNo, GarbageSetting setting) {
        var fileName = String.format("%02d.html", areaNo);
        List<Garbage> garbages = null;
        for (int year : setting.getYears()) {
            var tempGarbages = parseHtml(year, inputBasePath.resolve(String.valueOf(year)).resolve(fileName));
            if (garbages == null) {
                garbages = tempGarbages;
            } else {
                for (int i = 0; i < garbages.size(); i++) {
                    garbages.get(i).merge(tempGarbages.get(i));
                }
            }
        }
        return new AreaGarbage(areaNo, setting.getAreaName(areaNo), setting.getPdfName(areaNo), garbages);
    }

    private static List<Garbage> parseHtml(int year, Path path) {
        var garbages = new ArrayList<Garbage>();
        try {
            var doc = Jsoup.parse(path.toFile(), "utf-8");
            var elms = doc.select(".panel-success");
            for (var elm : elms) {
                garbages.add(new Garbage(year, elm));
            }
            return garbages;
        } catch (IOException e) {
            throw new GarbageParseException("");
        }
    }
}
