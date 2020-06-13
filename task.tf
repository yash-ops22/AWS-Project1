//Provider

provider "aws" {
  region     = "ap-south-1"
  profile    = "Yashu"
}


//Instance details

resource "aws_instance"  "instance1" {
  ami           = "ami-07a8c73a650069cf3"
  instance_type = "t2.micro"
  key_name	=  "yashukey1"
  security_groups =  [ "launch-wizard-1" ] 

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/win 10/Downloads/yashukey1.pem")
    host     = aws_instance.instance1.public_ip
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


//availibility zone

output  "availibility_zone" {
	value = aws_instance.instance1.availability_zone
}

//IP address
output  "instance1_public_ip" {
	value = aws_instance.instance1.public_ip
}




//EBS volume

resource "aws_ebs_volume" "Ebs" {
  availability_zone = aws_instance.instance1.availability_zone
  size              = 1
  
   tags = {
    Name = "EBS_1"
  }
}

//attaching ebs

resource "aws_volume_attachment" "attach_EBS" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.Ebs.id}"
  instance_id  = "${aws_instance.instance1.id}"
  force_detach = true
}



output  "EBS_details" {
	value = aws_ebs_volume.Ebs.id
}




//amazon s3 bucket

resource "aws_s3_bucket" "S3_bucket" {
  bucket = "firsts3bucket121212123"
  acl    = "private"
  force_destroy = true

}

locals {
  s3_origin_id = "s3bucketOrigin"
}

output "s3bucket_id" {
       value = aws_s3_bucket.S3_bucket.id
}




//cloudfront


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


resource "aws_s3_bucket_object" "s3images" {
bucket ="${ aws_s3_bucket.S3_bucket.bucket}" 
key = "yashukey1"
source = "C:/Users/win 10/Desktop/uploads/s3images/hc.jpg"

content_type = "image/jpg"
}

output  "domain-name" {
  value = aws_cloudfront_distribution.hybridcdn12.domain_name
} 


resource "null_resource" "nullremote33"  {


	provisioner "local-exec" {
	    command = "    ${aws_cloudfront_distribution.hybridcdn12.domain_name}"
  	}
}



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







