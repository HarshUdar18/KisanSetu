package com.kisansetu.common.storage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class LocalStorageService implements StorageService {

    private static final Logger log = LoggerFactory.getLogger(LocalStorageService.class);
    private final Map<String, byte[]> localDiskMock = new ConcurrentHashMap<>();

    @Override
    public String storeFile(String fileName, InputStream content, String contentType) {
        String fileKey = "uploads/" + UUID.randomUUID() + "_" + fileName;
        try {
            byte[] bytes = content.readAllBytes();
            localDiskMock.put(fileKey, bytes);
            log.info("LOCAL STORAGE: Stored file '{}' with size {} bytes (contentType: {})", fileKey, bytes.length, contentType);
            return "/api/v1/files/" + fileKey;
        } catch (Exception e) {
            log.error("Failed to store file: {}", e.getMessage());
            throw new RuntimeException("Storage failure", e);
        }
    }

    @Override
    public InputStream loadFile(String fileKey) {
        byte[] bytes = localDiskMock.get(fileKey);
        if (bytes == null) {
            return null;
        }
        return new ByteArrayInputStream(bytes);
    }

    @Override
    public boolean deleteFile(String fileKey) {
        return localDiskMock.remove(fileKey) != null;
    }
}
