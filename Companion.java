package com.example.demo;

import jakarta.persistence.*;

@Entity
@Table(name = "companions")
public class Companion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "USER_ID", nullable = false)
    private Long userId;

    @Column(name = "COMP_USER_NAME", nullable = false, length = 50)
    private String compUserName;

    public Companion() {
    }

    public Companion(Long userId, String compUserName, int contactCount) {
        this.userId = userId;
        this.compUserName = compUserName;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getCompUserName() {
        return compUserName;
    }

    public void setCompUserName(String compUserName) {
        this.compUserName = compUserName;
    }


    @Override
    public String toString() {
        return "Companion{" +
                "userId=" + userId +
                ", compUserName='" + compUserName + '\'' +
                '}';
    }
}
