package com.example.demo;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

public class DatabaseAppender extends AppenderBase<ILoggingEvent> {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseAppender.class);

    private String url;
    private String username;
    private String password;

    public void setUrl(String url) {
        this.url = url;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    protected void append(ILoggingEvent event) {
        String sql = "INSERT INTO logs (user_id, action_Type, log_time) VALUES (?, ?, ?)";

        String userIdStr = event.getMDCPropertyMap().get("userId");
        String actionType = event.getMDCPropertyMap().get("actionType");

        // 로거를 사용하여 디버깅 로그 출력
        logger.info("MDC userId: {}", userIdStr);
        logger.info("MDC actionType: {}", actionType);

        if (userIdStr == null || actionType == null) {
            logger.error("MDC values are not set correctly");
            return;
        }

        try (Connection connection = DriverManager.getConnection(url, username, password);
             PreparedStatement stmt = connection.prepareStatement(sql)) {

            String decryptedUserId = CryptoUtils.decryptData(userIdStr, CryptoUtils.aeskey);
            long userId = Long.parseLong(decryptedUserId);

            // 사용자가 존재하는지 확인하는 쿼리 실행
            String userQuery = "SELECT COUNT(*) FROM users WHERE user_id = ?";
            try (PreparedStatement userStmt = connection.prepareStatement(userQuery)) {
                userStmt.setLong(1, userId);
                ResultSet rs = userStmt.executeQuery();
                rs.next();
                int count = rs.getInt(1);
                if (count == 0) {
                    logger.error("User with userId {} does not exist. Skipping log insertion.", userId);
                    return;
                }
            }

            stmt.setLong(1, userId);
            stmt.setString(2, actionType);
            stmt.setTimestamp(3, new java.sql.Timestamp(event.getTimeStamp()));

            stmt.executeUpdate();

            logger.info("Successfully logged to database.");
        } catch (SQLException e) {
            logger.error("Error while logging to database", e);
        } catch (NumberFormatException e) {
            logger.error("Error parsing userId to number", e);
        } catch (Exception e) {
            logger.error("Error decrypting userId", e);
        }
    }


}
