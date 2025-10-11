package com.project.ecommerce.dao;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import com.project.ecommerce.entity.Customer;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;

import com.project.ecommerce.RedisConfig;
import org.springframework.data.redis.serializer.StringRedisSerializer;



@Repository
@Transactional
public class CustomerDaoImpl implements CustomerDao{



    Customer objcustomer;

    @Autowired
    EntityManager entityManager;


    @Autowired
    private RedisTemplate redisTemplate;


    public Customer insertCustomerDetails(Customer objcustomer) throws Exception
    {

        int rowCount = entityManager.createNativeQuery("INSERT INTO Customer_Details  (  Customer_Name , Customer_Address,Customer_DOB , Customer_Email,Customer_Phone) values ( :parameter1 ,:parameter2 ,:parameter3, :parameter4,:parameter5 ) ")
                .setParameter("parameter1",objcustomer.getCustomerName())
                .setParameter("parameter2",objcustomer.getCustomerAddress())
                .setParameter("parameter3",objcustomer.getCustomerDOB())
                .setParameter("parameter4", objcustomer.getCustomerEmail())
                .setParameter("parameter5", objcustomer.getCustomerPhone())
                .executeUpdate();

                
                if(rowCount<=0)
                {
                        throw new Exception("Insert Failed For Customer" + objcustomer.getCustomerName());
                }else
                {
    
                try{
                       System.out.println("Returning customer  Object");
            
                       Query idQuery = entityManager.createQuery("Select  LAST_INSERT_ID()");
                       long lastId =  (long) idQuery.getResultList().get(0);
                       objcustomer.setCustomerID((int)lastId);

                       redisTemplate.opsForHash().put("customer", String.valueOf(objcustomer.getCustomerID()), objcustomer);

                        return objcustomer;
                      
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                        return null;
                    }
                }

    }
    public Customer modifyCustomerDetails(Customer objcustomer) throws Exception
    {

        try{

        int rowCount = entityManager.createNativeQuery("UPDATE Customer.Customer_Details  set Customer_Name = :parameter1 , Customer_Address = :parameter2 ,Customer_DOB = :parameter3 , Customer_Email = :parameter4, Customer_Phone = :parameter5 where Customer_ID = :parameter6  ")
        .setParameter("parameter1",objcustomer.getCustomerName())
        .setParameter("parameter2",objcustomer.getCustomerAddress())
        .setParameter("parameter3",objcustomer.getCustomerDOB())
        .setParameter("parameter4", objcustomer.getCustomerEmail())
        .setParameter("parameter5", objcustomer.getCustomerPhone())
        .setParameter("parameter6", objcustomer.getCustomerID())
        .executeUpdate();

        
        if(rowCount<=0)
        {
                throw new Exception("Update  Failed For Customer" + objcustomer.getCustomerName());
        }else
        {
               System.out.println("Returning customer  Object");

               redisTemplate.opsForHash().put("customer", String.valueOf(objcustomer.getCustomerID()), objcustomer);

                return objcustomer;
              
            }
        }
            catch (Exception e)
            {
                e.printStackTrace();
                return null;
            }
        }
        



    public Customer getCustomerDetails(int customerID) throws Exception
    {
        try{
        

            objcustomer = (Customer)redisTemplate.opsForHash().get("customer", String.valueOf(customerID));


            if(objcustomer == null)
            {
            System.out.print("Not Found In Cache");
            Query theQuery = entityManager.createNativeQuery("SELECT  * FROM customer.customer_details where Customer_ID = :customerID",Customer.class);
            theQuery.setParameter("customerID" ,customerID );
            if((objcustomer = (Customer)theQuery.getResultList().get(0))!=null)
            {
                redisTemplate.opsForHash().put("customer", String.valueOf(customerID), objcustomer);
           
            }

         
            }
            else{
                System.out.println("Found In cache!!");
            }
            return  objcustomer;

            }
            catch (Exception e)
            {
                e.printStackTrace();
                return  objcustomer;
            }

    }
    public Customer deleteCustomerDetails(int customerID) throws Exception
    {

        System.out.println("Removing Customer From cache");
        redisTemplate.opsForHash().delete("customer", String.valueOf(customerID));

        System.out.println("Deleting Entry In DB");
        int rowCount = entityManager.createNativeQuery("Delete From customer.customer_details where Customer_ID = :parameter1  ")
        .setParameter("parameter1",customerID)
        .executeUpdate();

        if(rowCount == 0)
        {
            objcustomer.setCustomerID(0);
        }
        else{
            objcustomer.setCustomerID(customerID);
        }
        return objcustomer;
    }
    
}
