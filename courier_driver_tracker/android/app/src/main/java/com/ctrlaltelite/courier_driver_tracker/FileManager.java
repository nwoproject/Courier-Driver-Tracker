package com.ctrlaltelite.courier_driver_tracker;
import com.ctrlaltelite.courier_driver_tracker.location_service.*;

import android.os.Environment;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.IOException;


public class FileManager {

    public void writeToFile(String data) {
        File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        File file = new File(dir,"test.txt");

        try {
            FileOutputStream outputStream = new FileOutputStream(file);
            OutputStreamWriter oWriter = new OutputStreamWriter(outputStream);

            if(!file.exists()){
                file.createNewFile();
            }

            oWriter.append(data);
            oWriter.close();
            outputStream.close();
        }

        catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String readFromFile() {

        StringBuffer stringBuffer = new StringBuffer();
        String aRow = "";
        String aBuffer = "";

        File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        File file = new File(dir,"test.txt");

        if(!file.exists()){
            return ("File does not exist.");
        }

        try {
            FileInputStream inputStream = new FileInputStream(file);
            BufferedReader myReader = new BufferedReader(
                    new InputStreamReader(inputStream)
            );
            while ((aRow = myReader.readLine()) !=null) {
                aBuffer += aRow + "\n";
            }
            myReader.close();
            return aBuffer;
        }
        catch (IOException e){
            e.printStackTrace();
        }
        return ("Trouble reading from file.");
    }
}

