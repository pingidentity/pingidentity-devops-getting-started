---
title: Evaluation of Docker Base Image Security
---
# Evaluation of Docker Base Image Security

In the Center for Internet Security (CIS) [Docker Benchmark v1.2.0](https://www.cisecurity.org/benchmark/docker/), one of the recommendations says, "4.3 Ensure that unnecessary packages are not installed in the container."

It further states, "You should consider using a minimal base image rather than the standard Red Hat/CentOS/Debian images if you can. Some of the options available include BusyBox and Alpine."

The following sections present security aspects of different Linux distributions compared to Alpine Docker image. This doesn't necessarily mean that one is the best for Docker base images. Other factors, such as usability and compatibility, should also be considered when choosing the most suitable Docker image for an organization.

## Evaluation overview

To evaluate Alpine’s security, we compared it with the following popular Linux distributions: Ubuntu, CentOS, and Red Hat Enterprise Linux 7.

For this comparison, we used the latest version, as of March 12, 2020, of each distribution’s Docker image and compared them in four different categories:

* Image size
* Number of packages installed by default
* Number of historical vulnerabilities reported on [cvedetails.com](https://www.cvedetails.com/)
* Number of vulnerabilities reported by the Clair scan

The following table summarizes the numbers for each distribution.

| | Alpine | Ubuntu | CentOS | RHEL7 |
| --- | --- | --- | --- | --- |
| Image Version | alpine:3.11.3 | ubuntu:18.04 | centos:centos8.1.1911 | rhel7:7.7-481 |
| Image Size | 5.59MB | 64.2MB | 237MB | 205MB |
| Number of Packages Installed | 14 | 89 | 173 | 162 |
| Number of Historical CVE*s | 2 | 2007 | 2 | 662 |
| Number of Vulnerabilities Reported by Clair | 0 | 32 | 7 | 0 |

> *CVE - Common Vulnerabilities and Exposures

## Image size

Alpine has an advantage in image size. Although smaller size doesn’t directly translate into better security, the smaller size does mean less code packed into the image, which means smaller attack surface.

## Number of packages installed

Because of Alpine's smaller size, Alpine has the fewest packages out of box. Fewer packages means lesser chance of having vulnerabilities in the dependencies, which is a plus for security.

## Number of historical CVEs

Alpine and CentOS both rank highest in number of historical CVEs even though CentOS has a close relationship with RHEL7, and RHEL7 has 600+ reported vulnerabilities.

## Number of vulnerabilities reported by Clair

Some vulnerabilities reported by Clair might not be real issues, but their presence does mean extra overhead for developers or security teams to triage these findings. This overhead can be avoided if unnecessary dependencies are excluded from the image in the first place.

## Final evaluation results

Although none of the four categories is perfect on its own for evaluating the security of a Linux distribution, in combination, **Alpine** presents greater advantages for use, which is why we selected it as the disribution for all of our Docker images.

## References

* [CIS Docker Benchmarks](https://www.cisecurity.org/benchmark/docker/)
* [Alpine CVEs](https://www.cvedetails.com/product/38838/Alpinelinux-Alpine-Linux.html?vendor_id=16697)
* [Ubuntu CVEs](https://www.cvedetails.com/product/20550/Canonical-Ubuntu-Linux.html?vendor_id=4781)
* [CentOS CVEs](https://www.cvedetails.com/product/18131/Centos-Centos.html?vendor_id=10167)
* [Redhat Enterprise Linux CVEs](https://www.cvedetails.com/product/78/Redhat-Enterprise-Linux.html?vendor_id=25)

## Ping Identity's Docker Image Hardening Guide

For best practices for securing your product Docker image, see Ping Identity's [Hardening Guide](https://support.pingidentity.com/s/article/Docker-Image-Hardening-Deployment-Guide).
