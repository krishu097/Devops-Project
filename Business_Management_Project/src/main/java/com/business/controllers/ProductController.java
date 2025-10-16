package com.business.controllers;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.business.entities.Product;
import com.business.services.ProductServices;

@Controller
public class ProductController {
    
    @Autowired
    private ProductServices productServices;

    // Only add this one method for now
    @GetMapping("/products")
    public String showProducts(Model model) {
        List<Product> products = productServices.getAllProducts();
        model.addAttribute("products", products);
        return "products";
    }
}