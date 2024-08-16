package com.example;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@RestController
public class AppController {

    private final Connection dbConnection;

    public AppController(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    @GetMapping("/get-data")
    public ResponseEntity<List<User>> getData() {
        List<User> users = fetchDataFromDB();
        return ResponseEntity.ok(users);
    }

    @PostMapping("/update-roles")
    public ResponseEntity<List<User>> updateRoles(@RequestBody List<User> users) {
        updateDatabase(users);
        return ResponseEntity.ok(users);
    }

    private void updateDatabase(List<User> users) {
        String sqlStatement = "UPDATE team_members SET member_role=? WHERE member_name=?";
        try (PreparedStatement pstmt = dbConnection.prepareStatement(sqlStatement)) {
            for (User user : users) {
                pstmt.setString(1, user.getRole());
                pstmt.setString(2, user.getName());
                pstmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Consider throwing a custom exception or returning an error response
        }
    }

    private List<User> fetchDataFromDB() {
        List<User> users = new ArrayList<>();
        String sqlStatement = "SELECT member_name, member_role FROM team_members";
        try (PreparedStatement pstmt = dbConnection.prepareStatement(sqlStatement);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                User user = new User(rs.getString("member_name"), rs.getString("member_role"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Consider throwing a custom exception or returning an error response
        }
        return users;
    }

    public static class User {
        private String name;
        private String role;

        // Keep the default constructor for JSON deserialization
        public User() {
        }

        public User(String name, String role) {
            this.name = name;
            this.role = role;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }
    }
}