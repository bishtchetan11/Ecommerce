package com.project.ecommerce.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.project.ecommerce.entity.Customer;
import com.project.ecommerce.service.CustomerService;

@RestController
@RequestMapping("/customer/api")
public class CustomerRESTController {


   
    private CustomerService customerService;
    @Autowired
    public CustomerRESTController(CustomerService customerService)
    {
        this.customerService = customerService;
    }




    
    @PostMapping(value="/createCustomer")
    public Customer postData( @RequestBody Customer objCustomer) {
       
            
            System.out.println("Here1");
            System.out.println(objCustomer.getCustomerName());
        
            try{
             return customerService.createCustomer(objCustomer);

            }
            catch(Exception e)
            {
               e.printStackTrace();
                throw new CustomerNotFoundException("Customer Details  Not Inserted For  " + objCustomer.getCustomerName() );
            }
        


          
        }



        @GetMapping(value = "/getCustomerDetail")
        public  Customer getCustomerDetails(@RequestParam("base") int customerID)
        {

            try{
              
                Customer objCustomer;
                objCustomer = customerService.getCustomer(customerID);
                return  objCustomer;
            }
            catch(Exception e)
            {
                throw new CustomerNotFoundException("No Details For Customer With ID   " + customerID);
            }


        }


        @PostMapping(value="/modifyCustomer")
        public Customer modifyData( @RequestBody Customer objCustomer) {
           
                
                System.out.println("Here in modifyData");
                System.out.println(objCustomer.getCustomerName());
            
                try{
                 return customerService.modifyCustomer(objCustomer);
    
                }
                catch(Exception e)
                {
                   e.printStackTrace();
                    throw new CustomerNotFoundException("Customer Details  Not Modified For  " + objCustomer.getCustomerName() );
                }
            
              
            }


            @PostMapping(value="/deleteCustomer")
            public Customer deleteData( @RequestParam("base") int customerID) {
               
                    
                    System.out.println("Here in deleteData");
                    System.out.println(customerID);
                
                    try{
                     return customerService.removeCustomer(customerID);
        
                    }
                    catch(Exception e)
                    {
                       e.printStackTrace();
                        throw new CustomerNotFoundException("Customer Details  Not Deleted For  Customer ID  " + customerID);
                    }
                
                  
                }

}
