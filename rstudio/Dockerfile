FROM opencpu/rstudio:latest

USER root

# Set the timezone.
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
