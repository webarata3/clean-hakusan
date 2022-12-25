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

        var inputBasePath = Paths.get("data", "source");
        var outputBasePath = Paths.get("data", "dest");
        try {
            Path outputPath = Paths.get("output");
            Files.deleteIfExists(outputPath);
            Files.createDirectory(outputPath);
        } catch (IOException e) {
        }
        for (int areaNo : setting.getAreaNos()) {
            makeJson(inputBasePath, outputBasePath, areaNo, setting);
        }
    }

    private static void makeJson(Path inputBasePath, Path outputBasePath, int areaNo, GarbageSetting setting) {
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
        try {
            var mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
            var json = mapper.writeValueAsString(
                    new AreaGarbage(areaNo, setting.getAreaName(areaNo), setting.getPdfName(areaNo), garbages));
            var outputPath = Paths.get("output", String.format("%02d.json", areaNo));
            Files.writeString(outputPath, json, StandardCharsets.UTF_8, StandardOpenOption.CREATE);
        } catch (IOException e) {
            e.printStackTrace();
        }
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
