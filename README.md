# aws_cloud

This the first task of hybrid multi cloud.
Here we built an aws infrastructure using terraform code.
The task includes:

1. Create the key and security group which allow the port 80.
2. Launch EC2 instance.
3. In this Ec2 instance use the key and security group which we have created in step 1.
4. Launch one Volume (EBS) and mount that volume into /var/www/html
5. Developer have uploded the code into github repo also the repo has some images.
6. Copy the github repo code into /var/www/html
7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html

# solution

Firstly We will configure the aws profile.
<img src=" " width="400" height="400">

Then we will set our provider which is aws and the region.
<img src="provider.png" width="400" height="400">

we used existing security group and used an key pair.
<img src="sgweb.png" width="400" height="400">

Then we launch our ec2 instance using our key-pair and security group created earlier.
<img src="instance.png" width="400" height="400">
<img src=" " width="400" height="400">

Creating an EBS volume and will attach this volume to our instance, then we will mount this EBS volume in the /var/www/html location of our instance.
<img src="ebs.png" width="400" height="400">
<img src=" " width="400" height="400">

 Created an Github repo named cloud and uploaded an simple html code into it.
<img src=" " width="400" height="400"> 
<img src=" " width="400" height="400">

Then we will copy the html code into var/www/html folder.
<img src=" " width="400" height="400">
<img src=" " width="400" height="400">

Creating a S3 bucket and uploading images into it and allowing public access.
<img src=" " width="400" height="400">
<img src=" " width="400" height="400">

Then we will create a CloudFront{CDN} using the S3 bucket. We wil update  the html code with cloudfront. 
<img src=" " width="400" height="400">
<img src=" " width="400" height="400">
