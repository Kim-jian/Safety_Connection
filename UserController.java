package com.example.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;


import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;



@RestController
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequestMapping("/users")
public class UserController {


    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserRepository userRepository;





    @GetMapping("/{name}/{password}")
    public ResponseEntity<?> getLoginInfo(@PathVariable String name, @PathVariable String password) {
        MDC.put("userName", name);
        MDC.put("actionType", "GET");
        logger.info("LOGIN 요청 수신: userName = {}", name);

        try {
            String decryptedUserName = CryptoUtils.decryptData(name, CryptoUtils.aeskey);
            String decryptedPassword = CryptoUtils.decryptData(password,CryptoUtils.aeskey);
            Optional<Users> user = Optional.ofNullable(userRepository.findByNameAndPassword(decryptedUserName,decryptedPassword));
            if (user.isPresent()) {
                long userId = user.get().getUserId();
                String encryptedUserName = CryptoUtils.encryptData(String.valueOf(userId), CryptoUtils.aeskey);
                logger.info("사용자 조회 성공: userId = {}", userId);
                return ResponseEntity.ok().body(userId);
            } else {
                logger.warn("사용자를 찾을 수 없음. user Name = {}, password = {}",decryptedUserName, decryptedPassword);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("GET 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }
    @GetMapping("/{userId}")
    public ResponseEntity<?> getById(@PathVariable String userId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "GET");
        logger.info("GET 요청 수신: userId = {}", userId);

        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            long trueUserId = Long.parseLong(decryptedUserId);
            Optional<Users> user = Optional.ofNullable(userRepository.findById(trueUserId));
            if (user.isPresent()) {
                String userName = user.get().getName();
                String encryptedUserName = CryptoUtils.encryptData(userName, CryptoUtils.aeskey);
                logger.info("사용자 조회 성공: userName = {}", userName);
                return ResponseEntity.ok().body(encryptedUserName);
            } else {
                logger.warn("사용자를 찾을 수 없음: userId = {}", userId);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("GET 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }


    @GetMapping("/{userId}/location")
    public ResponseEntity<?> getLocationById(@PathVariable String userId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "L_GET");
        logger.info("L_GET 요청 수신: userId = {}", userId);
        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            long trueUserId = Long.parseLong(decryptedUserId);
            Optional<Users> user = Optional.ofNullable(userRepository.findById(trueUserId));
            if (user.isPresent()) {
                String userName = user.get().getName();
                String encryptedUserName = CryptoUtils.encryptData(userName, CryptoUtils.aeskey);
                Double longitude = user.get().getLongitude();
                String encryptedLongitude = CryptoUtils.encryptData(longitude.toString(), CryptoUtils.aeskey);
                Double latitude = user.get().getLatitude();
                String encryptedLatitude = CryptoUtils.encryptData(latitude.toString(), CryptoUtils.aeskey);
                logger.info("사용자 조회 성공: userName = {}", userName);
                return ResponseEntity.ok().body("UserName: " + encryptedUserName + ", Longitude: " + encryptedLongitude + ", Latitude: " + encryptedLatitude);
            } else {
                logger.warn("사용자를 찾을 수 없음: userId = {}", userId);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("L_GET 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @GetMapping("/{userId}/allcompanions")
    public ResponseEntity<?> getAllCompanions(@PathVariable String userId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "ALL_COMPANIONS_GET");
        logger.info("ALL_COMPANIONS_GET 요청 수신: UserID = {}", userId);
        try {
            Long trueUserId = Long.parseLong(CryptoUtils.decryptData(userId, CryptoUtils.aeskey));
            List<Companion> companions = userRepository.findAllCompanionsByUserId(trueUserId);
            logger.info("조회 성공: {}명의 동행자 발견, userID = {}", companions.size(), trueUserId);

            String encryptedCompanions = companions.stream()
                    .map(Companion::toString)
                    .collect(Collectors.joining(","));
            encryptedCompanions = CryptoUtils.encryptData(encryptedCompanions, CryptoUtils.aeskey);

            return ResponseEntity.ok().body(encryptedCompanions);
        } catch (Exception e) {
            logger.error("ALL_COMPANIONS_GET 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @GetMapping("/{userName}/namereq")
    public ResponseEntity<?> getIDByName(@PathVariable String userName) {
        MDC.put("userName", userName);
        MDC.put("actionType", "CL_GET");
        logger.info("ID_req 요청 수신: userName = {}", userName);
        try {
            String trueUserName = CryptoUtils.decryptData(userName, CryptoUtils.aeskey);
            Optional<Users> user = Optional.ofNullable(userRepository.findByName(trueUserName));
            if (user.isPresent()) {
                String userID = String.valueOf(user.get().getUserId());
                logger.info("사용자 조회 성공: userID = {}", userID);
                String encryptedUserID = CryptoUtils.encryptData(userID,CryptoUtils.aeskey);
                return ResponseEntity.ok().body(encryptedUserID);
            } else {
                logger.warn("사용자를 찾을 수 없음: userName = {}", userName);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("ID_req 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @GetMapping("/{userName}/compaloc")
    public ResponseEntity<?> getLocationByName(@PathVariable String userName) {
        MDC.put("userName", userName);
        MDC.put("actionType", "CL_GET");
        logger.info("CL_GET 요청 수신: userName = {}", userName);
        try {
            String trueUserName = CryptoUtils.decryptData(userName, CryptoUtils.aeskey);
            Optional<Users> user = Optional.ofNullable(userRepository.findByName(trueUserName));
            if (user.isPresent()) {
                Double longitude = user.get().getLongitude();
                String encryptedLongitude = CryptoUtils.encryptData(longitude.toString(), CryptoUtils.aeskey);
                Double latitude = user.get().getLatitude();
                String encryptedLatitude = CryptoUtils.encryptData(latitude.toString(), CryptoUtils.aeskey);
                logger.info("사용자 조회 성공: userName = {}", userName);
                return ResponseEntity.ok().body("Longitude: " + encryptedLongitude + ", Latitude: " + encryptedLatitude);
            } else {
                logger.warn("사용자를 찾을 수 없음: userName = {}", userName);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("CL_GET 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<?> deleteById(@PathVariable String userId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "DELETE");
        logger.info("DELETE 요청 수신: userId = {}", userId);

        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            long trueUserId = Long.parseLong(decryptedUserId);
            userRepository.deleteById(trueUserId);
            logger.info("사용자 삭제 성공: userId = {}", trueUserId);
            return ResponseEntity.ok().build(); // 삭제 완료 시 OK 응답 반환
        } catch (Exception e) {
            logger.error("DELETE 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @PostMapping("/{userId}/{encryptedCompId}/compadd")
    public ResponseEntity<?> addCompanion(@PathVariable String userId,
                                               @PathVariable String encryptedCompId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "Comp_ADD");
        logger.info("Comp_ADD 요청 수신: UserId = {}, CompId = {}, CompCount = {}", userId,encryptedCompId);
        try {
            Long decryptedCompID= Long.parseLong(CryptoUtils.decryptData(encryptedCompId,CryptoUtils.aeskey));
            Long decryptedUserID= Long.parseLong(CryptoUtils.decryptData(userId,CryptoUtils.aeskey));
            userRepository.addCompanion(decryptedUserID, decryptedCompID);
            Optional<Users> user = userRepository.findById(decryptedCompID);
            if (user.isPresent()) {
                logger.info("Comp_ADD 성공: CompUserName = {}", user.get().getName());
                return ResponseEntity.ok().body(CryptoUtils.encryptData(user.get().getName(), CryptoUtils.aeskey));
            }else {
                logger.warn("사용자를 찾을 수 없음: CompUserId = {}", decryptedCompID);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
        } catch (Exception e) {
            logger.error("Comp_ADD 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @PostMapping("/{userId}/{latitude}/{longitude}")
    public ResponseEntity<?> addLocation(@PathVariable String userId, @PathVariable String latitude, @PathVariable String longitude) {
        MDC.put("userId", userId);
        MDC.put("actionType", "L_POST");
        logger.info("L_POST 요청 수신: UserId = {}, Latitude = {}, Longitude = {}", userId, latitude, longitude);

        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            long trueUserId = Long.parseLong(decryptedUserId);
            String decryptedLatitude = CryptoUtils.decryptData(latitude, CryptoUtils.aeskey);
            double trueLatitude = Double.parseDouble(decryptedLatitude);
            String decryptedLongitude = CryptoUtils.decryptData(longitude, CryptoUtils.aeskey);
            double trueLongitude = Double.parseDouble(decryptedLongitude);

            // Update the user's location
            Optional<Users> userOptional = Optional.ofNullable(userRepository.findById(trueUserId));
            if (userOptional.isPresent()) {
                Users user = userOptional.get();
                user.setLongitude(trueLongitude);
                user.setLatitude(trueLatitude);
                userRepository.save(user);
                logger.info("사용자 위치 정보 갱신 성공: userId = {}", trueUserId);
                return ResponseEntity.ok("Location updated successfully");
            } else {
                logger.error("사용자 검색 실패: userId = {}", trueUserId);
                return ResponseEntity.status(404).body("User not found");
            }
        } catch (Exception e) {
            logger.error("L_POST 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @PostMapping("/{userId}/{name}/{phoneNumber}/{email}/{password}")
    public ResponseEntity<?> addUser(@PathVariable("userId") String userId,
                                     @PathVariable("name") String name,
                                     @PathVariable("phoneNumber") String phoneNumber,
                                     @PathVariable("email") String email,
                                     @PathVariable("password") String password) {
        MDC.put("userId", userId);
        MDC.put("actionType", "POST");
        logger.info("POST 요청 수신: UserId = {}, Name = {}, PhoneNumber = {}, Email = {}, password = {}", userId, name, phoneNumber, email, password);

        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            String decryptedUserName = CryptoUtils.decryptData(name, CryptoUtils.aeskey);
            String decryptedUserPhoneNumber = CryptoUtils.decryptData(phoneNumber, CryptoUtils.aeskey);
            String decryptedEmail = CryptoUtils.decryptData(email, CryptoUtils.aeskey);
            String decryptedPassword = CryptoUtils.decryptData(password, CryptoUtils.aeskey);

            long userIdLong = Long.parseLong(decryptedUserId);
            Users user = new Users(userIdLong, decryptedUserName, decryptedUserPhoneNumber, decryptedEmail,decryptedPassword);
            Users savedUser = userRepository.save(user);

            // 응답을 위해 userId 암호화
            String encryptedUserId = CryptoUtils.encryptData(String.valueOf(savedUser.getUserId()), CryptoUtils.aeskey);
            logger.info("사용자 생성 성공: userId = {}", savedUser.getUserId());
            return ResponseEntity.ok().body("사용자가 ID로 생성됨: " + encryptedUserId);
        } catch (Exception e) {
            logger.error("POST 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }
    @PostMapping("/{companionId}/sendNotification")
    public ResponseEntity<?> sendNotification(@PathVariable String companionId) {

        MDC.put("actionType", "SEND_NOTIFICATION");

        try {
            String decryptedCompanionId = CryptoUtils.decryptData(companionId, CryptoUtils.aeskey);
            long trueCompanionId = Long.parseLong(decryptedCompanionId);

            // 사용자 조회
            Optional<Users> userOptional = Optional.ofNullable(userRepository.findById(trueCompanionId));
            if (userOptional.isPresent()) {
                Users user = userOptional.get();
                String token = user.getFcmToken();
                if (token != null && !token.isEmpty()) {
                    token = CryptoUtils.encryptData(token,CryptoUtils.aeskey);
                    logger.info("조회된 동행자 Token: token = {}", token);
                    return ResponseEntity.ok().body(token);
                } else {
                    logger.warn("FCM 토큰이 없음: companionId = {}", trueCompanionId);
                    return ResponseEntity.status(HttpStatus.NO_CONTENT).body("FCM 토큰이 없습니다.");
                }
            } else {
                logger.warn("사용자를 찾을 수 없음: companionId = {}", trueCompanionId);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("사용자를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            logger.error("SEND_NOTIFICATION 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

    @PostMapping("/{userId}/{token}/updateToken")
    public ResponseEntity<?> updateToken(@PathVariable("userId") String userId, @PathVariable("token") String token) {
        MDC.put("userId", userId);
        MDC.put("actionType", "UPDATE_TOKEN");
        logger.info("UPDATE_TOKEN 요청 수신: userId = {}", userId);

        try {
            String decryptedUserId = CryptoUtils.decryptData(userId, CryptoUtils.aeskey);
            long trueUserId = Long.parseLong(decryptedUserId);

            Optional<Users> userOptional = Optional.ofNullable(userRepository.findById(trueUserId));
            if (userOptional.isPresent()) {
                token = CryptoUtils.decryptData(token,CryptoUtils.aeskey);
                Users user = userOptional.get();
                user.setFcmToken(token);
                userRepository.save(user);
                logger.info("FCM 토큰 업데이트 성공: userId = {}", trueUserId);
                return ResponseEntity.ok("FCM 토큰 업데이트 성공");
            } else {
                logger.warn("사용자를 찾을 수 없음: userId = {}", trueUserId);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("사용자를 찾을 수 없습니다.");
            }
        } catch (Exception e) {
            logger.error("UPDATE_TOKEN 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }



    @DeleteMapping("/{userId}/{companionId}/compdel")
    public ResponseEntity<?> addUser(@PathVariable("userId") String userId,
                                     @PathVariable("companionId") String compId) {
        MDC.put("userId", userId);
        MDC.put("actionType", "DEL");
        logger.info("Comp DEL 요청 수신. User Id = {}, Comp Id = {}", userId,compId);

        try {
            Long decryptedUserId = Long.parseLong(CryptoUtils.decryptData(userId, CryptoUtils.aeskey));
            Long decryptedCompId = Long.parseLong(CryptoUtils.decryptData(compId, CryptoUtils.aeskey));
            userRepository.deleteCompanionByUserIdAndCompanionId(decryptedUserId,decryptedCompId);
            logger.info("동행자 삭제 성공: userId = {}");
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            logger.error("Comp DEL 요청 처리 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("데이터 처리 중 오류 발생");
        } finally {
            MDC.clear();
        }
    }

}