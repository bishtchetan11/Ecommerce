package com.project.ecommerce.entity;
import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;



@Entity
@Table(name="Customer_Details")

public class Customer implements Serializable{
    
    private static final long  serialVersionUID = 7156526077883281623L; 

    @Id
    @Column(name="Customer_ID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int customerID;

    @Column(name="Customer_Name")
     String customerName;

     @Column(name="Customer_Email")
     String customerEmail;


     @Column(name="Customer_Address")
     String customerAddress;

     @Column(name="Customer_Phone")
     int customerPhone;


     @Column(name="Customer_DOB")
     String customerDOB;

    public int getCustomerID() {
        return this.customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public String getCustomerName() {
        return this.customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return this.customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerAddress() {
        return this.customerAddress;
    }

    public void setCustomerAddress(String customerAddress) {
        this.customerAddress = customerAddress;
    }

    public int getCustomerPhone() {
        return this.customerPhone;
    }

    public void setCustomerPhone(int customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getCustomerDOB() {
        return this.customerDOB;
    }

    public void setCustomerDOB(String customerDOB) {
        this.customerDOB = customerDOB;
    }

    public Customer()
    {
        
    }


    public Customer(int customerID, String customerName, String customerEmail, String customerAddress, int customerPhone, String customerDOB) {
        this.customerID = customerID;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerAddress = customerAddress;
        this.customerPhone = customerPhone;
        this.customerDOB = customerDOB;
    }




    @Override
    public String toString() {
        return "{" +
            " customerID='" + getCustomerID() + "'" +
            ", customerName='" + getCustomerName() + "'" +
            ", customerEmail='" + getCustomerEmail() + "'" +
            ", customerAddress='" + getCustomerAddress() + "'" +
            ", customerPhone='" + getCustomerPhone() + "'" +
            ", customerDOB='" + getCustomerDOB() + "'" +
            "}";
    }


     

}
