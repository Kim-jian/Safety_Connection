package com.example.demo;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.IvParameterSpec;
import java.util.Base64;

public class CryptoUtils {

    public static final String aeskey = "";

    private static final String AES = "AES";
    private static final String AES_CBC_PKCS5_PADDING = "AES/CBC/PKCS5PADDING";
    private static final String UTF_8 = "UTF-8";

    public static String encryptData(String data, String key) throws Exception {
        IvParameterSpec iv = new IvParameterSpec("".getBytes(UTF_8)); // Fixed 16 bytes IV for AES
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(UTF_8), AES);

        Cipher cipher = Cipher.getInstance(AES_CBC_PKCS5_PADDING);
        cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, iv);

        byte[] encrypted = cipher.doFinal(data.getBytes(UTF_8));
        return Base64.getUrlEncoder().encodeToString(encrypted);
    }

    public static String decryptData(String encryptedData, String key) throws Exception {
        IvParameterSpec iv = new IvParameterSpec("".getBytes(UTF_8)); // Fixed 16 bytes IV for AES
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(UTF_8), AES);

        Cipher cipher = Cipher.getInstance(AES_CBC_PKCS5_PADDING);
        cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, iv);

        byte[] decodedEncryptedData = Base64.getUrlDecoder().decode(encryptedData);
        byte[] original = cipher.doFinal(decodedEncryptedData);
        return new String(original, UTF_8);
    }
}
