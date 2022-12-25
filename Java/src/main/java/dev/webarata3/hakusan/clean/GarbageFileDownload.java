package dev.webarata3.hakusan.clean;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Optional;

public class GarbageFileDownload {
    /* 最初の%dが地域1〜23 次の%dが年度 */
    private static final String BASE_URL = "https://gb.hn-kouiki.jp/towns/pud/0/%d/%d";

    public static void main(String[] args) {
        var setting = GarbageSetting.readSetting();

        var path = Paths.get("input", "source");
        for (int areaNo : setting.getAreaNos()) {
            for (var year : setting.getYears()) {
                download(path, areaNo, year);
            }
        }
    }

    public static Optional<Path> download(Path saveBasePath, int area, int year) {
        URLConnection conn;
        try {
            conn = new URL(String.format(BASE_URL, area, year)).openConnection();
        } catch (IOException e) {
            e.printStackTrace();
            return Optional.empty();
        }
        try (InputStream is = conn.getInputStream()) {
            var saveDirPath = saveBasePath.resolve(String.valueOf(year));
            Files.createDirectories(saveDirPath);
            var filePath = saveDirPath.resolve(String.format("%02d.html", area));
            Files.copy(is, filePath, StandardCopyOption.REPLACE_EXISTING);
            return Optional.of(filePath);
        } catch (IOException e) {
            e.printStackTrace();
            return Optional.empty();
        }
    }
}
