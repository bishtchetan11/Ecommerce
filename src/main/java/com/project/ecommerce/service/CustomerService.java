package com.project.ecommerce.service;

import org.springframework.stereotype.Service;

import com.project.ecommerce.entity.Customer;


public interface  CustomerService {


    public Customer createCustomer(Customer  customer) throws Exception;
    
    public Customer getCustomer(int customerID) throws Exception;

    public Customer modifyCustomer(Customer customer) throws Exception;

    public Customer removeCustomer(int customerID) throws Exception;
}
