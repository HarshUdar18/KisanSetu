package com.kisansetu.common.storage;

import java.io.InputStream;

public interface StorageService {
    String storeFile(String fileName, InputStream content, String contentType);
    InputStream loadFile(String fileKey);
    boolean deleteFile(String fileKey);
}
