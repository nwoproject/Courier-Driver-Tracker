package com.ctrlaltelite.courier_driver_tracker;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class FileManager {
    public FileManager() {

    }

    public Boolean write(String fileName, String locDetails) {
        try {
            String path = "/sdcard/"+fileName+".txt";

            File file = new File(path);

            if (!file.exists()) {
                file.createNewFile();
            }

            FileWriter fw = new FileWriter(file.getAbsoluteFile());
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write(locDetails);
            bw.close();
            return true;
        } catch (IOException e) {
            e.printStrackTrace();
            return false;
        }
    }

    public String read(String fileName){

        BufferedReader br = null;
        String response = null;

        try {

            StringBuffer output = new StringBuffer();
            String fpath = "/sdcard/"+fileName+".txt";

            br = new BufferedReader(new FileReader(fpath));
            String line = "";
            while ((line = br.readLine()) != null) {
                output.append(line +"n");
            }

        } catch (IOException e) {
            e.printStackTrace();
            return null;

        }
        return response;

    }
}

