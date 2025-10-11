package com.project.ecommerce.dao;

import com.project.ecommerce.entity.Customer;

public interface CustomerDao {

    public Customer insertCustomerDetails(Customer objcustomer) throws Exception;
    public Customer modifyCustomerDetails(Customer objcustomer) throws Exception;
    public Customer getCustomerDetails(int customerID) throws Exception;
    public Customer deleteCustomerDetails(int customerID)throws Exception;
    
    
}
