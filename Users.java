package com.example.demo;

import jakarta.persistence.*;

@Entity
public class Users {

    @Id
    private long userId;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "name")
    private String name;

    @Column(name = "email")
    private String email;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "password")
    private String password;

    @Column(name = "fcm_token")
    private String fcmToken;

    public Users(long userId, String name, String phoneNumber, String email,String password) {
        this.name = name;
        this.userId = userId;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.password = password;
    }

    public Users() {
    }

    public long getUserId() {
        return this.userId;
    }

    public String getPassword(){
        return this.password;
    }

    public String getPhoneNumber() {
        return this.phoneNumber;
    }

    public String getEmail() {
        return this.email;
    }

    public String getName() {
        return this.name;
    }

    public Double getLongitude() {
        return this.longitude;
    }

    public Double getLatitude() {
        return this.latitude;
    }

    public String getFcmToken() {
        return fcmToken;
    }

    public void setUserId(long id) {
        this.userId = id;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }
}
