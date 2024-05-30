package com.example.demo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface UserRepository extends JpaRepository<Users, Long> {
        Users findById(long userId);
        void deleteById(long userId);

        Users findByName(String name);  // Ensure 'name' matches the field in Users entity
        Users findByNameAndPassword(String name, String password);

        @Modifying
        @Transactional
        @Query(value = "INSERT INTO companions (USER_ID, COMP_USER_NAME) VALUES (:userId, :compUserID)", nativeQuery = true)
        void addCompanion(@Param("userId") Long userId,
                          @Param("compUserID") Long compUserID);

        @Query(value = "SELECT CONTACT_COUNT FROM companions WHERE USER_ID = :userId", nativeQuery = true)
        Integer findContactCountByUserIdAndCompUserName(@Param("userId") Long userId);

        @Query("SELECT c FROM Companion c WHERE c.userId = :userId")
        List<Companion> findAllCompanionsByUserId(@Param("userId") Long userId);

        @Modifying
        @Transactional
        @Query(value = "DELETE FROM companions WHERE user_id = :userId AND comp_user_name = :companionId", nativeQuery = true)
        void deleteCompanionByUserIdAndCompanionId(@Param("userId") Long userId, @Param("companionId") Long companionId);

}
