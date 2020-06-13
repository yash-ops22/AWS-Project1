
# Cloud
    The cloud gives us easy access to a broad range of
    technologies so that you can innovate faster and
    build nearly anything that we can imagine. We can 
    quickly spin up resources as you need them–from
    infrastructure services, such as compute, storage,
    and databases, to Internet of Things, machine learning,
    data lakes and analytics, and much more.
    <img src="images2.jpeg" >

# AWS
    AWS (Amazon Web Services) is a comprehensive, evolving
    cloud computing platform provided by Amazon that includes
    a mixture of infrastructure as a service (IaaS), platform
    as a service (PaaS) and packaged software as a service
    (SaaS) offerings.
    
    <img src="images.png">
    
    
  # Terraform
    Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage.     existing and popular service providers as well as custom in-house solutions. Configuration files describe to Terraform.     the components needed to run a single application or your entire datacenter.
    
    <img src="images.jpeg">
    
    
  #  Services used

     Service #1 - EC2 [Elastic Compute Cloud]
     Service #2 - S3 Bucket 
     Service #3 - CloudFront
     Service #4 - EBS[Elastic Block Storage]
 


 Here we are creating an infrastructure in the aws cloud using
 aws services and using terraform code.


# The_task_includes:

1. Create the key and security group which allow the port 80.
2. Launch EC2 instance.
3. In this Ec2 instance use the key and security group which we have created in step 1.
4. Launch one Volume (EBS) and mount that volume into /var/www/html
5. Developer have uploded the code into github repo also the repo has some images.
6. Copy the github repo code into /var/www/html
7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html



# Step:1 

Firstly We will configure the aws profile
    
    C:\Users\win 10\Desktop\tera\mytest>aws configure --profile Yashu
    AWS Access Key ID [****************LELI]:
    AWS Secret Access Key [****************Av0P]:
    Default region name [ap-south-1]:
    Default output format [None]:

# Step:2

Then we will set our provider which is aws and the region.

       provider  "aws"   {
            region     = "ap-south-1"
            profile    = "Yashu"
       }


# Step:3

We used existing security group and used an key pair.


<img src="sgweb.png">
<img src="key.png">



# Step:4

Then we launch our ec2 instance using our key-pair and security group created earlier.
Connecting to the instance and install required softwares.



      resource "aws_instance"  "instance1" {


           ami             = "ami-07a8c73a650069cf3"
           instance_type   = "t2.micro"
           key_name	   =  "yashukey1"
           security_groups =  [ "launch-wizard-1" ] 

  
       connection {

            type        = "ssh"
            user        = "ec2-user"
            private_key = file("C:/Users/win 10/Downloads/yashukey1.pem")
            host        = aws_instance.instance1.public_ip
  }



    provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

    tags = {
    Name = "AmazonCloudOS"
      }
   }


<img src="OS.png">


# Step:5
Creating an EBS volume and will attach this volume to our instance.


        resource "aws_ebs_volume" "Ebs" {
 
          availability_zone = aws_instance.instance1.availability_zone
          size              = 1
  
          tags = {
          Name = "EBS_1"
          }
      }

        resource "aws_volume_attachment" "attach_EBS" {

       device_name  =  "/dev/sdh"
       volume_id    =  "${aws_ebs_volume.Ebs.id}"
       instance_id  =  "${aws_instance.instance1.id}"
       force_detach =  true
     }


   <img src="webebs.png">

# Step:6

Mounting the EBS to /var/www/html and then clonig the github repository into this folder.

      resource  "null_resource"  "nullvalue3" {

           depends_on = [
           aws_volume_attachment.attach_EBS,
           ]

       connection {
            type     = "ssh"
            user     = "ec2-user"
            private_key = file("C:/Users/win 10/Downloads/yashukey1.pem")
            host     = aws_instance.instance1.public_ip
         }
  
       provisioner "remote-exec" {
             inline = [
            "sudo mkfs.ext4  /dev/xvdh",
            "sudo mount  /dev/xvdh  /var/www/html",
            "sudo rm -rf /var/www/html/*",
            "sudo git clone https://github.com/yash-ops22/aws_cloud.git /var/www/html/"
            ]
       }
     }



# Step:7

Creating a S3 bucket, uploading images into it amd allowing public access.


      resource  "aws_s3_bucket"    "S3_bucket"    {

       
           bucket = "firsts3bucket121212123"
           acl    = "private"
           force_destroy = true

   
        }
  
           locals {
             s3_origin_id   = "s3bucketOrigin"
    }

      output   "s3bucket_id"   {

              value  =   aws_s3_bucket.S3_bucket.id
     }


      resource "aws_s3_bucket_object" "s3images" {
           
        bucket ="${ aws_s3_bucket.S3_bucket.bucket}" 
        key = "yashukey1"
        source = "C:/Users/win 10/Desktop/uploads/s3images/hc.jpg"

        content_type = "image/jpg"
  }


<img src="webs3.png">





# Step:8

Then we will create a CloudFront{CDN} using the S3 bucket. We wil update  the html code with cloudfront url.


       resource "aws_cloudfront_distribution" "hybridcdn12" {
       origin {
             domain_name = "${aws_s3_bucket.S3_bucket.bucket_regional_domain_name}"
             origin_id   = "${local.s3_origin_id}"
      
     custom_origin_config {

             http_port = 80
             https_port = 80
             origin_protocol_policy = "match-viewer"
             origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
            }
          }
             enabled = true

     default_cache_behavior {
            
             allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
             cached_methods   = ["GET", "HEAD"]
             target_origin_id = "${local.s3_origin_id}"

     forwarded_values {

           query_string = false
           
     cookies {
              forward = "none"
             }
        }
              
              viewer_protocol_policy = "allow-all"
              min_ttl                = 0
              default_ttl            = 3600
              max_ttl                = 86400
    
    }
      restrictions {
             geo_restriction {
               restriction_type = "none"
              }
         }
     viewer_certificate {
           cloudfront_default_certificate = true
           }
}





  <img src="webcdn.png">




# launching our infrastructure 

Merging  the terraform code imto a single file named task.tf and using
Terraform commands to build :

    terraform init -> to install plugins.
    terraform apply --auto-approve -> to launch the whole infratructure.





Using the public IP of our instance we will host our html code.
<img src="web1.png">



We can destroy the infrastructure that we created using command:
         
     terraform destroy --auto-approve
