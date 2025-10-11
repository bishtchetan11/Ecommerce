package com.project.ecommerce.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.project.ecommerce.dao.CustomerDao;
import com.project.ecommerce.dao.CustomerDaoImpl;
import com.project.ecommerce.entity.Customer;


@Service
public class CustomerServiceImpl  implements CustomerService{


    
    Customer objcustomer;
    public CustomerServiceImpl (Customer objCustomer)
    {
        this.objcustomer = objcustomer;
    }

    public CustomerServiceImpl()
    {

    }

    @Autowired
    private CustomerDao objCustomerDao;

    public CustomerServiceImpl(CustomerDao objCustomerDao)
    {
        this.objCustomerDao = objCustomerDao;
    }


    
    public Customer createCustomer(Customer  objcustomer) throws Exception
    {


        return objCustomerDao.insertCustomerDetails(objcustomer);
    }
    
    public Customer getCustomer(int customerID) throws Exception
    {
        return objCustomerDao.getCustomerDetails(customerID);

    }

    public Customer modifyCustomer(Customer  objcustomer) throws Exception
    {

        return objCustomerDao.modifyCustomerDetails(objcustomer);
    }

    public Customer removeCustomer(int customerID) throws Exception
    {

        return objCustomerDao.deleteCustomerDetails(customerID);
        
    }
}
