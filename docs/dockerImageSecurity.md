# Evaluation on Docker Base Image Security

## Introduction

In CIS (Center for Internet Security) [Docker Benchmark v1.2.0](https://www.cisecurity.org/benchmark/docker/), one of the recommendations says, "4.3 Ensure that unnecessary packages are not installed in the container." It further states, "You should consider using a minimal base image rather than the standard Red Hat/CentOS/Debian images if you can. Some of the options available include BusyBox and Alpine." Is Alpine Docker image really more secure than other, more popular Linux distributions?

The focus of this document is the security aspects of different Linux distributions, not which one is the best for Docker base images. Other factors such as usability and compatibility should also be considered based on the actual needs when choosing the most suitable Docker image for an organization.

## Evaluation

To evaluate Alpine’s security, we are going to compare it with the following popular Linux distros: Ubuntu, CentOS, and Red Hat Enterprise Linux 7. We will use the latest version (as of March 12, 2020) of each distro’s Docker image and compare them in four different areas: image size, number of packages installed by default, number of historical vulnerabilities reported on [cvedetails.com](https://www.cvedetails.com/), and number of vulnerabilities reported by Clair scan.

The following table summarises the numbers for each distro. The details of the installed packages and Clair scan results can be found in the appendix section.

| | Alpine | Ubuntu | CentOS | RHEL7 |
| --- | --- | --- | --- | --- |
| Image Version | alpine:3.11.3 | ubuntu:18.04 | centos:centos8.1.1911 | rhel7:7.7-481 |
| Image Size | 5.59MB | 64.2MB | 237MB | 205MB |
| Number of Packages Installed | 14 | 89 | 173 | 162 |
| Number of Historical CVE*s | 2 | 2007 | 2 | 662 |
| Number of Vulnerabilities Reported by Clair | 0 | 32 | 7 | 0 |
 *CVE - Common Vulnerabilities and Exposures

## Image Size

Alpine’s advantage in image size is obvious. Although smaller size doesn’t directly translate into better security, the smaller size does mean less code packed into the image, which means smaller attack surface.

## Number of Packages Installed

Alpine has the fewest packages out of box. This is not a surprise given its tiny size. Fewer packages means lesser chance of having vulnerabilities in the dependencies - a plus for security.

## Number of Historical CVEs

It’s interesting to see Alpine and CentOS tie for the first place in this category, even though CentOS has a close relationship with RHEL7 and RHEL7 has 600+ reported vulnerabilities.

## Number of Vulnerabilities Reported by Clair

There is a good chance that some vulnerabilities reported by Clair are not real issues, but their presence is also an issue. It means extra overhead for developers or security teams to triage these findings. This overhead can be avoided if unnecessary dependencies are excluded from the image in the first place.

## Result

Admittedly, none of the four areas is perfect for evaluating the security of a Linux distro, but in combination, they provide a clear picture that **Alpine** is the winner in this comparison.

## References

* [CIS Docker Benchmarks](https://www.cisecurity.org/benchmark/docker/)
* [Alpine CVEs](https://www.cvedetails.com/product/38838/Alpinelinux-Alpine-Linux.html?vendor_id=16697)
* [Ubuntu CVEs](https://www.cvedetails.com/product/20550/Canonical-Ubuntu-Linux.html?vendor_id=4781)
* [CentOS CVEs](https://www.cvedetails.com/product/18131/Centos-Centos.html?vendor_id=10167)
* [Redhat Enterprise Linux CVEs](https://www.cvedetails.com/product/78/Redhat-Enterprise-Linux.html?vendor_id=25)

